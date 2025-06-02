#!/bin/sh

# 要安装feh
# find ~/Pictures -type f \(  -name 'i3.jpg' \) -print0 | shuf -n1 -z | xargs -0 feh --bg-fill
find ~/.dotfiles/i3/.config/i3 -type f \(  -name 'jiangjun.jpg' \) -print0 | shuf -n1 -z | xargs -0 feh --bg-fill

