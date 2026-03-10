alias pacman="sudo pacman"
alias pof="poweroff"
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

# 更新我的git仓库
alias ugr="$HOME/Desktop/tools/update_repositories.sh"

# markdown文件图片本地化
alias ml="python ~/Desktop/tools/Md-ImgLocalize/main.py --md_path=./"

# 开关wifi
alias wifion="nmcli radio wifi on"
alias wifioff="nmcli radio wifi off"

# 解决kitty终端ssh问题，只有使用kitty终端时才会alias
[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"


