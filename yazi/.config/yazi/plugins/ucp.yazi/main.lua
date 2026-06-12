--[[
================================================================================
UNIVERSAL COPY PASTE PLUGIN FOR YAZI
================================================================================

Contents:

- Helpers
- Entry
- Copy
- Paste Images
- Paste List
- Paste Text To File
- Paste Entry


USAGE:
- Copy: plugin ucp copy [notify]
- Paste: plugin ucp paste [notify]

[notify] is optional and will show a notification when the action is successful or failed.

              ┌─────────────────┐
              │ M:paste_entry() │
              └─────────────────┘
                      │
                      ∨
              ┌─────────────────┐           ┌─────────────────┐           ┌─────────────────┐
              │     check_y()   │           │                 │           │                 │
              │                 │           │                 │           │                 │
              │  Does yazi has  │    YES    │  Are these      │    YES    │  Paste using    │
              │  yanked files   │──────────>│  files cut? 	  │──────────>│  native yazi    │
              │  in app state?  │           │                 │           │  command        │
              │                 │           │                 │           │                 │
              │                 │           │                 │           │       END       │
              └─────────────────┘           └─────────────────┘           └─────────────────┘
                      │                              │
                NO    │                              │ NO
                      ∨                              ∨
              ┌─────────────────┐           ┌─────────────────┐
           	  │  				│	     handle_file_list_paste()
              │ Able to extract │           │                 │
              │ file list from  │    YES    │ Check for       │
              │ text/uri-list   │──────────>│ collisions and  │
              │ or              │           │ paste using fs  │
              │ code/file-list? │           │                 │
              │ 				│           │       END       │
              └─────────────────┘           └─────────────────┘
                      │
                NO    │
                      ∨
              ┌─────────────────┐           ┌─────────────────┐
         	  │ 				│	        handle_image_paste()
              │                 │           │                 │
              │  Clipboard has  │    YES    │ Determines image│
              │  mimetype       │──────────>│ format and      │
              │  image/*?       │           │ assigns timestamp
              │                 │           │ before pasting  │
              │                 │           │ to file     END │
              └─────────────────┘           └─────────────────┘
                      │
                NO    │
                      ∨
              ┌─────────────────┐           ┌─────────────────┐
              │                 │           handle_text_paste()
              │                 │           │                 │
              │  Clipboard has  │    YES    │ Suggest pasting │
              │  any text?      │──────────>│ into new file   │
              │                 │           │                 │
              │                 │           │                 │
              │                 │           │       END       │
              └─────────────────┘           └─────────────────┘
                      │
                NO    │
                      ∨
              ┌─────────────────┐
              │ Display:        │
              │ Clipboard does  │
              │ not contain any │
              │ supported       │
              │ mimetypes  END  │
              └─────────────────┘

================================================================================
]]

local M = {}
local PackageName = "ucp"

--==============================================================================
-- Helpers BEGIN
--==============================================================================

---@enum STATE
local STATE = {
	INPUT_POSITION = "input_position",
	OVERWRITE_CONFIRM_POSITION = "overwrite_confirm_position",
	HIDE_NOTIFY = "hide_notify",
}

local set_state = ya.sync(function(state, key, value)
	if state then
		state[key] = value
	else
		state = {}
		state[key] = value
	end
end)

local get_state = ya.sync(function(state, key)
	if state then
		return state[key]
	else
		return nil
	end
end)

local function warn(s, ...)
	if get_state(STATE.HIDE_NOTIFY) then
		return
	end
	ya.notify({ title = PackageName, content = string.format(s, ...), timeout = 3, level = "warn" })
end

--==============================================================================
-- Helpers END
--==============================================================================

--==============================================================================
-- Entry BEGIN
--==============================================================================

function M:entry(job)
	local action = job.args[1]

	ya.dbg("Action", tostring(action), table.concat(job.args or {}, ", "))

	if not action then
		ya.err("No action, defaulting to paste")
		return M:paste_entry(job)
	end

	if action == "copy" then
		ya.dbg("Calling copy_entry")
		return M:copy_entry(job)
	elseif action == "paste" then
		ya.dbg("Calling paste_entry")
		return M:paste_entry(job)
	else
		warn("Unknown action, requires copy or paste arguement")
		return
	end
end

function M:setup(opts)
	if opts and opts.hide_notify and type(opts.hide_notify) == "boolean" then
		set_state(STATE.HIDE_NOTIFY, opts.hide_notify)
	else
		set_state(STATE.HIDE_NOTIFY, false)
	end
	if opts and opts.input_position and type(opts.input_position) == "table" then
		set_state(STATE.INPUT_POSITION, opts.input_position)
	else
		set_state(STATE.INPUT_POSITION, { "center", w = 70 })
	end
	if opts and opts.overwrite_confirm_position and type(opts.overwrite_confirm_position) == "table" then
		set_state(STATE.OVERWRITE_CONFIRM_POSITION, opts.overwrite_confirm_position)
	else
		set_state(STATE.OVERWRITE_CONFIRM_POSITION, { "center", w = 70, h = 10 })
	end
end

--==============================================================================
-- Entry END
--==============================================================================

--==============================================================================
-- Copy BEGIN
--==============================================================================

-- Get selected or hovered files using ya.sync
local selected_or_hovered = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, u in pairs(tab.selected) do
		paths[#paths + 1] = tostring(u)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths
end)

-- Entry function for copying selected files to clipboard
function M:copy_entry(job)
	ya.dbg("copy_entry called")

	local show_notify = false
	for _, arg in ipairs(job.args or {}) do
		if arg == "notify" then
			show_notify = true
			break
		end
	end

	--support for visual mode, we call it escape before selected_or_hovered, so all files become available in tab.selected
	ya.emit("escape", { visual = true })

	-- Get selected or hovered files first
	local urls = selected_or_hovered()
	ya.dbg("urls:", table.concat(urls, ", "))
	ya.dbg("urls length:", #urls)

	if #urls == 0 then
		if show_notify then
			ya.warn("No file selected")
		end
		return
	end

	-- Call yank to highlight selected files for visual feedback
	ya.emit("yank", {})

	-- Format the URLs for `text/uri-list` specification
	local function encode_uri(uri)
		return uri:gsub("([^%w%-%._~:/])", function(c)
			return string.format("%%%02X", string.byte(c))
		end)
	end

	local file_list_formatted = ""
	for _, path in ipairs(urls) do
		-- Each file path must be URI-encoded and prefixed with "file://"
		file_list_formatted = file_list_formatted .. "file://" .. encode_uri(path) .. "\r\n"
	end

	ya.dbg("file_list_formatted: %s", file_list_formatted)

	-- Try different clipboard commands based on platform
	local status, err = nil, nil

	-- Try wl-copy first (Wayland) with text/uri-list target
	ya.dbg("Attempting wl-copy with text/uri-list target...")
	status, err = Command("wl-copy"):arg("--type"):arg("text/uri-list"):arg(file_list_formatted):spawn():wait()
	ya.dbg(
		"wl-copy text/uri-list result: status=%s, err=%s",
		status and tostring(status.success) or "nil",
		err or "nil"
	)

	-- If wl-copy fails, try pbcopy (macOS)
	if not status or not status.success then
		ya.dbg("wl-copy failed, trying pbcopy...")
		-- For macOS, use the same text/uri-list format
		status, err = Command("pbcopy"):arg(file_list_formatted):spawn():wait()
		ya.dbg("pbcopy result: status=%s, err=%s", status and tostring(status.success) or "nil", err or "nil")
	end

	-- If both fail, try xclip (X11) with text/uri-list
	if not status or not status.success then
		ya.dbg("pbcopy failed, trying xclip...")
		-- xclip supports text/uri-list format
		status, err = Command("xclip")
			:arg("-selection")
			:arg("clipboard")
			:arg("-t")
			:arg("text/uri-list")
			:arg(file_list_formatted)
			:spawn()
			:wait()
		ya.dbg("xclip result: status=%s, err=%s", status and tostring(status.success) or "nil", err or "nil")
	end

	if show_notify then
		if status and status.success then
			ya.notify({
				title = PackageName,
				content = "Successfully copied the file(s) to system clipboard",
				level = "info",
				timeout = 5,
			})
		else
			ya.notify({
				title = PackageName,
				content = string.format("Could not copy selected file(s) %s", status and status.code or err),
				level = "error",
				timeout = 5,
			})
		end
	end
end

--==============================================================================
-- Copy END
--==============================================================================

--==============================================================================
-- Paste Helpers BEGIN
--==============================================================================

local function pathJoin(...)
	-- Detect OS path separator ('\' for Windows, '/' for Unix)
	local separator = package.config:sub(1, 1)
	local parts = { ... }
	local filteredParts = {}
	-- Remove empty strings or nil values
	for _, part in ipairs(parts) do
		if part and part ~= "" then
			table.insert(filteredParts, part)
		end
	end
	-- Join the remaining parts with the separator
	local path = table.concat(filteredParts, separator)
	-- Normalize any double separators (e.g., "folder//file" → "folder/file")
	path = path:gsub(separator .. "+", separator)

	return path
end

local get_cwd = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

local get_current_tab_id = ya.sync(function()
	return tostring(cx.active.id.value)
end)

--==============================================================================
-- Paste Helpers END
--==============================================================================

--==============================================================================
-- Paste Images BEGIN
--==============================================================================

-- Get all available image formats from clipboard
local function get_clipboard_image_targets()
	-- Try macOS first
	local handle = io.popen("osascript -e 'return (clipboard info) as string' 2>/dev/null")
	if handle then
		local info = handle:read("*a")
		handle:close()

		if info and info:match("picture") then
			-- macOS has image in clipboard, return a generic image target
			-- We'll detect the actual format when getting the data
			return "image/png image/jpeg image/tiff image/gif"
		end
	end

	-- Try Linux clipboard tools
	handle = io.popen("xclip -selection clipboard -o -t TARGETS 2>/dev/null || wl-paste --list-types 2>/dev/null")
	if not handle then
		return nil
	end

	local targets = handle:read("*a")
	handle:close()

	if targets and targets:match("image/") then
		return targets
	end

	return nil
end

-- Detect best image format from clipboard (with priority)
local function get_best_image_format(targets)
	if not targets then
		return nil
	end

	-- svg differs from pattern image/jpeg -> .jpeg
	if targets:match("image/svg%+xml") then
		return "svg"
		-- common pattern image/jpeg -> .jpeg
	elseif targets:match("image/") then
		local format = targets:match("image/([%w-]+)")
		if format then
			return format
		else
			-- fallback to png
			warn("Could not determine image format!")
			return "png"
		end
	end

	-- For macOS, if we detect an image but can't determine format, default to png
	if targets:match("image/png image/jpeg image/tiff image/gif") then
		return "png"
	end

	return nil
end

-- Get image data from clipboard
local function get_clipboard_image_data(format)
	local mime_type = "image/" .. format
	if format == "svg" then
		mime_type = "image/svg+xml"
	end

	-- Try macOS clipboard first
	local handle = io.popen("osascript -e 'return (clipboard info) as string' 2>/dev/null")
	if handle then
		local info = handle:read("*a")
		handle:close()

		if info and info:match("picture") then
			-- macOS has image in clipboard, save it to a temporary file and read it
			local temp_file = "/tmp/yazi_clipboard_image." .. format
			local save_cmd = string.format(
				"osascript -e 'set the clipboard to (read (POSIX file \"%s\") as «class PNGf»)' 2>/dev/null || osascript -e 'set the clipboard to (read (POSIX file \"%s\") as «class JPEG»)' 2>/dev/null",
				temp_file,
				temp_file
			)

			-- First, try to get the image data using pbpaste with different formats
			local pbpaste_cmd =
				"pbpaste -Prefer png 2>/dev/null || pbpaste -Prefer jpeg 2>/dev/null || pbpaste 2>/dev/null"
			handle = io.popen(pbpaste_cmd)
			if handle then
				local data = handle:read("*a")
				handle:close()
				if data and #data > 0 then
					return data
				end
			end
		end
	end

	-- Try X11 clipboard (xclip)
	handle = io.popen(string.format("xclip -selection clipboard -o -t %s 2>/dev/null", mime_type))
	if handle then
		local data = handle:read("*a")
		handle:close()
		if data and #data > 0 then
			return data
		end
	end

	-- Try Wayland clipboard (wl-paste)
	handle = io.popen(string.format("wl-paste -t %s 2>/dev/null", mime_type))
	if handle then
		local data = handle:read("*a")
		handle:close()
		if data and #data > 0 then
			return data
		end
	end

	return nil
end

-- Handle image paste (image/ mimetype)
function M:handle_image_paste(image_targets, no_hover, show_notify)
	-- Get best format as suggestion
	local suggested_format = get_best_image_format(image_targets)
	if not suggested_format then
		ya.err("Could not determine image format!")
		return
	end

	-- Generate a default filename with beautiful timestamp
	local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
	local file_name = string.format("pasted_%s.%s", timestamp, suggested_format)

	-- Get the image data from clipboard using the detected format
	local clipboard_content = get_clipboard_image_data(suggested_format)
	if not clipboard_content or #clipboard_content == 0 then
		ya.err("Failed to get image data from clipboard!")
		return
	end

	M:save_file_with_conflict_handling(file_name, clipboard_content, no_hover, show_notify)
end

--==============================================================================
-- Paste Images END
--==============================================================================

--==============================================================================
-- Paste List BEGIN
--==============================================================================
local function escape_lua_pattern(s)
	return s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

-- handle code/file-list clipboard mimetype
local function handle_code_file_list_paste(content)
	ya.dbg("Found code/file-list target, attempting to read...")
	-- Try code/file-list format (VS Code and other editors)
	local code_handle = io.popen("xclip -selection clipboard -o -t code/file-list 2>/dev/null")
	if code_handle then
		local code_content = code_handle:read("*a")
		code_handle:close()

		ya.dbg("code/file-list content: %s", code_content or "empty")

		local file_paths = {}
		for file_path in code_content:gmatch("[^\r\n]+") do
			-- Handle file:// URIs
			if file_path:match("^file://") then
				-- Extract path from file:// URI and URL decode
				local path = file_path:gsub("^file://", "")
				path = path:gsub("%%(%x%x)", function(hex)
					return string.char(tonumber(hex, 16))
				end)
				table.insert(file_paths, path)
				-- Handle direct paths
			elseif file_path:match("^/") or file_path:match("^%.%/") then
				table.insert(file_paths, file_path)
			end
		end
		if #file_paths > 0 then
			ya.dbg("Found %d file paths in code/file-list", #file_paths)
			return file_paths
		end
	end
end

local function handle_text_uri_list_paste(content)
	ya.dbg("Found text/uri-list target as fallback, attempting to read...")
	local uri_handle = io.popen(
		"xclip -selection clipboard -o -t text/uri-list 2>/dev/null || wl-paste -t text/uri-list 2>/dev/null")
	if uri_handle then
		local uri_content = uri_handle:read("*a")
		uri_handle:close()

		ya.dbg("text/uri-list content:", uri_content or "empty")

		local file_paths = {}
		for file_path in uri_content:gmatch("file://([^\r\n]+)") do
			-- URL decode the path
			local decoded_path = file_path:gsub("%%(%x%x)", function(hex)
				return string.char(tonumber(hex, 16))
			end)
			table.insert(file_paths, decoded_path)
		end
		if #file_paths > 0 then
			ya.dbg("Found file paths in text/uri-list", #file_paths)
			return file_paths
		end
	end
end

-- Detect if clipboard contains file URIs and extract all paths
local function get_clipboard_file_uris()
	-- Try macOS pbpaste first
	local handle = io.popen("pbpaste 2>/dev/null")
	if handle then
		local content = handle:read("*a")
		handle:close()

		if content and content:match("^/") then
			-- macOS pbpaste returns file paths directly when files are copied
			local file_paths = {}
			for file_path in content:gmatch("[^\r\n]+") do
				-- Only include absolute paths (starting with /)
				if file_path:match("^/") then
					table.insert(file_paths, file_path)
				end
			end
			if #file_paths > 0 then
				return file_paths
			end
		end
	end

	-- Try to get file URI from clipboard (common in Linux file managers)
	handle = io.popen("xclip -selection clipboard -o -t TARGETS 2>/dev/null || wl-paste --list-types 2>/dev/null")
	if not handle then
		return nil
	end

	local targets = handle:read("*a")
	handle:close()

	-- Check for code/file-list target specifically
	if targets and targets:match("code/file%-list") then
		return handle_code_file_list_paste(targets)
		-- Check for text/uri-list
	elseif targets and targets:match("text/uri%-list") then
		return handle_text_uri_list_paste(targets)
	end

	return nil
end

-- Extract filename from a full path
local function get_filename_from_path(path)
	-- Remove trailing slashes
	path = path:gsub("/$", "")
	-- Extract filename (everything after the last separator)
	local separator = package.config:sub(1, 1)
	local filename = path:match("[^" .. separator .. "]+$")
	return filename or path
end

-- Recursively copy a directory and all its contents
local function copy_directory(source_dir, target_dir, no_hover)
	-- Create target directory
	if target_dir.parent then
		fs.create("dir_all", target_dir.parent)
	end
	fs.create("dir", target_dir)

	local source_dir_escaped = tostring(source_dir):gsub("'", "'\\''")
	local source_files = io.popen("find '" .. source_dir_escaped .. "' -type f 2>/dev/null")
	if not source_files then
		return false
	end

	local success = true
	for line in source_files:lines() do
		-- Get relative path from source directory
		local rel_path = line:gsub("^" .. escape_lua_pattern(tostring(source_dir)) .. "/", "")
		local target_file_path = Url(pathJoin(tostring(target_dir), rel_path))

		-- Read source file content
		local source_content_file = io.open(line, "rb")
		if source_content_file then
			local content = source_content_file:read("*a")
			source_content_file:close()

			-- Ensure parent directories exist
			if target_file_path.parent then
				fs.create("dir_all", target_file_path.parent)
			end

			-- Write the file
			local wrote = fs.write(target_file_path, content)
			if not wrote then
				success = false
			end
		else
			success = false
		end
	end
	source_files:close()

	if success and not no_hover then
		ya.emit("reveal", { tostring(target_dir), tab = get_current_tab_id(), no_dummy = true, raw = true })
	end

	return success
end

-- Check if a path is a directory
local function is_directory(path)
	local path_escaped = tostring(path):gsub("'", "'\\''")
	local check = io.popen("test -d '" .. path_escaped .. "' && echo dir || echo file 2>/dev/null")
	if check then
		local result = check:read("*a")
		check:close()
		return result:match("dir")
	end
	return false
end

-- Check if two paths resolve to the same location (handles symlinks and relative paths)
local function paths_resolve_to_same(source_path, target_path)
	local source_str = tostring(source_path):gsub("'", "'\\''")
	local target_str = tostring(target_path):gsub("'", "'\\''")

	-- Use realpath to resolve both paths to their absolute, canonical forms
	local cmd = string.format("realpath '%s' 2>/dev/null", source_str)
	local source_handle = io.popen(cmd)
	local resolved_source = nil
	if source_handle then
		resolved_source = source_handle:read("*a"):gsub("%s+$", "") -- trim whitespace
		source_handle:close()
	end

	cmd = string.format("realpath '%s' 2>/dev/null", target_str)
	local target_handle = io.popen(cmd)
	local resolved_target = nil
	if target_handle then
		resolved_target = target_handle:read("*a"):gsub("%s+$", "") -- trim whitespace
		target_handle:close()
	end

	-- Compare resolved paths if both resolved successfully
	if resolved_source and resolved_target then
		return resolved_source == resolved_target
	end

	-- Fallback: simple string comparison if realpath failed
	return tostring(source_path) == tostring(target_path)
end

-- Handle directory collision by placing file inside directory and overwriting matching contents
local function handle_directory_collision(dir_path, source_file_uri, source_file_content, no_hover)
	local source_filename = get_filename_from_path(source_file_uri)
	-- Place the file inside the directory
	local target_file = Url(pathJoin(tostring(dir_path), source_filename))

	-- Check if target file exists in the directory
	local exists, _ = fs.cha(target_file)
	if exists then
		-- Try to remove it (could be file or subdirectory)
		local removed, err = fs.remove("file", target_file)
		if not removed and err and tostring(err):match("Is a directory") then
			-- Target is also a directory, recursively overwrite contents
			-- Check if source is also a directory
			local source_uri_esc = tostring(source_file_uri):gsub("'", "'\\''")
			local source_dir_check = io.popen("test -d '" .. source_uri_esc .. "' && echo dir || echo file 2>/dev/null")
			if source_dir_check then
				local result = source_dir_check:read("*a")
				source_dir_check:close()

				if result:match("dir") then
					-- Both are directories, recursively overwrite contents
					local source_files = io.popen("find '" .. source_uri_esc .. "' -type f 2>/dev/null")
					if source_files then
						local success = true
						for line in source_files:lines() do
							-- Get relative path from source directory
							local rel_path = line:gsub("^" .. escape_lua_pattern(source_file_uri) .. "/", "")
							local target_file_path = Url(pathJoin(tostring(target_file), rel_path))

							-- Read source file content
							local source_content_file = io.open(line, "rb")
							if source_content_file then
								local content = source_content_file:read("*a")
								source_content_file:close()

								-- Remove existing file if it exists
								local exists_file, _ = fs.cha(target_file_path)
								if exists_file then
									fs.remove("file", target_file_path)
								end

								-- Ensure parent directories exist
								if target_file_path.parent then
									fs.create("dir_all", target_file_path.parent)
								end

								-- Write the file
								fs.write(target_file_path, content)
							else
								success = false
							end
						end
						source_files:close()
						if success and not no_hover then
							ya.emit(
								"reveal",
								{ tostring(target_file), tab = get_current_tab_id(), no_dummy = true, raw = true }
							)
						end
						return success
					end
				end
			end
			-- If source is a file trying to overwrite a directory, put file inside the directory
			if target_file.parent then
				fs.create("dir_all", target_file.parent)
			end
			fs.write(target_file, source_file_content)
			if not no_hover then
				ya.emit("reveal", { tostring(target_file), tab = get_current_tab_id(), no_dummy = true, raw = true })
			end
			return true
		elseif removed then
			-- Was a file, now removed, write the new file
			if target_file.parent then
				fs.create("dir_all", target_file.parent)
			end
			fs.write(target_file, source_file_content)
			if not no_hover then
				ya.emit("reveal", { tostring(target_file), tab = get_current_tab_id(), no_dummy = true, raw = true })
			end
			return true
		else
			return false
		end
	else
		-- File doesn't exist in directory, just create it
		if target_file.parent then
			fs.create("dir_all", target_file.parent)
		end
		fs.write(target_file, source_file_content)
		if not no_hover then
			ya.emit("reveal", { tostring(target_file), tab = get_current_tab_id(), no_dummy = true, raw = true })
		end
		return true
	end
end

-- Handle file list paste (code/file-list mimetype)
function M:handle_file_list_paste(file_uris, no_hover, show_notify)
	ya.dbg("file_uris: ", table.concat(file_uris, ", "))

	local success_count = 0

	local bulk_action = nil -- nil, "overwrite_all", "copy_all", "cancel_all"

	for i, file_uri in ipairs(file_uris) do
		-- Extract filename from the URI path
		local file_name = get_filename_from_path(file_uri)

		-- Check if source is a directory
		local is_dir = is_directory(file_uri)

		if is_dir then
			-- Handle directory copy
			local dir_path = Url(pathJoin(get_cwd(), file_name))
			local cha, _ = fs.cha(dir_path)
			if cha then
				-- Directory exists, ask user what to do (unless bulk action is set)
				local action = nil

				if bulk_action == "cancel_all" then
					-- Skip all remaining files
					break
				elseif bulk_action == "overwrite_all" then
					action = 1 -- Overwrite
				elseif bulk_action == "copy_all" then
					action = 2 -- Create copy
				else
					-- Show bottom menu with directory info
					action = ya.which({
						cands = {
							{ desc = string.format("Directory: %s", file_name), on = "|" },
							{ desc = string.format("Progress: %d/%d", i, #file_uris), on = "|" },
							{ desc = "", on = "|" },
							{ desc = "Overwrite", on = "o" },
							{ desc = "Merge contents", on = "m" },
							{ desc = "Create copy (_copy)", on = "c" },
							{ desc = "Skip directory", on = "q" },
							{ desc = "Overwrite All", on = "O" },
							{ desc = "Create copy All", on = "C" },
							{ desc = "Cancel All", on = "Q" },
						},
					})

					-- Adjust action index since first three items are info only
					if action and action > 3 then
						action = action - 3
					elseif action and action <= 3 then
						action = nil
					end

					-- Set bulk actions is selected
					if action == 4 then
						bulk_action = "overwrite_all"
						action = 1
					elseif action == 5 then
						bulk_action = "copy_all"
						action = 2
					elseif action == 6 then
						bulk_action = "cancel_all"
						break
					end
				end

				if action == 1 then -- Overwrite
					-- Check if source and destination are the same directory
					if paths_resolve_to_same(file_uri, dir_path) then
						warn("Source and destination are the same", tostring(dir_path))
						-- Skip this directory, continue with next item
					else
						-- Remove existing directory recursively using system command
						local dir_path_str = tostring(dir_path):gsub("'", "'\\''")
						local remove_cmd = io.popen("rm -rf '" .. dir_path_str .. "' 2>&1")
						if remove_cmd then
							local err_output = remove_cmd:read("*a")
							remove_cmd:close()
							-- If removal succeeded or directory didn't exist, proceed with copy
							if err_output == "" or err_output:match("No such file") then
								-- Copy the directory
								if copy_directory(file_uri, dir_path, no_hover) then
									success_count = success_count + 1
								else
									warn("Failed to overwrite directory: %s", tostring(dir_path))
								end
							else
								warn(
									"Failed to remove existing directory: %s (err: %s)",
									tostring(dir_path),
									err_output
								)
							end
						else
							-- Try fs.remove as fallback
							local removed, err = fs.remove("dir", dir_path)
							if removed or (err and tostring(err):match("Is a directory")) then
								if copy_directory(file_uri, dir_path, no_hover) then
									success_count = success_count + 1
								else
									warn("Failed to overwrite directory: %s", tostring(dir_path))
								end
							else
								warn(
									"Failed to remove existing directory: %s (err: %s)",
									tostring(dir_path),
									tostring(err)
								)
							end
						end
					end
				elseif action == 2 then -- Merge
					-- Simply copy into existing directory without deleting it
					if copy_directory(file_uri, dir_path, no_hover) then
						success_count = success_count + 1
					else
						warn("Failed to merge directory: %s", tostring(dir_path))
					end
				elseif action == 3 then -- Create copy
					-- Generate copy directory name with _copy suffix
					local copy_name = file_name .. "_copy"
					local copy_path = Url(pathJoin(get_cwd(), copy_name))

					if copy_directory(file_uri, copy_path, no_hover) then
						success_count = success_count + 1
					else
						warn("Failed to copy directory: %s", tostring(copy_path))
					end
				end
				-- If action == 3 (Cancel) or nil, do nothing
			else
				-- Directory doesn't exist, just copy it
				if copy_directory(file_uri, dir_path, no_hover) then
					success_count = success_count + 1
				else
					warn("Failed to copy directory: %s", file_uri)
				end
			end
		else
			-- Handle file copy
			local source_file = io.open(file_uri, "rb")
			if source_file then
				local file_content = source_file:read("*a")
				source_file:close()

				-- Save the file
				local file_path = Url(pathJoin(get_cwd(), file_name))
				local cha, _ = fs.cha(file_path)
				if cha then
					-- File exists, ask user what to do (unless bulk action is set)
					local action = nil

					if bulk_action == "cancel_all" then
						-- Skip all remaining files
						break
					elseif bulk_action == "overwrite_all" then
						action = 1 -- Overwrite
					elseif bulk_action == "copy_all" then
						action = 2 -- Create copy
					else
						-- Show bottom menu with file info in title
						action = ya.which({
							cands = {
								{ desc = string.format("File: %s", file_name), on = "|" },
								{ desc = string.format("Progress: %d/%d", i, #file_uris), on = "|" },
								{ desc = "", on = "|" },
								{ desc = "Overwrite", on = "o" },
								{ desc = "Create copy (_copy)", on = "c" },
								{ desc = "Skip file", on = "q" },
								{ desc = "Overwrite All", on = "O" },
								{ desc = "Create copy All", on = "C" },
								{ desc = "Cancel All", on = "Q" },
							},
						})

						-- Adjust action index since first three items are info only
						if action and action > 3 then
							action = action - 3
						elseif action and action <= 3 then
							action = nil
						end

						-- Set bulk actions is selected
						if action == 4 then
							bulk_action = "overwrite_all"
							action = 1
						elseif action == 5 then
							bulk_action = "copy_all"
							action = 2
						elseif action == 6 then
							bulk_action = "cancel_all"
							break
						end
					end

					if action == 1 then -- Overwrite
						-- Try to remove as file first
						local deleted_collided_item, err = fs.remove("file", file_path)
						if not deleted_collided_item then
							-- If it failed because it's a directory, handle it by overwriting contents
							if err and tostring(err):match("Is a directory") then
								local handled = handle_directory_collision(file_path, file_uri, file_content, no_hover)
								if handled then
									success_count = success_count + 1
								else
									warn("Failed to overwrite directory contents: %s", tostring(file_path))
								end
							else
								-- Try to write anyway - fs.write might handle overwrite
								local wrote, write_err = fs.write(file_path, file_content)
								if wrote then
									success_count = success_count + 1
									if not no_hover then
										ya.emit("reveal", {
											tostring(file_path),
											tab = get_current_tab_id(),
											no_dummy = true,
											raw = true,
										})
									end
								else
									warn(
										"Failed to overwrite file: %s (delete err: %s, write err: %s)",
										tostring(file_path),
										tostring(err),
										tostring(write_err)
									)
								end
							end
						else
							if file_path.parent then
								fs.create("dir_all", file_path.parent)
							end
							fs.write(file_path, file_content)
							success_count = success_count + 1
							if not no_hover then
								ya.emit(
									"reveal",
									{ tostring(file_path), tab = get_current_tab_id(), no_dummy = true, raw = true }
								)
							end
						end
					elseif action == 2 then -- Create copy
						-- Generate copy filename with simple _copy suffix
						local copy_name = file_name:gsub("(%.%w+)$", "_copy%1")
						if not copy_name:match("_copy") then
							copy_name = copy_name .. "_copy"
						end
						local copy_path = Url(pathJoin(get_cwd(), copy_name))

						if copy_path.parent then
							fs.create("dir_all", copy_path.parent)
						end
						fs.write(copy_path, file_content)
						success_count = success_count + 1
						if not no_hover then
							ya.emit(
								"reveal",
								{ tostring(copy_path), tab = get_current_tab_id(), no_dummy = true, raw = true }
							)
						end
					end
					-- If action == 3 (Cancel) or nil, do nothing
				else
					if file_path.parent then
						fs.create("dir_all", file_path.parent)
					end
					fs.write(file_path, file_content)
					success_count = success_count + 1
					if not no_hover then
						ya.emit(
							"reveal",
							{ tostring(file_path), tab = get_current_tab_id(), no_dummy = true, raw = true }
						)
					end
				end
			else
				warn("Failed to read file: %s", file_uri)
			end
		end
	end

	if success_count > 0 and show_notify then
		ya.notify({
			title = PackageName,
			content = string.format("Successfully pasted %d file(s)", success_count),
			timeout = 3,
			level = "info",
		})
	end
end

--==============================================================================
-- Paste List END
--==============================================================================

--==============================================================================
-- Paste Text To File BEGIN
--==============================================================================

local function input_file_name(default_name)
	local pos = get_state(STATE.INPUT_POSITION)
	pos = pos or { "center", w = 70 }

	local input_value, input_event = ya.input({
		title = "Paste into a new file. Enter file name:",
		value = default_name or "",
		pos = pos,
		-- TODO: remove this after next yazi released
		position = pos,
	})
	if input_event == 1 then
		if not input_value or input_value == "" then
			warn("File name can't be empty!")
			return
		elseif input_value:match("/$") then
			warn("File name can't ends with '/'")
			return
		end
		return input_value
	end
end

-- Handle text paste (text/plain mimetype) - suggest creating a new file
function M:handle_text_paste(clipboard_content, no_hover, show_notify)
	-- Prompt user for filename
	local file_name = input_file_name()
	if not file_name or file_name == "" then
		return
	end

	M:save_file_with_conflict_handling(file_name, clipboard_content, no_hover, show_notify)
end

-- Common function to save file with conflict handling
function M:save_file_with_conflict_handling(file_name, clipboard_content, no_hover, show_notify)
	-- Save the file
	local file_path = Url(pathJoin(get_cwd(), file_name))
	local cha, _ = fs.cha(file_path)
	if cha then
		-- File exists, ask user what to do
		local pos = get_state(STATE.OVERWRITE_CONFIRM_POSITION)
		pos = pos or { "center", w = 80, h = 20 }

		-- Show bottom menu with file info as menu items
		local action = ya.which({
			cands = {
				{ desc = "Overwrite", on = "o" },
				{ desc = "Create copy (_copy)", on = "c" },
				{ desc = "Cancel", on = "q" },
			},
		})

		if action == 1 then -- Overwrite
			local deleted_collided_item, err = fs.remove("file", file_path)
			if not deleted_collided_item then
				-- If it failed because it's a directory, warn and return
				if err and tostring(err):match("Is a directory") then
					warn("Cannot overwrite directory with file: %s", tostring(file_path))
					return
				else
					-- Try to write anyway - fs.write might handle overwrite
					local wrote, write_err = fs.write(file_path, clipboard_content)
					if not wrote then
						warn(
							"Failed to overwrite file: %s (delete err: %s, write err: %s)",
							tostring(file_path),
							tostring(err),
							tostring(write_err)
						)
						return
					end
					if not no_hover then
						ya.emit(
							"reveal",
							{ tostring(file_path), tab = get_current_tab_id(), no_dummy = true, raw = true }
						)
					end
					if show_notify then
						ya.notify({
							title = PackageName,
							content = string.format("Overwritten: %s", file_name),
							timeout = 3,
							level = "info",
						})
					end
					return
				end
			end
			-- File was successfully deleted, now write the new content
			if file_path.parent then
				fs.create("dir_all", file_path.parent)
			end
			local wrote = fs.write(file_path, clipboard_content)
			if wrote then
				if not no_hover then
					ya.emit("reveal", { tostring(file_path), tab = get_current_tab_id(), no_dummy = true, raw = true })
				end
				if show_notify then
					ya.notify({
						title = PackageName,
						content = string.format("Overwritten: %s", file_name),
						timeout = 3,
						level = "info",
					})
				end
			else
				warn("Failed to write file after deletion: %s", tostring(file_path))
			end
		elseif action == 2 then -- Create copy
			-- Generate copy filename with simple _copy suffix
			local copy_name = file_name:gsub("(%.%w+)$", "_copy%1")
			if not copy_name:match("_copy") then
				copy_name = copy_name .. "_copy"
			end
			local copy_path = Url(pathJoin(get_cwd(), copy_name))

			if copy_path.parent then
				fs.create("dir_all", copy_path.parent)
			end
			local wrote = fs.write(copy_path, clipboard_content)
			if wrote then
				if not no_hover then
					ya.emit("reveal", { tostring(copy_path), tab = get_current_tab_id(), no_dummy = true, raw = true })
				end
				if show_notify then
					ya.notify({
						title = PackageName,
						content = string.format("Created copy: %s", copy_name),
						timeout = 3,
						level = "info",
					})
				end
			else
				warn("Failed to create copy: %s", tostring(copy_path))
			end
		end
		-- If action == 3 (Cancel) or nil, do nothing - file is not saved
	else
		-- File doesn't exist, create it
		if file_path.parent then
			fs.create("dir_all", file_path.parent)
		end
		local wrote = fs.write(file_path, clipboard_content)
		if wrote then
			if not no_hover then
				ya.emit("reveal", { tostring(file_path), tab = get_current_tab_id(), no_dummy = true, raw = true })
			end
			if show_notify then
				ya.notify({
					title = PackageName,
					content = string.format("Created: %s", file_name),
					timeout = 3,
					level = "info",
				})
			end
		else
			warn("Failed to create file: %s", tostring(file_path))
		end
	end
end

--==============================================================================
-- Paste Text To File BEGIN
--==============================================================================

--==============================================================================
-- Paste Entry BEGIN
--==============================================================================

-- get list of yanked files and if they are cut
local yanked_info = ya.sync(function()
	local paths = {}
	for _, u in pairs(cx.yanked) do
		paths[#paths + 1] = tostring(u)
	end

	return paths, cx.yanked.is_cut
end)

-- Returns an array of mimetype strings, or nil if unavailable
local function get_clipboard_mimetypes()
	-- Try macOS first
	local handle = io.popen("osascript -e 'return (clipboard info) as string' 2>/dev/null")
	if handle then
		local info = handle:read("*a")
		handle:close()

		if info then
			-- macOS returns different format
			-- Format: "«class PNGf», «class JPEG», picture, text" etc.
			local mimetypes = {}
			for item in info:gmatch("[^,]+") do
				local trimmed_item = item:match("^%s*(.-)%s*$") -- trim
				if trimmed_item and trimmed_item ~= "" then
					table.insert(mimetypes, trimmed_item)
				end
			end
			if #mimetypes > 0 then
				return mimetypes
			end
		end
	end

	-- Try Linux clipboard tools (xclip or wl-paste)
	handle = io.popen("xclip -selection clipboard -o -t TARGETS 2>/dev/null || wl-paste --list-types 2>/dev/null")
	if not handle then
		return nil
	end

	local targets = handle:read("*a")
	handle:close()

	if targets then
		-- Split targets by newline and return as array
		local mimetypes = {}
		for mimetype in targets:gmatch("[^\r\n]+") do
			local trimmed_mimetype = mimetype:match("^%s*(.-)%s*$") -- trim
			if trimmed_mimetype and trimmed_mimetype ~= "" then
				table.insert(mimetypes, trimmed_mimetype)
			end
		end
		if #mimetypes > 0 then
			return mimetypes
		end
	end

	return nil
end

-- Check if mimetypes array contains a mimetype that contains the substring
local function has_mimetype(mimetypes, substring)
	if not mimetypes then
		return false
	end
	for _, mimetype in ipairs(mimetypes) do
		if mimetype:find(substring, 1, true) then
			return true
		end
	end
	return false
end

function M:paste_entry(job)
	local no_hover = job.args.no_hover == nil and false or job.args.no_hover
	local show_notify = false
	for _, arg in ipairs(job.args or {}) do
		if arg == "notify" then
			show_notify = true
			break
		end
	end

	-- 1: Check if there are yanked files in the app state
	local yanked_files, is_cut = yanked_info(job.args[1])

	if is_cut then
		-- If there are cut files, paste them using native command
		ya.emit("paste", {})
		ya.emit("unyank", {})
		return
	end

	-- Get available clipboard mimetypes and route workflow based on them
	local available_mimetypes = get_clipboard_mimetypes()
	if available_mimetypes then
		local mimetypes_display = table.concat(available_mimetypes, ", ")
		ya.dbg("Available clipboard mimetypes:", mimetypes_display)
	end

	if available_mimetypes then
		-- 2: Handle text/uri-list and code/file-list clipboard mimetype
		if
			has_mimetype(available_mimetypes, "code/file-list") or has_mimetype(available_mimetypes, "text/uri-list")
		then
			local file_uris = get_clipboard_file_uris()
			if file_uris and #file_uris > 0 then
				M:handle_file_list_paste(file_uris, no_hover, show_notify)
				ya.emit("unyank", {})
				return
			end
			if #yanked_files > 0 then
				ya.emit("paste", {})
				ya.emit("unyank", {})
			end
			return
		end

		-- 3: Handle image/* mimetype
		if has_mimetype(available_mimetypes, "image/") then
			local image_targets = get_clipboard_image_targets()
			if image_targets then
				M:handle_image_paste(image_targets, no_hover, show_notify)
				ya.emit("unyank", {})
				return
			end
		end

		-- 4: Handle text/plain mimetype - suggest creating a new file
		if
			has_mimetype(available_mimetypes, "text/plain")
			or has_mimetype(available_mimetypes, "TEXT")
			or has_mimetype(available_mimetypes, "STRING")
		then
			local clipboard_content = ya.clipboard()
			if clipboard_content and clipboard_content ~= "" then
				M:handle_text_paste(clipboard_content, no_hover, show_notify)
				ya.emit("unyank", {})
				return
			end
		end
	end

	-- Fallback: Natively paste yanked files if there were any
	-- Could be useful for using yazi in tty
	if #yanked_files > 0 then
		ya.emit("paste", {})
		ya.emit("unyank", {})
		return
	end

	warn("Clipboard does not contain any supported mimetypes")
end

--==============================================================================
-- Paste Entry END
--==============================================================================

return M
