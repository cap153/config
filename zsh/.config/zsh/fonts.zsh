FONT_DIR="$HOME/.local/share/fonts/ComicShannsMono"
if [[ ! -d "$FONT_DIR" ]]; then
	mkdir -p $FONT_DIR
	curl -L "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/ComicShannsMono.zip" -o /tmp/CascadiaCode.zip
	unzip /tmp/CascadiaCode.zip -d $FONT_DIR
fi

FONT_DIR="$HOME/.local/share/fonts/LXGWWenKai"
if [[ ! -d "$FONT_DIR" ]]; then
	mkdir -p $FONT_DIR
	curl -L "https://github.com/lxgw/LxgwWenKai/releases/download/v1.520/lxgw-wenkai-v1.520.tar.gz" -o /tmp/lxgx-wenkai.tar.gz
	tar -zxvf /tmp/lxgx-wenkai.tar.gz -C $FONT_DIR
fi
