alias pacman="sudo pacman"
alias c="clear"
alias s="fastfetch"
alias ta='tmux new-session -A -s main'
# 小写 i 每删除一个文件，系统都会询问你是否确认删除，大写 I 要删除的文件数量超过 3 个或者使用了 -f 时会询问
alias rm='rm -I'
# tailspin,A log file highlighter,`journalctl -xfu | tspin`
alias less="tspin"

alias sp="ss -tunlp | grep"

# 调试模式启动chromium
alias chromium="chromium --remote-debugging-port=9222"

# 更新pacman的mirrorlist
alias uml="sudo reflector --country China --age 12 --protocol https --ipv6 --sort rate --save /etc/pacman.d/mirrorlist"

# 挂载相关
alias mount="sudo mount -o uid=$UID,gid=$GID,dmask=022,fmask=133"
alias umount="sudo umount"

alias ip="ip -c"

# youtube-dl设置代理
alias yt-dlp="yt-dlp -f bestvideo+bestaudio/best --proxy 'http://127.0.0.1:7897'"
alias yd="yt-dlp -f bestvideo+bestaudio/best --proxy 'http://127.0.0.1:7897'"
# alias yd="yt-dlp  -f bestvideo+bestaudio/best --external-downloader aria2c --external-downloader-args '-x 16 -k 1M' --cookies '$HOME/.config/cookies.txt' --proxy 'http://127.0.0.1:7897'"

# 终端代理
#alias setpxy='export ALL_PROXY=http://127.0.0.1:7897'
#alias unsetpxy='unset ALL_PROXY'
opxy() {
	export http_proxy="http://${host_ip}:7897"
	export https_proxy="http://${host_ip}:7897"
	echo "HTTP Proxy on (Host: ${host_ip})"
}
cpxy() {
	unset http_proxy
	unset https_proxy
	echo "HTTP Proxy off"
}

# ==========================================================
# 3. tun2socks 快捷开关 (理直气壮物理 IP + DNS 污染净化版)
# ==========================================================

# 关闭 TUN 模式
ctun() {
	echo "🛑 正在关闭 tun2socks 代理..."
	sudo ip route del 0.0.0.0/1 dev tun0 2>/dev/null
	sudo ip route del 128.0.0.0/1 dev tun0 2>/dev/null

	# 清除发往物理代理宿主机的直连旁路路由
	sudo ip route del ${host_ip} 2>/dev/null

	sudo killall -q tun2socks 2>/dev/null
	sudo ip link delete tun0 2>/dev/null

	# 💡 恢复 WSL 默认网关 DNS (避免平时解析变慢)
	if [[ -n "$WSL_DISTRO_NAME" ]]; then
		local wsl_gateway=$(ip -color=never route show 2>/dev/null | awk '/default/ {print $3}')
		[[ -z "$wsl_gateway" ]] && wsl_gateway="127.0.0.1"
		sudo rm -f /etc/resolv.conf 2>/dev/null
		echo "nameserver ${wsl_gateway}" | sudo tee /etc/resolv.conf >/dev/null
	fi

	echo "✅ TUN 全局代理已关闭"
	export http_proxy="http://${host_ip}:7897"
	export https_proxy="http://${host_ip}:7897"
}

