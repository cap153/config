FONTS=(
	"ComicShannsMono"
	"LxgwWenKai-Screen"
	"segoeui"
	"IoskeleyMono-Normal"
)

BASE_URL="https://github.com/cap153/config/releases/download/%E6%88%91%E4%BD%BF%E7%94%A8%E7%9A%84%E5%AD%97%E4%BD%93"

for FONT_NAME in "${FONTS[@]}"; do
	FONT_DIR="$HOME/.local/share/fonts/$FONT_NAME"
	if [[ ! -d "$FONT_DIR" ]]; then
		echo "Installing $FONT_NAME..."
		mkdir -p "$FONT_DIR"
		curl -L "$BASE_URL/$FONT_NAME.tar.gz" -o /tmp/font.tar.gz &&
			tar -zxvf /tmp/font.tar.gz -C "$FONT_DIR"
	fi
done
