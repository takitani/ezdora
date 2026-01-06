#!/usr/bin/env bash
set -euo pipefail

# fd - A simple, fast and user-friendly alternative to 'find'
# https://github.com/sharkdp/fd
# Works great with fzf for fuzzy file finding

if command -v fd >/dev/null 2>&1; then
    echo "[ezdora] fd already installed, skipping."
    exit 0
fi

echo "[ezdora] Installing fd (fd-find)..."
sudo dnf install -y fd-find

echo "[ezdora] fd installed successfully."
