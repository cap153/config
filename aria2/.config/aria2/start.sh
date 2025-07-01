#!/bin/sh

aria2c --conf-path /home/captain/.config/aria2/aria2.conf &

# 使用service启动
# [Unit]
# Description=Run a Custom Script at Startup
# After=default.target

# [Service]
# ExecStart=aria2c --conf-path /home/pi/.config/aria2/aria2.conf

# [Install]
# WantedBy=default.target
