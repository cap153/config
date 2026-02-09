function neovide() {
    if [[ -z "$TMUX" || $# -eq 0 ]]; then
        command nvim "$@"
        return
    fi

    # 1. 动态获取当前 Kitty 的真实 PID
    # 逻辑：查找当前 shell 进程的所有父进程，找到名为 kitty 的那一个
    local my_kitty_pid=$(ps -s $$ -o ppid=,comm= | grep -i 'kitty' | awk '{print $1}' | head -n 1)
    
    # 如果通过 ps 没找到（某些系统环境差异），保底方案使用 $KITTY_PID
    [[ -z "$my_kitty_pid" ]] && my_kitty_pid=$KITTY_PID

    # 2. 启动 Neovide 并脱离
    neovide --frame none "$@" >/dev/null 2>&1 &| 
    local nv_pid=$!

    # 3. 后台监听并恢复
    (
        while kill -0 $nv_pid 2>/dev/null; do
            sleep 1
        done
        kitty tmux new-session -A -s main
    ) &!

    # 4. 清理并杀死确认后的 PID
    clear && tmux clear-history
    if [[ -n "$my_kitty_pid" ]]; then
        kill -9 $my_kitty_pid
    fi
}

function ra() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function zle_eval {
    echo -en "\e[2K\r"
    eval "$@"
    zle redisplay
}

function openlazygit {
    zle_eval lazygit
}

zle -N openlazygit; bindkey "^G" openlazygit

function openlazynpm {
    zle_eval lazynpm
}

zle -N openlazynpm; bindkey "^N" openlazynpm
