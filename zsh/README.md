# Zsh Configuration

Modern, fast, modular zsh setup with Powerlevel10k, optimized for DevOps workflows.

## Features

- **Powerlevel10k** — fast prompt with instant-prompt support
- **Zinit (turbo mode)** — non-essential plugins deferred until after the first prompt
- **Eval-cache** — `zoxide`/`mise`/`atuin`/`fzf` init output cached; tools only re-run when their binary changes
- **Byte-compilation** — config files compiled to `.zwc` bytecode in the background
- **Modular `conf.d/`** — clean separation of env, plugins, options, tools, keybinds, aliases, functions
- **DevOps-focused** — 100+ kubectl aliases, AWS helpers, git shortcuts, jq-based cluster utilities
- **~0.11s time-to-prompt** (down from ~0.22s on the previous single-file layout)

## Structure

```
zsh/
├── zshrc              # orchestrator — controls load order (symlinked to ~/.zshrc)
├── zprofile           # login shell setup (symlinked to ~/.zprofile, minimal)
├── p10k.zsh           # Powerlevel10k theme config (symlinked to ~/.p10k.zsh)
├── lib/
│   └── eval-cache.zsh # caches slow `tool init` output
└── conf.d/
    ├── env.zsh        # PATH, brew, OrbStack, exports (runs before instant prompt)
    ├── plugins.zsh    # Zinit + p10k (eager) + turbo-deferred plugins + compinit
    ├── options.zsh    # history, setopt, completion/fzf-tab styling
    ├── tools.zsh      # zoxide / mise / atuin / fzf (via eval-cache)
    ├── keybinds.zsh   # Ghostty Shift+Enter bindings
    ├── aliases.zsh    # kubectl, git, tools
    └── functions.zsh  # kubectl helpers, AWS utils, git
```

The orchestrator resolves its own real path (`${${(%):-%x}:A:h}`), so even though
`~/.zshrc` is a symlink it sources `conf.d/` and `lib/` directly from the repo —
no per-file symlinks needed.

## Load Order

1. **`conf.d/env.zsh`** — PATH/brew/OrbStack/exports (must run before any output)
2. **p10k instant prompt** — renders the prompt before init finishes
3. **`lib/eval-cache.zsh`** — defines the init-output cache helper
4. **`conf.d/{plugins,options,tools,keybinds,aliases,functions}.zsh`** — in order
5. **`p10k.zsh`** — theme config
6. **`~/.zshrc.local`** — machine-specific/private overrides (not tracked)
7. **Background `zcompile`** — byte-compiles changed config files

## Plugins

Loaded via Zinit:

1. **romkatv/powerlevel10k** — eager (instant prompt needs it early)
2. **Aloxaf/fzf-tab** — turbo, after compinit
3. **zdharma-continuum/fast-syntax-highlighting** — turbo
4. **zsh-users/zsh-autosuggestions** — turbo

Plugins 2–4 load in `wait lucid` turbo mode: deferred until just after the first
prompt is drawn, so they never block time-to-prompt.

## Key Bindings

- `Ctrl+R` — Atuin fuzzy history search
- `↑/↓` — plain history navigation
- `Shift+Enter` — accept line (Ghostty extended keys)

## Aliases Highlights

### Kubectl
```zsh
k, kubectl          # kubecolor wrapper
kgp, kgpa, kgpw     # get pods (all, watch)
kl, klf             # logs, logs -f
keti                # exec -ti
kctx, kns           # context/namespace switching
```

### Git
```zsh
g, ga, gc           # git, add, commit
gd, gds             # diff, diff --staged
gs, gl              # status, log
gp, gpf             # push, force-with-lease
```

### Tools
```zsh
ls, ll, la, lt      # eza (icons + git), falls back to ls -G
cat                 # bat with Catppuccin theme
lg                  # lazygit
reload              # exec zsh
zup                 # zinit self-update && update --parallel
```

## Functions Highlights

### Kubectl Utilities
- `kpods_restarts_ks` — pods sorted by restart count
- `kpods_running_all` — all running pods with IPs
- `kpods_top_mem` — top 5 pods by memory request
- `kevents_warnings` — warning events cluster-wide
- `kclean_evicted` — delete all Evicted pods
- `ktopn`, `ktopp` — node/pod resource usage sorted

### AWS
- `aws-paste` — parse AWS console creds from clipboard

### Git
- `gacp "msg"` — add all, commit, push in one command
- `gacp "msg" -f` — same with force push

### Kubectl Config
- `kuse` — pick kubeconfig from ~/Downloads with fzf
- `kuoff` — unset KUBECONFIG

## Performance

- **Time-to-prompt**: ~0.11s (7-run average)
- **Optimizations**:
  - p10k instant prompt (renders prompt before full init)
  - Zinit turbo mode (non-essential plugins load after first prompt)
  - eval-cache (zoxide/mise/atuin/fzf init cached; regenerated only when binary changes)
  - background `zcompile` of all config files and the completion dump

## Troubleshooting

### p10k not loading
```zsh
rm -f ~/.cache/p10k-instant-prompt-*.zsh*
exec zsh
```

### Slow startup / profiling
```zsh
time zsh -i -c exit
zsh -xv 2>&1 | ts -i '%.s' | tee /tmp/zsh-profile.log
```

### Stale tool init (after upgrading zoxide/mise/atuin/fzf)
The cache auto-refreshes when the binary is newer, but to force it:
```zsh
rm -rf ~/.cache/zsh-eval-cache && exec zsh
```

### Plugin issues
```zsh
zinit update --all
rm -rf ~/.local/share/zinit   # then restart (Zinit auto-installs)
```

## Installation

Handled by `install.sh` in the parent directory:

```bash
cd ~/dotfiles
./install.sh
```

Symlinks created:
- `~/.zshrc` → `~/dotfiles/zsh/zshrc`
- `~/.zprofile` → `~/dotfiles/zsh/zprofile`
- `~/.p10k.zsh` → `~/dotfiles/zsh/p10k.zsh`

`conf.d/` and `lib/` are resolved from the repo by the orchestrator — they are not symlinked.

## Customization

### Change prompt style
```zsh
p10k configure
```

### Add aliases / functions
Edit `conf.d/aliases.zsh` or `conf.d/functions.zsh` — changes apply on next shell (symlinked entry point).

### Machine-specific / private overrides
Put untracked settings (work secrets, host-specific paths) in `~/.zshrc.local` — it is auto-sourced last.

### Modify PATH
Edit the `path=()` array in `conf.d/env.zsh`.

## References

- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Zinit](https://github.com/zdharma-continuum/zinit)
- [zsh startup files order](http://zsh.sourceforge.net/Intro/intro_3.html)
