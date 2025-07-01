export PLUG_DIR=$HOME/.zim
if [[ ! -d $PLUG_DIR ]]; then
	curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
	cd ~/.dotfiles/zsh
	git restore .zimrc 
	git restore .zshrc
fi
