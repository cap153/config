-- 这是一个在 Yazi 中通过 rg 和 skim 搜索文件内容，并用 nvim 打开的插件。
-- 依赖: ripgrep (rg), skim (sk), bat

local M = {}

-- 1. 在模块顶层同步获取状态
-- 这会在插件加载时创建一个名为 'state' 的函数
-- 这个函数可以在之后被调用以获取最新的 CWD
local state = ya.sync(function()
	return cx.active.current.cwd
end)

-- 2. 插件入口函数
function M:entry()
	-- 隐藏 yazi 界面，以便 skim 的 TUI 和后续的 nvim 可以显示
	local _permit = ya.hide()

	-- 调用之前创建的 state() 函数来获取当前目录
	local cwd = state()

	-- 执行 rg | sk 命令并获取用户选择的行
	local selected, err = M.run_grep(cwd)
	if err then
		-- 如果出错，显示一个通知
		return ya.notify({ title = "Grep", content = tostring(err), timeout = 5, level = "error" })
	end

	if not selected or selected == "" then
		-- 如果用户没有选择任何东西就退出了 (e.g., 按下 Esc)
		-- 函数在此处返回，Yazi 会自动重绘界面
		return
	end

	-- 3. 解析 rg 的输出 (e.g., "path/to/file.lua:10:5:local M = {}")
	local parts = M.parse_rg_output(selected)
	if not parts then
		return ya.notify({
			title = "Grep",
			content = "无法解析 rg 输出: " .. selected,
			timeout = 5,
			level = "error",
		})
	end

	-- 4. 在 nvim 中打开文件并等待其关闭
	-- 我们不需要退出 Yazi，只需要阻塞式地运行 nvim
	M.open_in_nvim(cwd, parts)

	-- 当 nvim 关闭后，open_in_nvim 函数返回
	-- entry 函数也随之结束，_permit 被释放，Yazi 会自动重新显示
end

-- 5. 命令执行函数
function M.run_grep(cwd)
	-- preview 脚本，
	-- sk 会在执行前把 {1} 和 {2} 替换成实际的文件名和行号。
	local preview_script = [[
		file="{1}"
		line="{2}"
		start=$((line > 10 ? line - 10 : 1))
		bat --style=numbers --color=always --line-range "$start:" --highlight-line "$line" "$file"
	]]
	
	-- 将 preview 脚本包装成 sk 所需的最终命令格式
	local preview_command_for_sk = "sh -c '" .. preview_script .. "' _ {1} {2}"

	-- sk 需要执行的命令
	local rg_command = 'rg --color=always --vimgrep --smart-case --no-heading --hidden "{}"'

	-- 调用 "sk"，并把每个参数通过 .arg() 方法安全地传递给它。
	local child, err = Command("sk")
		:arg("--ansi")
		:arg("-i")
		:arg("-c")
		:arg(rg_command) -- "-c" 的参数
		:arg("--delimiter")
		:arg(":")        -- "--delimiter" 的参数
		:arg("--nth")
		:arg("4..")       -- "--nth" 的参数
		:arg("--preview")
		:arg(preview_command_for_sk) -- "--preview" 的参数
		:arg("--bind=ctrl-e:down,ctrl-u:up")
		:arg("--layout=reverse")
		:cwd(tostring(cwd))
		:stdout(Command.PIPED)
		:spawn()

	if not child then
		return nil, Err("Failed to start `sk`, error: %s", err)
	end

	local output, err = child:wait_with_output()
	if not output then
		return nil, Err("Cannot read `skim` output, error: %s", err)
	elseif not output.status.success and output.status.code ~= 130 then
		return nil, Err("`skim` exited with error code %s", output.status.code)
	end

	return output.stdout, nil
end

-- 6. 输出解析函数
function M.parse_rg_output(line)
	-- 这个解析器能更好地处理 Windows 路径 (e.g., C:\path)
	local parts = {}
	local remaining_line = line

	-- 提取文件路径 (可以包含冒号，如 C:\...)
	local file_end = remaining_line:find(":%d+:%d+:")
	if not file_end then
		return nil
	end

	parts.file = remaining_line:sub(1, file_end - 1)
	remaining_line = remaining_line:sub(file_end + 1)

	-- 提取行号和列号
	local line_str, col_str, _ = remaining_line:match("([^:]+):([^:]+):(.*)")
	if not (line_str and col_str) then
		return nil
	end

	parts.line = line_str
	parts.column = col_str

	return parts
end

-- 7. 在 nvim 中打开文件的函数
function M.open_in_nvim(cwd, parts)
	-- 将相对路径和当前工作目录结合成绝对路径
	local file_path = cwd:join(parts.file)

	-- 使用链式的 .arg() 方法来明确地传递每个参数。
	-- 这能确保 "+call cursor(...)" 和文件名被当作两个独立的参数，
	-- 就像在 shell 中执行 `nvim "+call..." "filename"` 一样。
	local child, err = Command("nvim")
		:arg(string.format("+call cursor(%s, %s)", parts.line, parts.column))
		:arg(tostring(file_path))
		-- 让 nvim 接管终端的输入、输出和错误流
		:stdin(Command.INHERIT)
		:stdout(Command.INHERIT)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		ya.notify({ title = "Grep", content = "Failed to start nvim: " .. tostring(err), level = "error", timeout = 5 })
		return
	end

	-- 等待 nvim 进程结束。
	child:wait()
end

return M
