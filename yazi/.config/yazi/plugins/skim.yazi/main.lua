local M = {}

-- 1. 同步获取当前工作目录 (CWD)
-- 我们不需要像 fzf 插件那样获取已选文件，因为 fd 会自己生成文件列表。
local state = ya.sync(function()
	return cx.active.current.cwd
end)

-- 2. 插件入口函数
function M:entry()
	-- 和 fzf 插件一样，取消所有选择，为新的选择做准备
	ya.emit("escape", { visual = true })

	-- 隐藏 yazi 界面，以便 skim 的 TUI 可以显示
	local _permit = ya.hide()
	local cwd = state()

	-- 执行 skim 命令并获取输出
	local output, err = M.run_with(cwd)
	if not output then
		-- 如果出错，显示一个通知
		return ya.notify { title = "Skim", content = tostring(err), timeout = 5, level = "error" }
	end

	-- 解析 skim 的输出，将其转换为 yazi 的 Url 对象列表
	local urls = M.split_urls(cwd, output)
	if #urls == 0 then
		-- 如果用户没有选择任何东西就退出了 (e.g., 按下 Esc)
		return
	end

	-- 根据选择的数量执行不同操作
	if #urls == 1 then
		-- 如果只选择了一个文件，则在 yazi 中定位并高亮它
		-- fzf 插件在这里会判断是否为目录，但我们的命令 `fd --type f` 只会列出文件，
		-- 所以可以直接 "reveal"。
		ya.emit("reveal", { urls[1], raw = true })
	elseif #urls > 1 then
		-- 如果选择了多个文件，则在 yazi 中将它们全部选中
		urls.state = "on" -- "on" 表示选中
		ya.emit("toggle_all", urls)
	end
end

-- 3. 命令执行函数
function M.run_with(cwd)
	-- 这是您想要执行的完整命令
	local cmd = "fd --type f -HL --exclude .git | sk --multi --preview='bat -n --color=always {}' --bind='ctrl-e:down,ctrl-u:up' --layout=reverse"

	-- 使用 sh -c 来执行整个管道命令
	local child, err = Command("sh")
		:arg("-c")
		:arg(cmd)
		:cwd(tostring(cwd)) -- 在当前 yazi 目录下执行
		:stdout(Command.PIPED) -- 捕获标准输出
		:spawn()

	if not child then
		return nil, Err("Failed to start shell for `skim`, error: %s", err)
	end

	-- 等待命令执行完成并获取输出
	local output, err = child:wait_with_output()
	if not output then
		return nil, Err("Cannot read `skim` output, error: %s", err)
	-- skim 在用户按 Esc 取消时，退出码也是 130
	elseif not output.status.success and output.status.code ~= 130 then
		-- 将 fzf 的错误信息改为 skim
		return nil, Err("`skim` exited with error code %s", output.status.code)
	end
	return output.stdout, nil
end

-- 4. 输出解析函数 (与 fzf 插件完全相同)
-- 这个函数非常有用，它将命令输出的字符串（每行一个路径）转换成 Url 对象，
-- 并且能正确处理绝对路径和相对路径。
function M.split_urls(cwd, output)
	local t = {}
	for line in output:gmatch("[^\r\n]+") do
		local u = Url(line)
		if u.is_absolute then
			t[#t + 1] = u
		else
			t[#t + 1] = cwd:join(u)
		end
	end
	return t
end

return M
