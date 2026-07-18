export ROCM_HOME=/opt/rocm
export PATH=$ROCM_PATH/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
export PATH="$HOME/.zvm/bin:$PATH"
export PATH="$HOME/.local/share/zvm/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export ANDROID_HOME=$HOME/.android/Sdk

# export LANG=zh_CN.UTF-8
# export LANGUAGE=zh_CN:en_US

# export ALL_PROXY=http://127.0.0.1:7897
# export http_proxy=socks5://127.0.0.1:10086
# export https_proxy=$http_proxy

export LLM_KEY=NONE

# 跳过不安全目录的验证
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
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-e:down' 'ctrl-u:up'

# 使用 shell 提示的 Yazi 用户可能希望显示一个指示器，以便轻松知道他们位于 yazi 子 shell 内。
YAZI_TERM=""
if [ -n "$YAZI_LEVEL" ]; then
	YAZI_TERM=" : "
fi
PS1="$PS1$YAZI_TERM"

# 检测并设置代理
if [[ -n "$WSL_DISTRO_NAME" ]]; then
	# 优先获取物理局域网 IP (使用纯 awk 处理，杜绝 grep 带来的 ANSI 颜色)
	host_ip=$(ipconfig.exe 2>/dev/null | tr -d '\r' | awk -F: '/IPv4/ && !/172\./ {print $2; exit}' | tr -d ' ')

	# 若获取失败（例如平板没连 Wi-Fi 断网），自动回退到 WSL2 虚拟网卡网关 IP
	if [[ -z "$host_ip" ]]; then
		host_ip=$(ip -color=never route show 2>/dev/null | awk '/default/ {print $3}')
	fi

	# 若还是为空，最后兜底回退到 127.0.0.1
	[[ -z "$host_ip" ]] && host_ip="127.0.0.1"
else
	# 物理机环境下，直接使用本地回环地址
	host_ip="127.0.0.1"
fi

# >>> sivtr shell integration >>>
export SIVTR_TERMINAL_ID="$$"
_sivtr_precmd() {
  local exit_status=$?
  export SIVTR_LAST_COMMAND="$(fc -ln -1)"
  export SIVTR_LAST_COMMAND_ID="$HISTCMD"
  if [[ -n "${SIVTR_NEXT_COMMAND_CWD:-}" ]]; then
    export SIVTR_COMMAND_CWD="$SIVTR_NEXT_COMMAND_CWD"
  else
    unset SIVTR_COMMAND_CWD
  fi
  export SIVTR_LAST_EXIT_CODE="$exit_status"
  export SIVTR_COMMAND_ENDED_AT="$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)"
  unset SIVTR_COMMAND_DURATION_MS
  export SIVTR_LAST_PROMPT="$(print -P "$PROMPT")"
  sivtr flush >/dev/null 2>&1 || true
  export SIVTR_NEXT_COMMAND_CWD="$PWD"
  return $exit_status
}
if [[ " ${precmd_functions[*]:-} " != *" _sivtr_precmd "* ]]; then
  precmd_functions=(_sivtr_precmd $precmd_functions)
fi
# <<< sivtr shell integration <<<

# 探测端口（硬性限制 0.1 秒超时，避免黑洞网络卡死终端）
if timeout 0.1 bash -c "true &>/dev/null > /dev/tcp/${host_ip}/7897" 2>/dev/null; then
	export ALL_PROXY="http://${host_ip}:7897"
	export http_proxy="http://${host_ip}:7897"
	export https_proxy="http://${host_ip}:7897"
	export PROXY_STATE="🌐"
else
	export PROXY_STATE=""
fi

# 将图标添加到右侧提示符
# RPROMPT="$RPROMPT $PROXY_STATE"

# 连接tmux或新建会话
if command -v tmux &>/dev/null; then
	# 非交互式 Shell，没有被 tmux 环境变量标记，不在 VSCode，不在 Neovim，未被ssh
	if [[ $- == *i* ]] &&
		[ -z "$TMUX" ] &&
		[ "$TERM_PROGRAM" != "vscode" ] &&
		[ -z "$NVIM" ] &&
		[ -z "$SSH_CONNECTION" ] &&
		[[ ! "$TERM" =~ screen ]] &&
		[[ ! "$TERM" =~ tmux ]]; then

		# 在新建或附加会话前，强制将当前客户端健康的全局环境变量刷新写入 tmux server
		tmux set-environment -g PATH "$PATH"
		[[ -n "$WSL_INTEROP" ]] && tmux set-environment -g WSL_INTEROP "$WSL_INTEROP"
		[[ -n "$WSL_DISTRO_NAME" ]] && tmux set-environment -g WSL_DISTRO_NAME "$WSL_DISTRO_NAME"

		# 使用 exec 可以替换当前 Shell 进程，这样退出 tmux 时会直接关闭终端，而不是退回到外层 Shell
		tmux new-session -A -s main
	fi
fi

# 同时加载家目录和当前目录下的 .env（如果存在）
for env_file in "$HOME/.env" "./.env"; do
	if [ -f "$env_file" ]; then
		export $(grep -v '^#' "$env_file" | xargs)
	fi
done
