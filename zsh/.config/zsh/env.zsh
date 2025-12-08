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

# 在tmux中启用fzf-tab弹窗
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# 使用 shell 提示的 Yazi 用户可能希望显示一个指示器，以便轻松知道他们位于 yazi 子 shell 内。
YAZI_TERM=""
if [ -n "$YAZI_LEVEL" ]; then
	YAZI_TERM=" : "
fi
PS1="$PS1$YAZI_TERM"

# 检测并设置代理
zmodload zsh/net/tcp
if ztcp 127.0.0.1 7897 2>/dev/null; then
    local fd=$REPLY
    ztcp -c $fd
    export ALL_PROXY="http://127.0.0.1:7897"
    export http_proxy="http://127.0.0.1:7897"
    export https_proxy="http://127.0.0.1:7897"
    # 设置一个变量供 Prompt 使用
    export PROXY_STATE="🌐" 
else
    export PROXY_STATE=""
fi

# 将图标添加到右侧提示符
# RPROMPT="$RPROMPT $PROXY_STATE"

# 连接tmux或新建会话
# 检测 tmux 是否安装
if command -v tmux &> /dev/null; then
	# 1. 检测是否是交互式 Shell (防止 scp/sftp 等非交互连接被破坏)
	# 2. 检测当前是否已经在 tmux 里面 (防止无限递归)
	# 3. 检测是否在 VSCode 的内置终端里
	# 4. 检测是否在 Neovim 内置终端里
	if [[ $- == *i* ]] && \
		[ -z "$TMUX" ] && \
		[ "$TERM_PROGRAM" != "vscode" ] && \
		[ -z "$NVIM" ]; then
		# 尝试进入 main 会话
		# 使用 exec 可以替换当前 Shell 进程，这样退出 tmux 时会直接关闭终端，而不是退回到外层 Shell
		exec tmux new-session -A -s main
	fi
fi

  
