-- 如果安装插件出现
-- error: Your local changes to the following files would be overwritten by checkout
-- 执行下面命令删除本地git仓库缓存
-- rm -rf ~/.local/state/yazi

-- 在状态栏中显示符号链接
Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)
-- 在状态栏中显示用户/文件组
Status:children_add(function()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ""
	end

	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	}
end, 500, Status.RIGHT)

-- 显示git文件的状态
require("git"):setup()
-- 跨实例复制
require("session"):setup {
	sync_yanked = true,
}
-- 智能进入目录或打开文件
require("smart-enter"):setup {
	open_multi = true,
}
