# conf.d/keybinds.zsh — key bindings.

# Shift+Enter: Ghostty sends extended key sequences zsh doesn't handle by
# default; bind them to accept-line.
bindkey "^[[27;2;13~" accept-line
bindkey "^[[13;2u" accept-line
