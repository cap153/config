alias pacman="sudo pacman"
alias c="clear"
alias s="fastfetch"
alias ta='tmux new-session -A -s main'
# 小写 i 每删除一个文件，系统都会询问你是否确认删除，大写 I 要删除的文件数量超过 3 个或者使用了 -f 时会询问
alias rm='rm -I'
# tailspin,A log file highlighter,`journalctl -xfu | tspin`
alias less="tspin"

# 挂载相关
alias mount="sudo mount -o uid=$UID,gid=$GID,dmask=022,fmask=133"
alias umount="sudo umount"

alias ip="ip -c"

# youtube-dl设置代理
alias yd="yt-dlp --external-downloader aria2c --external-downloader-args '-x 16 -k 1M' --cookies '$HOME/.config/cookies.txt' --proxy 'http://127.0.0.1:7897'"

# 终端代理
#alias setpxy='export ALL_PROXY=http://127.0.0.1:7897'
#alias unsetpxy='unset ALL_PROXY'
opxy() {
	export http_proxy="http://127.0.0.1:7897"
	export https_proxy="http://127.0.0.1:7897"
	echo "HTTP Proxy on"
}
cpxy() {
	unset http_proxy
	unset https_proxy
	echo "HTTP Proxy off"
}

# ==========================================
# tun2socks 快捷开关 (WSL 镜像网络版)
# ==========================================

# 关闭 TUN 模式
ctun() {
	echo "🛑 正在关闭 tun2socks 代理..."
	sudo ip route del 0.0.0.0/1 dev tun0 2>/dev/null
	sudo ip route del 128.0.0.0/1 dev tun0 2>/dev/null
	sudo killall -q tun2socks 2>/dev/null
	sudo ip link delete tun0 2>/dev/null
	echo "✅ TUN 全局代理已关闭"
	export http_proxy="http://127.0.0.1:7897"
	export https_proxy="http://127.0.0.1:7897"
}
# 开启 TUN 模式
otun() {
	ctun
	echo "🚀 正在启动 tun2socks 代理..."
	rm /tmp/tun2socks.log
	sudo killall -q tun2socks 2>/dev/null
	sudo ip link delete tun0 2>/dev/null
	sudo ip tuntap add mode tun dev tun0
	sudo ip addr add 198.18.0.1/15 dev tun0
	sudo ip link set dev tun0 up
	sudo nohup tun2socks -device tun0 -proxy socks5://127.0.0.1:7897 -loglevel info >/tmp/tun2socks.log 2>&1 &
	sleep 1
	sudo ip route add 0.0.0.0/1 dev tun0
	sudo ip route add 128.0.0.0/1 dev tun0
	unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY
	echo "✅ TUN 全局代理已开启！(日志: /tmp/tun2socks.log)"
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

# 可以在 /etc/sudoers 尝试添加下面内容以免密(使用当前用户名)：
# captain ALL=(ALL) NOPASSWD: /usr/sbin/fstrim -v /
pof() {
	local VHD_WIN_PATH="D:\\archlinux\\ext4.vhdx"
	echo "🛠️  正在执行多重同步..."
	sync && sleep 1 && sync
	if [[ "$(uname -r | tr '[:upper:]' '[:lower:]')" == *microsoft* ]]; then
		echo "🏠 环境：WSL (Windows Subsystem for Linux)"
		echo "🧹 正在标记回收空间 (fstrim)..."
		sudo fstrim -v /
		echo "🚀 启动独立监护进程并请求管理员权限..."
		/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "
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
            Start-Process powershell.exe -ArgumentList \"-NoProfile\", \"-Command\", \$script -Verb RunAs
        "
		echo "✅ 监护进程已接管，本窗口即将随 WSL 关闭。"
	else
		echo "💻 环境：物理机"
		poweroff
	fi
}
