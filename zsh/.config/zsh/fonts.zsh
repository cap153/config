FONT_DIR="$HOME/.local/share/fonts/ComicShannsMono"
if [[ ! -d "$FONT_DIR" ]]; then
	echo "Installing Nerd Fonts. If the download fails, you can try deleting the directory $FONT_DIR and restarting zsh."
	mkdir -p $FONT_DIR
	curl -L "https://github.com/cap153/config/releases/download/%E6%88%91%E4%BD%BF%E7%94%A8%E7%9A%84%E5%AD%97%E4%BD%93/ComicShannsMono.tar.gz" -o /tmp/font.tar.gz
	tar -zxvf /tmp/font.tar.gz -C $FONT_DIR
fi

FONT_DIR="$HOME/.local/share/fonts/LxgwWenKai-Screen"
if [[ ! -d "$FONT_DIR" ]]; then
	echo "Installing Chinese fonts. If the download fails, you can try deleting the directory $FONT_DIR and restarting zsh."
	mkdir -p $FONT_DIR
	curl -L "https://github.com/cap153/config/releases/download/%E6%88%91%E4%BD%BF%E7%94%A8%E7%9A%84%E5%AD%97%E4%BD%93/LxgwWenKai-Screen.tar.gz" -o /tmp/font.tar.gz
	tar -zxvf /tmp/font.tar.gz -C $FONT_DIR
fi
