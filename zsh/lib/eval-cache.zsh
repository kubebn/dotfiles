# lib/eval-cache.zsh
# Cache the output of slow `tool init` commands (zoxide/mise/atuin/fzf) to a
# file and source that instead of spawning the tool on every startup. The cache
# is regenerated only when the tool binary is newer than the cached file.

ZSH_EVAL_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-eval-cache"
[[ -d "$ZSH_EVAL_CACHE_DIR" ]] || mkdir -p "$ZSH_EVAL_CACHE_DIR"

# Usage: _eval_cache <name> '<init command>'
#   <name> must match the binary name (used for cache key and freshness check).
_eval_cache() {
  local name="$1" cmd="$2"
  local cache_file="$ZSH_EVAL_CACHE_DIR/${name}.zsh"
  local binary="$commands[$name]"

  # Tool not installed — nothing to do.
  [[ -z "$binary" ]] && return

  # (Re)generate the cache if missing or the binary was updated.
  if [[ ! -e "$cache_file" || "$binary" -nt "$cache_file" ]]; then
    local tmp="${cache_file}.$$"
    if eval "$cmd" >| "$tmp" 2>/dev/null; then
      mv -f "$tmp" "$cache_file"
      zcompile "$cache_file" &!
    else
      rm -f "$tmp"
      print -u2 "eval-cache: '$cmd' failed; skipping $name"
      return 1
    fi
  fi

  source "$cache_file"
}