# 开启 TUN 模式
otun() {
	ctun
	echo "🚀 正在启动 tun2socks 代理..."
	rm /tmp/tun2socks.log 2>/dev/null
	sudo killall -q tun2socks 2>/dev/null
	sudo ip link delete tun0 2>/dev/null
	sudo ip tuntap add mode tun dev tun0
	sudo ip addr add 198.18.0.1/15 dev tun0
	sudo ip link set dev tun0 up

	# 防止路由环路 (Routing Loop)
	if [[ -n "$WSL_DISTRO_NAME" && "$host_ip" != "127.0.0.1" ]]; then
		local wsl_gateway=$(ip -color=never route show 2>/dev/null | awk '/default/ {print $3}')
		if [[ -n "$wsl_gateway" ]]; then
			sudo ip route add ${host_ip} via ${wsl_gateway} 2>/dev/null
		fi
	fi

	# 启动 tun2socks
	sudo nohup tun2socks -device tun0 -proxy socks5://${host_ip}:7897 -loglevel info >/tmp/tun2socks.log 2>&1 &
	sleep 1

	sudo ip route add 0.0.0.0/1 dev tun0
	sudo ip route add 128.0.0.0/1 dev tun0

	# 💡 临时修改 WSL 内网 DNS 为公共 DNS（如 8.8.8.8）
	if [[ -n "$WSL_DISTRO_NAME" ]]; then
		sudo rm -f /etc/resolv.conf 2>/dev/null
		echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null
	fi

	unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY
	echo "✅ TUN 全局代理已开启！(目标代理: ${host_ip}:7897, 日志: /tmp/tun2socks.log)"
}

# 更新我的git仓库
alias ugr="$HOME/Desktop/tools/update_repositories.sh"

# markdown文件图片本地化
alias ml="python ~/Desktop/tools/Md-ImgLocalize/main.py --md_path=./"

# 开关wifi
alias wifion="nmcli radio wifi on"
alias wifioff="nmcli radio wifi off"

# 解决kitty终端ssh问题，只有使用kitty终端时才会alias
[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

# 快捷启动 claude-tap 反向代理本地模型
tap-local() {
	# 默认转发到 http://127.0.0.1:8080 (llama.cpp)，可通过第一个参数修改
	local target="${1:-http://127.0.0.1:8080}"
	# 默认 claude-tap 监听 1234 端口，可通过第二个参数修改
	local port="${2:-1234}"

	echo "claude-tap 正在启动..."
	echo "监听端口: http://127.0.0.1:$port"
	echo "目标模型: $target"

	claude-tap --tap-no-launch --tap-port "$port" --tap-proxy-mode reverse --tap-target "$target"
}

# 创建（或修改）一个专门存放你个人规则的文件
# sudo visudo -f /etc/sudoers.d/captain
# 尝试添加下面内容以免密(使用当前用户名)：
# captain ALL=(ALL) NOPASSWD: /usr/bin/fstrim -v /
pof() {
	local VHD_WIN_PATH="D:\\archlinux\\ext4.vhdx"
	echo "🛠️  正在执行多重同步..."
	sync && sleep 1 && sync
	if [[ "$(uname -r | tr '[:upper:]' '[:lower:]')" == *microsoft* ]]; then
		echo "🏠 环境：WSL (Windows Subsystem for Linux)"
		echo "🧹 正在标记回收空间 (fstrim)..."
		sudo /usr/bin/fstrim -v /

		echo "🚀 启动独立监护进程并请求管理员权限..."
		/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -NonInteractive -Command "
            \$script = {
                Start-Sleep 1;
                Write-Host '正在关闭 WSL 虚拟机...' -ForegroundColor Yellow;
                wsl.exe --shutdown;
                Write-Host '正在压缩 VHDX...' -ForegroundColor Cyan;
                \$tmp = [System.IO.Path]::GetTempFileName();
                'select vdisk file=\"$VHD_WIN_PATH\"', 'compact vdisk' | Out-File -FilePath \$tmp -Encoding ASCII;
                diskpart.exe /s \$tmp;
                Remove-Item \$tmp;
                Write-Host '任务完成，即将关机...' -ForegroundColor Green;
                Start-Sleep 1;
                shutdown.exe /s /t 0
            };
            Start-Process powershell.exe -ArgumentList \"-NoProfile\", \"-NonInteractive\", \"-Command\", \$script -Verb RunAs
        "
		echo "✅ 监护进程已接管，本窗口即将随 WSL 关闭。"
	else
		echo "💻 环境：物理机"
		poweroff
	fi
}
