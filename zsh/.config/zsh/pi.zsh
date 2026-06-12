# Pi agent skills/extensions auto-installer
# Clones git repos into ~/.pi/agent/skills/ if not already present.
# Clones git repos into ~/.pi/agent/extensions/ if not already present.
# Add new skills/extensions by following the same directory-exists pattern below.

SKILLS_BASE="$HOME/.pi/agent/skills"
EXTENSIONS_BASE="$HOME/.pi/agent/extensions"

# ============================================
# browser-harness skill
# ============================================
BH_DIR="$SKILLS_BASE/browser-harness"
if [[ ! -d "$BH_DIR" ]]; then
	echo "Installing browser-harness skill. If the clone fails, delete $BH_DIR and restart zsh."
	mkdir -p "$SKILLS_BASE"
	git clone --depth 1 https://github.com/browser-use/browser-harness.git "$BH_DIR"
	cd "$BH_DIR"
	uv tool install -e .
	command -v browser-harness
fi

# ============================================
# plan-mode extension
# ============================================
PM_DIR="$EXTENSIONS_BASE/plan-mode"
if [[ ! -d "$PM_DIR" ]]; then
	echo "Installing plan-mode extension. If the clone fails, delete $PM_DIR and restart zsh."
	TMP_DIR=$(mktemp -d)
	git init "$TMP_DIR" &>/dev/null
	cd "$TMP_DIR"
	git remote add origin https://github.com/earendil-works/pi.git
	git config core.sparseCheckout true
	echo "packages/coding-agent/examples/extensions/plan-mode/*" >>.git/info/sparse-checkout
	git pull --depth 1 origin main &>/dev/null
	mkdir -p "$HOME/.pi/agent/extensions"
	cp -r "$TMP_DIR/packages/coding-agent/examples/extensions/plan-mode" "$PM_DIR"
	rm -rf "$TMP_DIR"
fi

cd $HOME
