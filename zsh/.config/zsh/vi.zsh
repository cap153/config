# -----------------------------------------------------------------
# Zsh Vi Mode (vi-mode)
# -----------------------------------------------------------------

# Enable Vi mode
bindkey -v

# --- Custom Keybindings ---

# Fix Backspace key in vi-insert mode. This is a common issue.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

# IMPORTANT: Bindings for navigation should apply to BOTH
# command mode (vicmd) and visual mode (visual).

# -- Insert Mode Triggers --
# 'k' enters insert mode at the cursor
bindkey -M vicmd "k" vi-insert
# 'K' enters insert mode at the beginning of the line
bindkey -M vicmd "K" vi-insert-bol

# -- Navigation (for both vicmd and visual mode) --
# Remap 'n' and 'i' for left/right character movement
bindkey -M vicmd  "n" vi-backward-char
bindkey -M visual "n" vi-backward-char

bindkey -M vicmd  "i" vi-forward-char
bindkey -M visual "i" vi-forward-char

# Remap 'N' and 'I' for beginning/end of line
bindkey -M vicmd  "N" vi-beginning-of-line
bindkey -M visual "N" vi-beginning-of-line

bindkey -M vicmd  "I" vi-end-of-line
bindkey -M visual "I" vi-end-of-line
bindkey -M vicmd  "S" vi-end-of-line
bindkey -M visual "S" vi-end-of-line

# Remap 'e' and 'u' for line/history navigation
bindkey -M vicmd "e" down-line-or-history
bindkey -M vicmd "u" up-line-or-history

# Remap 'h' for forward word end
bindkey -M vicmd  "h" vi-forward-word-end
bindkey -M visual "h" vi-forward-word-end

# -- Other Bindings --
bindkey -M vicmd "l" undo
bindkey -M vicmd "=" vi-repeat-search
#bindkey -M vicmd "-" vi-rev-repeat-search

# Set a short timeout for ambiguous key sequences
KEYTIMEOUT=1

# 解绑 visual 和 viopp 模式下的 k
bindkey -M visual -r "k"
bindkey -M viopp -r "k"

# 加载选择引号的函数
autoload -U select-quoted
zle -N select-quoted

# 加载选择括号的函数
autoload -U select-bracketed
zle -N select-bracketed

# “选择内部单词”的函数 (Inner Word)
vi-select-inner-word() {
  # 记录原始位置，防止在行首/行尾越界
  local save_cursor=$CURSOR
  # 先向后移一个字符再执行结尾跳转，确保光标在单词开头时也能准确选中当前单词
  zle vi-backward-char
  zle vi-forward-word-end
  local end=$CURSOR
  # 先向前移一个字符再执行开头跳转，确保光标在单词结尾时不会跳到下一个单词
  zle vi-forward-char
  zle vi-backward-word
  local start=$CURSOR
  # 设置选区
  CURSOR=$start
  MARK=$end
  # 关键：只有当可视模式未开启时才开启它，防止 Toggle 导致退出
  if (( ! REGION_ACTIVE )); then
    zle visual-mode
  fi
}
zle -N vi-select-inner-word

# “选择整个单词”的函数 (Around Word - 包含空格)
vi-select-around-word() {
  zle vi-forward-word
  local end=$((CURSOR - 1))
  zle vi-backward-word
  MARK=$end
  if (( ! REGION_ACTIVE )); then
    zle visual-mode
  fi
}
zle -N vi-select-around-word

for m in visual viopp; do
# 涵盖引号: k" , k' , k`
  for c in {k,a}{\',\",\`}; do
    bindkey -M $m "$c" select-quoted
  done
# 涵盖括号: k( , k[ , k{ , k< 等
  for c in {k,a}{\(,\),\[,\],\{,\},\<,\>}; do
    bindkey -M $m "$c" select-bracketed
  done
  bindkey -M $m "kw" vi-select-inner-word
  bindkey -M $m "aw" vi-select-around-word
done


# -----------------------------------------------------------------
# Cursor Shape Control (The Best Practice)
# -----------------------------------------------------------------

# 改变光标形状的辅助函数
function _set_cursor_shape() {
  case $1 in
    block) echo -ne "\e[1 q" ;; # 方块
    beam)  echo -ne "\e[5 q" ;; # 竖线
  esac
}

# 监听模式切换
function zle-keymap-select() {
  if [[ ${KEYMAP} == vicmd ]]; then
    _set_cursor_shape block
  else
    _set_cursor_shape beam
  fi
}
zle -N zle-keymap-select

# 监听行初始化（进入命令行时）
function zle-line-init() {
  _set_cursor_shape beam
}
zle -N zle-line-init

# 确保在命令结束后光标恢复为竖线
# 有些终端在运行完 ls 等命令后会重置光标，这里可以强制重置
preexec() {
  _set_cursor_shape beam
}
