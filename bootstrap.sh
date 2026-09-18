#!/usr/bin/env bash
# ==============================================================================
# macOS Minimalist Developer Environment Bootstrapper
# ==============================================================================
# Usage:
#   bash bootstrap.sh [--repo <github-user/dotfiles>]
#
# Or set DOTFILES_REPO env var before running:
#   DOTFILES_REPO=username/dotfiles bash bootstrap.sh
# ==============================================================================

set -euo pipefail

# --- Colors ---
BOLD="$(tput bold 2>/dev/null || true)"
GREEN="$(tput setaf 2 2>/dev/null || true)"
BLUE="$(tput setaf 4 2>/dev/null || true)"
YELLOW="$(tput setaf 3 2>/dev/null || true)"
RED="$(tput setaf 1 2>/dev/null || true)"
RESET="$(tput sgr0 2>/dev/null || true)"

info()    { printf "%s[INFO]%s  %s\n"  "${BLUE}${BOLD}"   "${RESET}" "$*"; }
success() { printf "%s[OK]%s    %s\n"  "${GREEN}${BOLD}"  "${RESET}" "$*"; }
warn()    { printf "%s[WARN]%s  %s\n"  "${YELLOW}${BOLD}" "${RESET}" "$*"; }
error()   { printf "%s[ERROR]%s %s\n"  "${RED}${BOLD}"    "${RESET}" "$*" >&2; }

# --- Argument Parsing ---
DOTFILES_REPO="${DOTFILES_REPO:-}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo)
            DOTFILES_REPO="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--repo <github-user/dotfiles>]"
            echo ""
            echo "Options:"
            echo "  --repo   GitHub repo shorthand for chezmoi (e.g. username/dotfiles)"
            echo "           Alternatively, set the DOTFILES_REPO environment variable."
            exit 0
            ;;
        *)
            error "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# ==============================================================================
# Preflight
# ==============================================================================

info "Starting macOS Minimalist Dev Environment Setup..."

if [[ "$(uname)" != "Darwin" ]]; then
    error "This script targets macOS only."
    exit 1
fi

# 1. Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    warn "Complete the Xcode CLI tools installation dialog, then re-run this script."
    exit 1
else
    success "Xcode Command Line Tools installed."
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is on PATH (handles Apple Silicon + Intel)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

success "Homebrew ready."

# Remove stale taps that no longer exist upstream (causes brew update to fail)
STALE_TAPS=("homebrew/homebrew-cask-fonts" "homebrew/cask-fonts")
for stale in "${STALE_TAPS[@]}"; do
    if brew tap 2>/dev/null | grep -qx "$stale"; then
        warn "Removing stale tap '${stale}'..."
        brew untap "$stale" 2>/dev/null || true
    fi
done

info "Updating Homebrew..."
brew update --quiet

# ==============================================================================
# Helpers
# ==============================================================================

formula_installed() { brew list --formula "$1" &>/dev/null; }
cask_installed()    { brew list --cask    "$1" &>/dev/null; }
tapped()            { brew tap | grep -qx "$1"; }

# ==============================================================================
# Taps
# ==============================================================================

TAPS=(
    "nikitabobko/tap"
)

info "Checking Homebrew taps..."
for tap in "${TAPS[@]}"; do
    if tapped "$tap"; then
        success "Tap '${tap}' already added."
    else
        info "Adding tap '${tap}'..."
        # Homebrew >= 7.0 requires third-party taps to be trusted before they load.
        if brew help trust &>/dev/null; then
            brew trust --tap "$tap" >/dev/null 2>&1 || true
        fi
        brew tap "$tap"
    fi
done

# ==============================================================================
# CLI Formulas
# ==============================================================================

FORMULAS=(
    chezmoi   # Dotfiles manager (manages this repo)
    tmux      # Terminal multiplexer
    neovim    # Modal text editor
    w3m       # Plain-text CLI web browser
    aerc      # TUI email client
    git       # Version control
    ripgrep   # Fast search (rg)
    fd        # Fast find replacement
    fzf       # Fuzzy finder
    jq        # JSON processor
    zoxide    # Smarter cd (z)
)

info "Installing CLI formulas..."
for formula in "${FORMULAS[@]}"; do
    if formula_installed "$formula"; then
        success "'${formula}' already installed."
    else
        info "Installing '${formula}'..."
        brew install "$formula"
    fi
done

# ==============================================================================
# GUI Casks
# ==============================================================================

CASKS=(
    ghostty     # Fast, feature-rich GPU-accelerated terminal emulator
    devpod      # Dev Containers orchestrator
    orbstack    # Fast Docker / Linux VM runtime
    vivaldi     # Privacy-conscious graphical browser
    aerospace   # i3-style tiling window manager for macOS
)

info "Installing GUI casks..."
for cask in "${CASKS[@]}"; do
    if cask_installed "$cask"; then
        success "'${cask}' already installed."
    else
        info "Installing cask '${cask}'..."
        brew install --cask "$cask"
    fi
done

# ==============================================================================
# opencode
# ==============================================================================

if ! command -v opencode &>/dev/null; then
    info "Installing opencode..."
    curl -fsSL https://opencode.ai/install | bash \
        || warn "opencode install failed — install it manually: https://opencode.ai"
else
    success "opencode already installed."
fi

if ! command -v pi &>/dev/null; then
    info "Installing pi code agent..."
    curl -fsSL https://pi.dev/install.sh | sh \
        || warn "pi install failed — install it manually: https://pi.dev"
else
    success "pi already installed."
fi

# ==============================================================================
# Dotfiles via Chezmoi
# ==============================================================================

if [[ -n "$DOTFILES_REPO" ]]; then
    CHEZMOI_SOURCE="$(chezmoi source-path 2>/dev/null || true)"
    if [[ -d "$CHEZMOI_SOURCE" ]]; then
        info "Updating dotfiles..."
        chezmoi update
    else
        info "Initializing dotfiles from '${DOTFILES_REPO}'..."
        chezmoi init --apply "$DOTFILES_REPO"
    fi
    success "Dotfiles applied."
else
    echo ""
    warn "No dotfiles repo specified. Apply your dotfiles with:"
    echo "  chezmoi init --apply https://github.com/<username>/dotfiles"
    echo ""
    echo "  Or re-run this script with:"
    echo "  $0 --repo <username>/dotfiles"
fi

echo ""
success "macOS minimalist environment ready."
