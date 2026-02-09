local M = {}

local get_cwd = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

function M:entry(job)
	local channel = job.args[1] or "files"
	ya.emit("escape", { visual = true })
	local cwd = get_cwd()

	-- 模式 A：直接接管模式 (针对 tv text)
	-- 不重定向输出，允许 tv 内部直接启动 nvim
	if channel == "text" then
		local permit = ui.hide()
		local child, err = Command("tv")
			:arg(channel)
			:cwd(cwd)
			:stdin(Command.INHERIT)
			:stdout(Command.INHERIT)
			:stderr(Command.INHERIT)
			:spawn()

		if child then
			child:wait()
		else
			ya.notify { title = "TV Error", content = "启动失败: " .. tostring(err), level = "error" }
		end
		permit:drop()
		return -- 直接结束，让 tv 处理一切
	end

	-- 模式 B：选择器模式 (针对 tv files)
	-- 需要捕获输出，让 Yazi 实现跳转
	local tmp_file = os.tmpname()
	local permit = ui.hide()
	local child = Command("sh")
		:arg("-c")
		:arg(string.format('tv %s > %q', channel, tmp_file))
		:cwd(cwd)
		:stdin(Command.INHERIT)
		:stdout(Command.INHERIT)
		:stderr(Command.INHERIT)
		:spawn()

	if child then
		child:wait()
	end
	permit:drop()

	-- 读取结果并让 Yazi 跳转
	local f = io.open(tmp_file, "r")
	if f then
		local line = f:read("*all"):gsub("[\r\n]+$", "")
		f:close()
		os.remove(tmp_file)

		if line ~= "" then
			local target = Url(line)
			if not target.is_absolute then
				target = Url(cwd):join(line)
			end
			ya.emit("reveal", { target })
		end
	end
end

return M
