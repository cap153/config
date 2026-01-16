#!/bin/bash

# 链接手机目录
ln -sn /storage/emulated/0 $HOME/SD

# 用户的环境变量
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"

# HomeBrew包管理器
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# 设置 Fcitx5 运行所需的环境变量
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx
export GLFW_IM_MODULE=ibus

# D-Bus 和其他现代应用需要这个变量来存放运行时文件，如socket
export XDG_RUNTIME_DIR="/tmp/user/$(id -u)"
# 确保该目录存在且权限正确
mkdir -p "$XDG_RUNTIME_DIR"
chmod 0700 "$XDG_RUNTIME_DIR"

# 确保之前的D-Bus守护进程已关闭，避免冲突
killall -q dbus-daemon
# 手动启动D-Bus会话守护进程
# 比wm先启动避免dbus-daemon准备好之前就发起了连接请求
dbus-daemon --session --fork --address="unix:path=$XDG_RUNTIME_DIR/bus"
# 并将其地址导出到环境中
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

# 设置 DISPLAY 变量 (从外部继承)
# 这一步是保险措施，确保会话内有正确的 DISPLAY
export DISPLAY=:0

# 使用 dbus-launch 启动 wm
exec bspwm
