# conf.d/aliases.zsh — command aliases.

# ── kubectl / kubecolor ───────────────────────────────────────────────────────
alias kubectl=kubecolor
alias k=kubecolor

# Context & namespace switching
alias kctx=kubectx
alias kns=kubens
alias kcc='kubectl config current-context'
alias kcgc='kubectl config get-contexts'

# Get
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgpw='kubectl get pods -w'
alias kgpwide='kubectl get pods -o wide'
alias kgd='kubectl get deployment'
alias kgds='kubectl get daemonset'
alias kgss='kubectl get statefulset'
alias kgs='kubectl get svc'
alias kgi='kubectl get ingress'
alias kgcm='kubectl get configmaps'
alias kgsec='kubectl get secret'
alias kgpvc='kubectl get pvc'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kgj='kubectl get job'
alias kga='kubectl get all'
alias kgaa='kubectl get all -A'

# Describe
alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe svc'
alias kdno='kubectl describe node'
alias kdsec='kubectl describe secret'
alias kdcm='kubectl describe configmap'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'

# Exec
alias keti='kubectl exec -ti'

# Apply / delete
alias kaf='kubectl apply -f'
alias kdelf='kubectl delete -f'
alias kdel='kubectl delete'
alias kdelp='kubectl delete pod'
alias kdeld='kubectl delete deployment'

# Port forward
alias kpf='kubectl port-forward'

# Rollout
alias krsd='kubectl rollout status deployment'
alias krss='kubectl rollout status statefulset'
alias kru='kubectl rollout undo'
alias krh='kubectl rollout history'

# Scale
alias ksd='kubectl scale deployment'

# krew plugins
alias klock='kubectl klock'
alias kk='kubectl klock'
alias ksec='kubectl view-secret'

# ── Git ───────────────────────────────────────────────────────────────────────
alias g='git'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -m'
alias gca='git commit --amend --no-edit'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git --no-pager diff'
alias gds='git --no-pager diff --staged'
alias gs='git status -sb'
alias gl='git --no-pager log --oneline --graph --decorate -20'
alias gla='git --no-pager log --oneline --graph --decorate --all -20'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias grb='git rebase'
alias grbi='git rebase -i'
alias gst='git stash'
alias gstp='git stash pop'
alias gsts='git stash show -p'
alias gcp='git cherry-pick'
alias gbr='git branch'
alias gbrd='git branch -d'
alias gbrD='git branch -D'
alias gtag='git tag'
alias gfetch='git fetch --all --prune'

# ── General tools ─────────────────────────────────────────────────────────────
# eza replaces ls (used by both reference configs); falls back to BSD ls.
if (( $+commands[eza] )); then
  alias ls='eza --icons --group-directories-first --git'
  alias ll='eza -l --icons --git --group-directories-first'
  alias la='eza -la --icons --git --group-directories-first'
  alias lt='eza --tree --level=2 --icons'
else
  alias ls='ls -G'           # colorized output on macOS
  alias ll='ls -G -lh'       # long listing with human-readable sizes
  alias la='ls -G -lha'      # long listing including hidden files
fi
alias cat='bat --theme="Catppuccin Mocha"'
alias catt='bat -pp'
alias lg=lazygit

# ── Maintenance ───────────────────────────────────────────────────────────────
alias reload='exec zsh'
alias zup='zinit self-update && zinit update --parallel'
