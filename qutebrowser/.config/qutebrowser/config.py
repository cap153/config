import os
import shlex

# ==============================================================================
# 基础配置
# ==============================================================================
# qute://version 可以查看版本信息
# 忽略自动生成的配置
config.load_autoconfig(False)
my_proxy_url = "http://127.0.0.1:7897"
os.environ["QB_PROXY"] = my_proxy_url  # 作为环境变量传递给脚本
c.content.proxy = my_proxy_url
c.url.start_pages = ["https://aistudio.google.com/prompts/new_chat"]
c.url.default_page = "about:blank"
# 新建标签页时使用的搜索引擎
c.url.searchengines = {
    "DEFAULT": "https://www.google.com/search?q={}",
    "b": "https://www.bing.com/search?q={}",
    "d": "https://duckduckgo.com/?q={}",
}
# 隐藏系统窗口标题栏
c.window.hide_decoration = True
# 隐藏底部状态栏 (平时隐藏，输入命令或报错时自动浮现)
c.statusbar.show = "in-mode"
# 启用强制暗色模式
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.preferred_color_scheme = "dark"
# 图片处理策略
# 'smart': 智能分析图片，如果是简单的图标/二维码则反转颜色，如果是照片则保持原样
# 'never': 永远不反转图片 (推荐，防止表情包变鬼片)
c.colors.webpage.darkmode.policy.images = "smart"
# 窗口化全屏
# c.content.fullscreen.window = True

# ==============================================================================
# 清理与安全
# ==============================================================================
# 防止触发默认危险操作
# config.bind("m", "nop")  # 默认是 quickmark
# config.bind("b", "nop")  # 默认是 quickmark-load

# ==============================================================================
# 历史与输入
# ==============================================================================
config.bind("l", "back")  # 后退
config.bind("k", "hint inputs")  # 聚焦输入框 (类似 focusInput)
# 外部编辑器 (Edit Text)
my_terminal_editor = ["/usr/bin/kitty", "nvim"]
# 在 Insert 模式下按 Ctrl+space 呼出编辑器输入
c.editor.command = my_terminal_editor + ["{file}"]
config.bind("<Ctrl-space>", "edit-text", mode="insert")
# 绑定 r 重载配置
config.bind("r", 'config-source ;; reload ;; message-info "配置已重载 & 页面已刷新"')

# ==============================================================================
# 页面导航
# ==============================================================================
# Colemak 方向键: u(上), e(下), n(左), i(右)

# 直接映射上下滚动在打开视频时默认是调节音量
config.bind("u", "scroll up")
config.bind("e", "scroll down")
config.bind("n", "scroll left")
config.bind("i", "scroll right")

# 大幅度滚动
config.bind("U", "fake-key <PgUp>")
config.bind("E", "fake-key <PgDown>")
config.bind("gg", "fake-key <Home>")
config.bind("G", "fake-key <End>")

# 下面的滚动方式在innerHTML无法生效
# 平滑滚动
# config.bind("u", "jseval -q window.scrollBy({ top: -150, behavior: 'smooth' })")
# config.bind("e", "jseval -q window.scrollBy({ top: 150, behavior: 'smooth' })")
# 滚动半页
# config.bind("U", "scroll-page 0 -0.5")  # page up
# config.bind("E", "scroll-page 0 0.5")  # page down
# 设置 U/E 为 5 倍距离 (750px)，模拟 "5k" 和 "5j" 的效果
# config.bind('U', "jseval -q window.scrollBy({ top: -750, behavior: 'smooth' })")
# config.bind('E', "jseval -q window.scrollBy({ top: 750, behavior: 'smooth' })")
# 滚到顶/底部
# config.bind("<Ctrl-u>", "scroll-to-perc 0")
# config.bind("<Ctrl-e>", "scroll-to-perc")

# 命令栏补全导航
# Ctrl-e: 选择下一个候选项 (相当于 Tab / Down)
config.bind("<Ctrl-e>", "completion-item-focus next", mode="command")
# Ctrl-u: 选择上一个候选项 (相当于 Shift-Tab / Up)
config.bind("<Ctrl-u>", "completion-item-focus prev", mode="command")

# ==============================================================================
# 查找与搜索
# ==============================================================================
# = : 跳转到下一个搜索结果 (Next Result)
config.bind("=", "search-next")
# - : 跳转到上一个搜索结果 (Previous Result)
config.bind("-", "search-prev")

# ==============================================================================
# 链接提示
# ==============================================================================

# config.bind("a", "hint")  # 当前标签页打开
# config.bind("A", "hint links tab-fg")  # 新前台标签页打开 (focus)
# 智能匹配
# config.bind('a', 'hint --rapid')
# config.bind('A', 'hint --rapid links tab-fg')
# 会漏掉某些元素，换成最强力的 all 模式：
config.bind("a", "hint all")
config.bind("A", "hint all tab-fg")

# ==============================================================================
# 按键穿透
# ==============================================================================
# 在 Bilibili/YouTube 上，f 全屏、d 弹幕等快捷键无效，使用fake-key映射原本功能
config.bind("f", "fake-key f")
config.bind("d", "fake-key d")
# 临时穿透
config.bind("<Ctrl-v>", "mode-enter passthrough", mode="normal")
config.bind("<Escape>", "mode-leave", mode="passthrough")

