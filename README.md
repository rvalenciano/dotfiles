# dotfiles

Minimalist macOS developer environment managed with [chezmoi](https://www.chezmoi.io/).

## One-command bootstrap

On a fresh macOS machine, run:

```bash
curl -fsSL https://raw.githubusercontent.com/<username>/dotfiles/main/bootstrap.sh \
    | bash -s -- --repo <username>/dotfiles
```

Or clone and run locally:

```bash
git clone https://github.com/<username>/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
bash bootstrap.sh --repo <username>/dotfiles
```

## What gets installed

| Tool | Purpose |
|---|---|
| [chezmoi](https://chezmoi.io) | Dotfiles manager |
| [neovim](https://neovim.io) + LazyVim | Modal text editor |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| [ghostty](https://ghostty.org) | Fast, GPU-accelerated terminal |
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | i3-style tiling WM for macOS |
| [aerc](https://aerc-mail.org) | TUI email client |
| [DevPod](https://devpod.sh) + [OrbStack](https://orbstack.dev) | Dev Containers workflow |
| [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd), [fzf](https://github.com/junegunn/fzf), [zoxide](https://github.com/ajeetdsouza/zoxide) | CLI productivity |
| [w3m](https://w3m.sourceforge.net) | Plain-text browser |
| [Claude Code](https://claude.ai/code) | AI coding assistant |

## Structure

```
dotfiles/
├── bootstrap.sh            # One-shot macOS setup script
├── dot_zshrc               # → ~/.zshrc
├── dot_config/
│   ├── ghostty/
│   │   └── config          # → ~/.config/ghostty/config
│   ├── tmux/
│   │   └── tmux.conf       # → ~/.config/tmux/tmux.conf
│   ├── aerospace/
│   │   └── aerospace.toml  # → ~/.config/aerospace/aerospace.toml
│   ├── nvim/               # → ~/.config/nvim/ (LazyVim)
│   │   ├── init.lua
│   │   └── lua/plugins/
│   └── aerc/
│       └── binds.conf      # → ~/.config/aerc/binds.conf
├── dot_local/
│   └── bin/                # → ~/.local/bin/ (on $PATH)
│       ├── executable_fabric-query
│       ├── executable_ddg-w3m
│       └── executable_zk
└── .devcontainer/
    └── devcontainer.json   # Default Dev Container template
```

## Managing dotfiles

```bash
# Edit a file
chezmoi edit ~/.zshrc

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Add a new file
chezmoi add ~/.config/foo/bar.conf

# Push changes to git
chezmoi cd && git add -A && git commit -m "..." && git push
```

## Local overrides

Machine-specific settings that should **not** be tracked:

- `~/.zshrc.local` — sourced at the end of `.zshrc`
