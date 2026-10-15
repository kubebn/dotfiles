# conf.d/plugins.zsh — Zinit plugin manager and plugins.
#
# Speed strategy (from both reference configs):
#   - p10k loads eagerly (the instant prompt needs it as early as possible).
#   - Everything else loads in turbo mode (`wait lucid`), i.e. deferred until
#     after the first prompt is drawn, so it never blocks time-to-prompt.

# Bootstrap Zinit if missing.
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Powerlevel10k — eager (instant prompt requires it early).
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Turbo-loaded interactive plugins.
# Order matters: compinit -> fzf-tab -> syntax-highlighting -> autosuggestions.
# atinit runs compinit; atload byte-compiles the completion dump for faster
# subsequent startups.
zinit wait lucid \
  atinit"zicompinit; zicdreplay" \
  atload'compdump="${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}";
         [[ ! -s "${compdump}.zwc" || "$compdump" -nt "${compdump}.zwc" ]] && zcompile "$compdump" &!' \
  for Aloxaf/fzf-tab \
      zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions
