-- 显示快捷键：wezterm show-keys
local wezterm = require("wezterm")
local act = wezterm.action --用于设置鼠标等动作
local config ={
	use_fancy_tab_bar = false, -- 顶部状态栏的样式
	show_new_tab_button_in_tab_bar = false, -- 隐藏新建窗口的加号
	hide_tab_bar_if_only_one_tab = true, -- 只有一个窗口时隐藏顶部状态栏
	window_decorations = "RESIZE", -- 窗口装饰
	window_background_opacity = 0.75, -- 窗口透明度
	text_background_opacity = 0.75, -- 字体透明度，适应neovim
	adjust_window_size_when_changing_font_size = false,
  window_close_confirmation = "NeverPrompt", -- 关闭当还有任务时关闭窗口的确认提示，适应joshuto
	warn_about_missing_glyphs=false, -- 关闭当字体缺失时的提示信息
	window_padding = { -- 窗口边距
		left = 7,
		right = 5,
		top = 10,
		bottom = 5
	},

	font_size = 19, -- 字体大小
	font = wezterm.font( -- 字体样式
		"ComicShannsMono Nerd Font",
		{ weight = "Regular" }
	),

	-- color_scheme = "Dracula", -- 主题
	-- color_scheme = "Catppuccin Mocha", -- 主题
	colors = { -- 自定义的背景颜色设置
		-- The default text color
		foreground = '#f8f8f2',
		-- The default background color
		background = '#282a36',
		ansi = {
			'#000000',
			'#ff5555',
			'#50fa7b',
			'#f1fa8c',
			'#bd93f9',
			'#ff79c6',
			'#8be9fd',
			'#bbbbbb',
		},
		brights = {
			'#44475a',
			'#ff5555',
			'#50fa7b',
			'#f1fa8c',
			'#bd93f9',
			'#ff79c6',
			'#8be9fd',
			'#ffffff',
		},
	},
	-- 鼠标右键粘贴
	mouse_bindings = {
		{
			event = { Down = { streak = 1, button = "Right" } },
			mods = "NONE",
			action = act({ PasteFrom = "Clipboard" }),
		},
	},
}

return config
