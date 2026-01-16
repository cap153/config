# fcitx5
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
# export GTK_IM_MODULE=wayland
# export INPUT_METHOD=fcitx
# export SDL_IM_MODULE=fcitx

# executable files
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

export ANDROID_HOME=$HOME/.android/Sdk

# https://github.com/noctalia-dev/noctalia-shell/issues/437
export QT_QPA_PLATFORMTHEME="gtk3"
# https://github.com/prasanthrangan/hyprdots/issues/1406
# need install archlinux-xdg-menu for dolphin's open with
export XDG_MENU_PREFIX="arch- kbuildsycoca6"

# xwayland-satellite :12 &
# export DISPLAY=:12

