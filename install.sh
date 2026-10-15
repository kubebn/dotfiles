#!/usr/bin/env bash
# install.sh — Mac setup script
# Run this on a fresh Mac to install tools and apply dotfiles configs.
# Usage: bash install.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Starting Mac setup from $DOTFILES_DIR"

# ── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "==> Homebrew already installed"
fi

# ── Brew taps ─────────────────────────────────────────────────────────────────
brew tap hashicorp/tap

# ── Brew tools ────────────────────────────────────────────────────────────────
echo "==> Installing brew packages..."
brew install \
    bat \
    kubectl \
    kubectx \
    k9s \
    kubecolor \
    openshift-cli \
    azure-cli \
    awscli \
    Azure/kubelogin/kubelogin \
    neovim \
    ripgrep \
    lfk \
    mise \
    kustomize \
    kubeconform \
    lexfrei/tap/claudeline \
    fd \
    eza \
    fzf \
    lazygit \
    jq \
    yq \
    crane \
    gh \
    telnet \
    zoxide \
    duti \
    node \
    go \
    tfenv \
    hashicorp/tap/vault

# ── Terraform via tfenv ───────────────────────────────────────────────────────
echo "==> Installing latest Terraform via tfenv..."
tfenv install latest
tfenv use latest

# ── Krew + kubectl plugins ────────────────────────────────────────────────────
if [ ! -f "$HOME/.krew/bin/kubectl-krew" ]; then
    echo "==> Installing krew..."
    (
        set -x; cd "$(mktemp -d)"
        OS="$(uname | tr '[:upper:]' '[:lower:]')"
        ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64$/arm64/')"
        KREW="krew-${OS}_${ARCH}"
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
        tar zxvf "${KREW}.tar.gz"
        ./"${KREW}" install krew
    )
fi
export PATH="$HOME/.krew/bin:$PATH"
kubectl krew install klock view-secret 2>/dev/null || true

# ── Ghostty ───────────────────────────────────────────────────────────────────
if [ ! -d "/Applications/Ghostty.app" ]; then
    echo "==> Installing Ghostty..."
    brew install --cask ghostty
else
    echo "==> Ghostty already installed"
fi

# ── Atuin (shell history sync) ────────────────────────────────────────────────
if ! command -v atuin &>/dev/null && [ ! -f "$HOME/.atuin/bin/atuin" ]; then
    echo "==> Installing Atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    # After install, run: atuin register -u <USERNAME> -e <EMAIL>
    # Then: atuin import auto && atuin sync
else
    echo "==> Atuin already installed"
fi

# ── Zed ───────────────────────────────────────────────────────────────────────
if [ ! -d "/Applications/Zed.app" ]; then
    echo "==> Installing Zed..."
    brew install --cask zed
else
    echo "==> Zed already installed"
fi

# ── Claude Code ───────────────────────────────────────────────────────────────
if ! command -v claude &>/dev/null && [ ! -f "$HOME/.local/bin/claude" ]; then
    echo "==> Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
else
    echo "==> Claude Code already installed"
fi

# ── Zinit (zsh plugin manager) ────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -f "$ZINIT_HOME/zinit.zsh" ]; then
    echo "==> Installing Zinit..."
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
else
    echo "==> Zinit already installed"
fi

# ── Dotfiles: Ghostty ─────────────────────────────────────────────────────────
echo "==> Applying Ghostty config..."
GHOSTTY_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
mkdir -p "$GHOSTTY_CONFIG_DIR"
cp "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_CONFIG_DIR/config"

# ── Dotfiles: Zsh ─────────────────────────────────────────────────────────────
# The orchestrator (zshrc) resolves its own real path and sources conf.d/ + lib/
# from the repo, so only the three entry points need symlinking.
echo "==> Applying Zsh config..."
ln -sf "$DOTFILES_DIR/zsh/zshrc"     "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/zsh/zprofile"  "$HOME/.zprofile"
ln -sf "$DOTFILES_DIR/zsh/p10k.zsh"  "$HOME/.p10k.zsh"
# Clean up symlinks from the old single-file layout (now in conf.d/).
rm -f "$HOME/.config/zsh/aliases.zsh" "$HOME/.config/zsh/functions.zsh"

# ── Dotfiles: Claude Code (skipped if not present in repo) ────────────────────
if [ -d "$DOTFILES_DIR/claude" ]; then
    echo "==> Applying Claude Code config..."
    mkdir -p "$HOME/.claude"
    cp "$DOTFILES_DIR/claude/CLAUDE.md"      "$HOME/.claude/CLAUDE.md"
    cp "$DOTFILES_DIR/claude/settings.json"  "$HOME/.claude/settings.json"
else
    echo "==> No claude/ config in repo — skipping Claude Code config"
fi

# ── Dotfiles: Zed ─────────────────────────────────────────────────────────────
echo "==> Applying Zed settings..."
mkdir -p "$HOME/.config/zed"
cp "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"

# ── Corporate CA cert → az CLI certifi bundle (skipped if cert absent) ────────
# certs/ is gitignored and only exists on work machines; personal machines skip this.
if [ -f "$DOTFILES_DIR/certs/corporate-ca.pem" ]; then
    echo "==> Injecting corporate CA into az CLI..."
    CERTIFI="$(brew --prefix azure-cli)/libexec/lib/python3.13/site-packages/certifi/cacert.pem"
    if [ -f "$CERTIFI" ] && ! grep -q "Emirates/Zscaler" "$CERTIFI"; then
        echo "" >> "$CERTIFI"
        echo "# corporate CA — added for az CLI" >> "$CERTIFI"
        cat "$DOTFILES_DIR/certs/corporate-ca.pem" >> "$CERTIFI"
    fi
else
    echo "==> No corporate CA cert found — skipping az CLI cert injection"
fi

# ── Dotfiles: SSH ─────────────────────────────────────────────────────────────
echo "==> Applying SSH config..."
mkdir -p "$HOME/.ssh/sockets"
chmod 700 "$HOME/.ssh"
cp "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
chmod 600 "$HOME/.ssh/config"

# ── Dotfiles: Atuin ───────────────────────────────────────────────────────────
echo "==> Applying Atuin config..."
mkdir -p "$HOME/.config/atuin"
cp "$DOTFILES_DIR/atuin/config.toml" "$HOME/.config/atuin/config.toml"
# After install: atuin login -u <USERNAME> && atuin import auto && atuin sync

# ── Dotfiles: Neovim ──────────────────────────────────────────────────────────
echo "==> Applying Neovim config..."
mkdir -p "$HOME/.config/nvim"
cp -r "$DOTFILES_DIR/nvim/"* "$HOME/.config/nvim/"

# ── Set Zsh as default shell ──────────────────────────────────────────────────
ZSH_PATH="/bin/zsh"
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "==> Setting Zsh as default shell..."
    sudo chsh -s "$ZSH_PATH"
else
    echo "==> Zsh is already the default shell"
fi

echo ""
echo "==> Done! Restart Ghostty to apply everything."
