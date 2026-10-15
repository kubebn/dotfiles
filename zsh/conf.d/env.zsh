# conf.d/env.zsh — PATH and environment. Sourced first, before the instant
# prompt, so it must not produce any output.

# Homebrew (early for correct PATH).
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# OrbStack integration (output suppressed so it doesn't break instant prompt).
[[ -f ~/.orbstack/shell/init.zsh ]] && source ~/.orbstack/shell/init.zsh 2>/dev/null

# PATH.
path=(
  "$HOME/.local/bin"
  "$HOME/.atuin/bin"
  "$HOME/.krew/bin"
  "$HOME/.orbstack/bin"
  "$HOME/go/bin"
  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $path
)
typeset -U path

# Environment.
export EDITOR=nvim
export KUBECOLOR_KUBECTL_BINARY="/opt/homebrew/bin/kubectl"
export NODE_TLS_REJECT_UNAUTHORIZED="0"

# Corporate CA trust for Python tooling behind the TLS-intercepting
# proxy. Bundle = certifi public roots + the ROOT-CA
# intermediate, so httpx/requests/pip (incl. the headroom proxy) verify
# upstream TLS instead of failing with "self-signed certificate in chain".
if [[ -r "$HOME/headroom/ca-bundle-with-corp.pem" ]]; then
  export SSL_CERT_FILE="$HOME/headroom/ca-bundle-with-corp.pem"
  export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
fi
export CLICOLOR=1                        # enable ls colors on macOS
export LSCOLORS=ExGxFxDxCxegedabagacad   # macOS ls color scheme
