FONT_DIR="$HOME/.local/share/fonts/ComicShannsMono"
if [[ ! -d "$FONT_DIR" ]]; then
	echo "正在安装英文字体，如果下载失败可以删除尝试目录 $FONT_DIR 重新启动zsh"
	mkdir -p $FONT_DIR
	curl -L "https://github.com/cap153/config/releases/download/%E6%88%91%E4%BD%BF%E7%94%A8%E7%9A%84%E5%AD%97%E4%BD%93/ComicShannsMono.tar.gz" -o /tmp/font.tar.gz
	tar -zxvf /tmp/font.tar.gz -C $FONT_DIR
fi

FONT_DIR="$HOME/.local/share/fonts/LXGWWenKai"
if [[ ! -d "$FONT_DIR" ]]; then
	echo "正在安装中文字体，如果下载失败可以尝试删除目录 $FONT_DIR 重新启动zsh"
	mkdir -p $FONT_DIR
	curl -L "https://github.com/cap153/config/releases/download/%E6%88%91%E4%BD%BF%E7%94%A8%E7%9A%84%E5%AD%97%E4%BD%93/LXGWWenKai.tar.gz" -o /tmp/font.tar.gz
	tar -zxvf /tmp/font.tar.gz -C $FONT_DIR
fi
