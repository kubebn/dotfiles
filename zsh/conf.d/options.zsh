# conf.d/options.zsh — history, shell options, completion styling.

# History.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS EXTENDED_HISTORY

# Shell options.
setopt AUTO_CD NO_BEEP GLOB_DOTS

# Completion styling.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'l:|=* r:|=*'   # case-insensitive + substring
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '[%d]'        # group support in fzf-tab
zstyle ':completion:*' menu select

# fzf-tab — preview directory contents with eza (matches both reference configs;
# falls back silently if eza isn't installed).
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always -- "$realpath" 2>/dev/null'
zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always -- "$realpath" 2>/dev/null'
zstyle ':fzf-tab:*' switch-group '<' '>'
