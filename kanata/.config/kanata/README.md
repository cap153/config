[https://shom.dev/start/using-kanata-to-remap-any-keyboard/](https://shom.dev/start/using-kanata-to-remap-any-keyboard/) 

## 权限

```bash
# 1 创建只有读取输入设备 `uinput` 的特定组
sudo groupadd uinput

# 2 将我们的用户添加到 `input` 和 `uinput` 组中
sudo usermod -aG input $USER
sudo usermod -aG uinput $USER

# 3 通过创建规则文件来定义组 `uinput` 的规则
echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-input.rules

# 4 重新加载设备，并已启用新的许可
sudo udevadm control --reload && udevadm trigger --verbose --sysname-match=uniput

# 5 重新加载驱动
sudo modprobe uinput

# 6 重新登录用户
reboot
```

## 运行Kanata作为服务

创建一个称为的文件 `kanata.service` 并将其放入 `~/.config/systemd/user/`:

```service
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata

[Service]
Type=simple
ExecStart=kanata --cfg /home/%u/.dotfiles/kanata/.config/kanata/caps_tap_esc_hold_ctrl.kbd
Restart=no

[Install]
WantedBy=default.target
```

通过下面命令开机自启动、重启kanata服务

```bash
systemctl --user enable kanata.service
systemctl --user restart kanata.service
