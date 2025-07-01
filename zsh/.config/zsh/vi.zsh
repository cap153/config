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

# -----------------------------------------------------------------
# Cursor Shape Control (The Best Practice)
# -----------------------------------------------------------------

# This function automatically runs when the keymap changes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    # Block cursor for command mode
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ $1 = 'beam' ]]; then
    # Beam (I-bar) cursor for insert mode
    echo -ne '\e[5 q'
  fi
}
# Register the function to run on keymap changes
zle -N zle-keymap-select

# Set the initial cursor to beam shape on startup
echo -ne '\e[5 q'