# ==============================================================================
# 标签栏
# ==============================================================================
# 位置选项: left, right, top, bottom
# c.tabs.position = 'left'
# 宽度选项：可以是 (如 '15%') 或像素值 (如 200)
# c.tabs.width = 200
# 显示策略: 'always', 'never', 'switching' (切换时才显示)
# c.tabs.show = "switching"
# 快捷键开关
config.bind("tt", "config-cycle tabs.show always never")

# ==============================================================================
# 标签页管理
# ==============================================================================
config.bind("tu", "cmd-set-text -s :open -t")  # 新建标签页
config.bind("tn", "tab-prev")  # 上一个标签页
config.bind("ti", "tab-next")  # 下一个标签页
config.bind("N", "tab-prev")  # 上一个标签页
config.bind("I", "tab-next")  # 下一个标签页
config.bind("<Ctrl-u>", "tab-prev")  # 上一个标签页
config.bind("<Ctrl-e>", "tab-next")  # 下一个标签页
config.bind("tmn", "tab-move -")  # 标签页向左移动
config.bind("tmi", "tab-move +")  # 标签页向右移动

config.bind("x", "tab-close")  # 关闭当前标签
config.bind("Q", "tab-close")  # 关闭当前标签
config.bind("tq", "tab-close")  # 关闭当前标签
config.bind("tQ", "tab-only")  # 关闭其他标签 (closeOtherTabs)
# config.bind('tN', '...') # 暂不支持原生 CloseTabsOnLeft
# config.bind('tI', '...') # 暂不支持原生 CloseTabsOnRight

config.bind("<Ctrl-t>", "cmd-set-text -s :tab-select")  # 搜索已经打开的标签页

# ==============================================================================
# 书签
# ==============================================================================
config.bind("M", "bookmark-add")
config.bind("m", "bookmark-del")
# 搜索书签
config.bind("b", "cmd-set-text -s :bookmark-load -t")
# 快捷键 B 使用编辑器打开书签
bookmark_file = os.path.expanduser("~/.config/qutebrowser/bookmarks/urls")
cmd_edit_bookmark = shlex.join(my_terminal_editor + [bookmark_file])
config.bind("B", f"spawn --detach {cmd_edit_bookmark}")

# ==============================================================================
# 网页翻译
# ==============================================================================

# config.bind('tr', 'open -t https://translate.google.com/translate?sl=auto&tl=zh-CN&u={url}')
cmd_trans_script = "spawn --userscript qb-translate"
config.bind("tr", cmd_trans_script)

# ==============================================================================
# Visual / Caret 模式映射
# ==============================================================================
c.bindings.commands["caret"] = {
    # 基础移动
    "u": "move-to-prev-line",
    "e": "move-to-next-line",
    "n": "move-to-prev-char",
    "i": "move-to-next-char",
    # 快速移动 (模拟 5k / 5j)
    "U": "cmd-run-with-count 5 move-to-prev-line",
    "E": "cmd-run-with-count 5 move-to-next-line",
    # 行首行尾
    "N": "move-to-start-of-line",
    "I": "move-to-end-of-line",
    # 保持 ESC 退出
    "<Escape>": "mode-leave",
    "<Return>": "yank selection",
    "y": "yank selection",
    # 翻译选中的区域
    "tr": cmd_trans_script,
}

# ==============================================================================
# 增强 Esc 键体验 (退出到普通模式并切换回英文输入法)
# ==============================================================================

# 定义一个复合命令：
# mode-leave: 切换回 Normal 模式
# jseval -q ...: 让当前聚焦的元素(输入框)失去焦点
# -q (quiet) 参数是为了防止在底部状态栏显示 "Javascript returned: undefined"
# fcitx5-remote -c: 切换回英文输入法
cmd_escape_fcitx = "mode-leave ;; jseval -q document.activeElement.blur() ;; spawn --detach fcitx5-remote -c"

# 将 Esc 绑定到这个复合命令 (仅针对 insert 模式，之前的退出穿透模式和这里不冲突)
config.bind("<Escape>", cmd_escape_fcitx, mode="insert")


# ==============================================================================
# 油猴插件自动更新列表 (Greasemonkey Auto-Updater)
# ==============================================================================

# 支持 GreasyFork 的详情页链接，也支持直链 (.user.js)
enabled_scripts = [
    # CSDN 去广告
    "https://greasyfork.org/zh-CN/scripts/420352-csdn-focus",
    # 知乎免登录
    "https://greasyfork.org/zh-CN/scripts/396171-%E7%9F%A5%E4%B9%8E%E5%85%8D%E7%99%BB%E5%BD%95",
]

# 禁用的插件 (暂时不想用，但不想删文件，下次启用不用重新下载)
disabled_scripts = [
]

# 注入环境变量
os.environ["QB_GM_LIST"] = " ".join(enabled_scripts)
os.environ["QB_GM_DISABLED_LIST"] = " ".join(disabled_scripts)

# 绑定快捷键 gr 刷新当前配置并调用同步脚本
config.bind("gr", "config-source ;; spawn --userscript qb-update-gm")
