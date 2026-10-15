# conf.d/tools.zsh — external tool integrations.
# Each init command is cached via _eval_cache (lib/eval-cache.zsh) so the tool
# is only spawned when its binary changes, not on every shell start.

# Zoxide — smart cd ('z' to jump, 'cd' stays native).
_eval_cache zoxide 'zoxide init zsh'

# Mise — runtime version manager.
_eval_cache mise 'mise activate zsh'

# fzf — fuzzy finder key bindings and completion.
_eval_cache fzf 'fzf --zsh'

# Atuin — shell history (Ctrl+R fuzzy search; up arrow stays plain history).
[[ -f "$HOME/.atuin/bin/env" ]] && source "$HOME/.atuin/bin/env"
_eval_cache atuin 'atuin init zsh --disable-up-arrow'
