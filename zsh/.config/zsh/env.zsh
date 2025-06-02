# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# export LANG=zh_CN.UTF-8
# export LANGUAGE=zh_CN:en_US

# 配置终端代理
# export ALL_PROXY=http://127.0.0.1:7897

# 使用本的的ollama模型Set LLM_KEY to NONE
export LLM_KEY=NONE

export OPENROUTER_API_KEY="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"
export DEEPSEEK_API_KEY="sk-975bb76438d1453db1d664041f7caf07"

# skip the verification of insecure directories
export ZSH_DISABLE_COMPFIX=true

# 解决cursor使用rust出现"unknown proxy name: 'Cursor'
# https://github.com/getcursor/cursor/issues/549
[[ "$TERM_PROGRAM" == "vscode" ]] && unset ARGV0
# fish添加如下环境变量
# string match -q "$TERM_PROGRAM" "vscode"
# and unset ARGV0

# 正确启动ide
# export _JAVA_AWT_WM_NONREPARENTING=1

# 修改shell配置文件 ~/.bashrc ~/.zshrc等
# export http_proxy=socks5://127.0.0.1:10086
# export https_proxy=$http_proxy

# 树莓派远程连接终端临时生效方法
# export TERM=vt100

# pyenv install -v 3.8 # 安装指定版本python
# pyenv versions # 查看已经安装的python版本
# 自动载入pyenv，启用后可以使用pyenv global 3.8来在终端切换指定的python版本
# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

# joshuto批量重命名默认编辑器设置为nvim
export EDITOR=nvim

# 禁用桌面剪贴板同步,解决system-clipboard两秒窃取一次焦点
export CLIPBOARD_NOGUI=1

# windows下设置环境变量
# set OLLAMA_HOST=0.0.0.0

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="gentoo"


