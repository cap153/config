# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias pacman="sudo pacman"
alias pof="poweroff"
alias c="clear"
alias s="macchina"
# alias ra="$HOME/.config/joshuto/ra.sh"

# tailspin,A log file highlighter,`journalctl -xfu | tspin`
alias less="tspin"

# 挂载相关
# id [用户名]查看uid和gid,blkid查看UUID
# sudo mount -o uid=$UID,gid=$GID,dmask=022,fmask=133 设备 路径
# 自动挂载/dev/sda3      /media/program    ntfs    defaults,utf8,uid=1000,gid=1000,dmask=022,fmask=133     0       0 
# mount -a刷新自动挂载,记得关闭win快速启动
alias ma="mkdir $HOME/usb & sudo mount  -o gid=1000,uid=1000 /dev/sdb1 usb"
alias uma="sudo umount $HOME/usb && rmdir $HOME/usb "
# alias mount="sudo mount  -o gid=1000,uid=1000"
alias ip="ip -c"

# youtube-dl设置代理
alias yd="yt-dlp --external-downloader aria2c --external-downloader-args '-x 16 -k 1M' --cookies '$HOME/.config/cookies.txt' --proxy 'http://127.0.0.1:2080'"

# 终端代理
alias setpxy='export ALL_PROXY=http://127.0.0.1:7897'
alias unsetpxy='unset ALL_PROXY' 
# setpxy () {
#   export http_proxy="http://127.0.0.1:7890"
#   export https_proxy="https://127.0.0.1:7890"
#   echo "HTTP Proxy on"
# }
# unsetpxy () {
#   unset http_proxy
#   unset https_proxy
#   echo "HTTP Proxy off"
# }

# 改键位
# alias qw="setxkbmap us colemak -option altwin:alt_win -option caps:swapescape"
# alias qw="setxkbmap us colemak -option caps:swapescape"
# alias qw="xmodmap $HOME/.config/sway/my_xmodmap"
alias qw="xkbcomp $HOME/.config/sway/map.xkb $DISPLAY"

# 更新我的git仓库
alias ugr="$HOME/Desktop/tools/update_repositories.sh"

# markdown文件图片本地化
alias ml="python ~/Desktop/tools/Md-ImgLocalize/main.py --md_path=./"

# 开关wifi
alias wifion="nmcli radio wifi on"
alias wifioff="nmcli radio wifi off"

# 解决kitty终端ssh问题，只有使用kitty终端时才会alias
[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

# 使用 shell 提示的 Yazi 用户可能希望显示一个指示器，以便轻松知道他们位于 yazi 子 shell 内。
YAZI_TERM=""
if [ -n "$YAZI_LEVEL" ]; then
	YAZI_TERM=" : "
fi
PS1="$PS1$YAZI_TERM"

