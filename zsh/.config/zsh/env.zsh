# 用户的环境变量
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"

# HomeBrew包管理器
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# export LANG=zh_CN.UTF-8
# export LANGUAGE=zh_CN:en_US

# 配置终端代理
# export ALL_PROXY=http://127.0.0.1:7897
# export http_proxy=socks5://127.0.0.1:10086
# export https_proxy=$http_proxy

# 使用本的的ollama模型Set LLM_KEY to NONE
export LLM_KEY=NONE
export OPENROUTER_API_KEY=""
export DEEPSEEK_API_KEY=""

# skip the verification of insecure directories
export ZSH_DISABLE_COMPFIX=true

# 解决cursor使用rust出现"unknown proxy name: 'Cursor'
# https://github.com/getcursor/cursor/issues/549
[[ "$TERM_PROGRAM" == "vscode" ]] && unset ARGV0
# fish添加如下环境变量
# string match -q "$TERM_PROGRAM" "vscode"
# and unset ARGV0

# 正确启动ide
# export _JAVA_AWT_WM_NONREPARENTING=1

# 树莓派远程连接终端临时生效方法
# export TERM=vt100

# 默认编辑器设置为nvim
export EDITOR=nvim

# 禁用桌面剪贴板同步,解决system-clipboard两秒窃取一次焦点
# export CLIPBOARD_NOGUI=1

# windows下设置环境变量
# set OLLAMA_HOST=0.0.0.0

# 使用 shell 提示的 Yazi 用户可能希望显示一个指示器，以便轻松知道他们位于 yazi 子 shell 内。
YAZI_TERM=""
if [ -n "$YAZI_LEVEL" ]; then
	YAZI_TERM=" : "
fi
PS1="$PS1$YAZI_TERM"
