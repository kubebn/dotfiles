# dotfiles

My macOS setup: zsh, Neovim, Ghostty, and the CLI tools I lean on for Kubernetes and cloud work.

## What's here

- `zsh/` — modular zsh config on Powerlevel10k, ~0.11s to prompt. Details in [zsh/README.md](zsh/README.md).
- `nvim/` — Neovim, managed with lazy.nvim.
- `ghostty/` — terminal config.
- `atuin/` — shell history sync settings.
- `ssh/` — client defaults (connection reuse, keepalives).
- `vscode/`, `zed/` — editor settings.
- `install.sh` — installs everything via Homebrew and symlinks the configs.

## Install

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

Re-running it is fine. Missing tools get installed, anything already set up is left alone.