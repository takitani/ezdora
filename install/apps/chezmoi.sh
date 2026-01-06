#!/usr/bin/env bash
set -euo pipefail

# chezmoi - Manage your dotfiles across multiple machines
# https://www.chezmoi.io/
#
# After install, initialize with:
#   chezmoi init --apply <github-username>
# Or create new:
#   chezmoi init
#   chezmoi add ~/.gitconfig ~/.tmux.conf ~/.config/kitty
#   chezmoi cd && git remote add origin <repo> && git push

if command -v chezmoi >/dev/null 2>&1; then
    echo "[ezdora] chezmoi already installed, skipping."
    exit 0
fi

echo "[ezdora] Installing chezmoi..."

# Install via official script to ~/.local/bin
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"

echo "[ezdora] chezmoi installed to ~/.local/bin/chezmoi"
echo ""
echo "[ezdora] Next steps:"
echo "  1. Initialize: chezmoi init"
echo "  2. Add configs: chezmoi add ~/.gitconfig ~/.tmux.conf"
echo "  3. Push to repo: chezmoi cd && git init && git remote add origin <repo>"
