#!/bin/bash

# 链接手机目录
ln -sn /storage/emulated/0 $HOME/SD

# 设置 Fcitx5 运行所需的环境变量
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx
export GLFW_IM_MODULE=ibus

# 设置 DISPLAY 变量 (从外部继承)
# 这一步是保险措施，确保会话内有正确的 DISPLAY
export DISPLAY=:0

# 使用 dbus-launch 启动整个 i3 会话
exec dbus-launch --exit-with-session i3
