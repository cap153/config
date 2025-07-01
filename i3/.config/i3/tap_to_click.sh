#!/bin/bash

# Get id of touchpad and the id of the field corresponding to
# tapping to click
# 3631 Touchpad需要根据自己的实际设备修改，查看命令为'xinput list'
id=`xinput list | grep "3161 Touchpad" | cut -d'=' -f2 | cut -d'[' -f1`

# Set the property to true
xinput --set-prop $id "libinput Tapping Enabled" 1
