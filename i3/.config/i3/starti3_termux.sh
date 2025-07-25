#!/data/data/com.termux/files/usr/bin/bash

# 杀死以前的X11进程
kill -9 $(pgrep -f "termux.x11") 2>/dev/null

# 通过网络启用PulseAudio
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

# 准备termux-x11会话
export XDG_RUNTIME_DIR=${TMPDIR}
termux-x11 :0 >/dev/null &

# 等3秒termux-x11启动
sleep 3

# 启动termux-x11主要活动
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

# 登录proot环境并执行.xinitrc脚本以启动i3wm，这里使用的用户名tiny
proot-distro login debian --user tiny --shared-tmp -- /bin/bash -c 'env PULSE_SERVER=127.0.0.1 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform ~/.xinitrc'
exit 0
