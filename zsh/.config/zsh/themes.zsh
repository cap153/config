THEME_DIR="$HOME/.local/share/themes"
if [[ ! -d "$THEME_DIR" ]]; then
	echo "Installing themes. If the download fails, you can try deleting the directory $THEME_DIR and restarting zsh."
	mkdir -p $THEME_DIR
	curl -L "https://github.com/cap153/config/releases/download/%E6%88%91%E4%BD%BF%E7%94%A8%E7%9A%84%E4%B8%BB%E9%A2%98/Catppuccin-GTK-Theme.tar.gz" -o /tmp/Catppuccin-GTK-Theme.tar.gz
	tar -zxvf /tmp/Catppuccin-GTK-Theme.tar.gz -C $THEME_DIR
	curl -L "https://github.com/cap153/config/releases/download/%E6%88%91%E4%BD%BF%E7%94%A8%E7%9A%84%E4%B8%BB%E9%A2%98/Dracula-GTK-Theme.tar.gz" -o /tmp/Dracula-GTK-Theme.tar.gz
	tar -zxvf /tmp/Dracula-GTK-Theme.tar.gz -C $THEME_DIR
fi

ICONS_DIR="$HOME/.local/share/icons"
if [[ ! -d "$ICONS_DIR" ]]; then
	echo "Installing icons. If the download fails, you can try deleting the directory $ICONS_DIR and restarting zsh."
	mkdir -p $ICONS_DIR
	curl -L "https://github.com/cap153/config/releases/download/%E6%88%91%E4%BD%BF%E7%94%A8%E7%9A%84%E4%B8%BB%E9%A2%98/Catppuccin-icons.tar.gz" -o /tmp/Catppuccin-icons.tar.gz
	tar -zxvf /tmp/Catppuccin-icons.tar.gz -C $ICONS_DIR
	curl -L "https://github.com/cap153/config/releases/download/%E6%88%91%E4%BD%BF%E7%94%A8%E7%9A%84%E4%B8%BB%E9%A2%98/Dracula-cursors.tar.gz" -o /tmp/Dracula-cursors.tar.gz
	tar -zxvf /tmp/Dracula-cursors.tar.gz -C $ICONS_DIR
fi

PIC_DIR="$HOME/github/pic"
if [[ ! -d "$PIC_DIR" ]]; then
	echo "Geting pictures. If the download fails, you can try deleting the directory $PIC_DIR and restarting zsh."
	mkdir -p $PIC_DIR
	git clone --depth 1 https://github.com/cap153/pic.git $PIC_DIR
fi
