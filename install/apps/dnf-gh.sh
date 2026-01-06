#!/usr/bin/env bash
set -euo pipefail

# GitHub CLI - essential for git workflow and PR management
# https://cli.github.com/

if command -v gh >/dev/null 2>&1; then
    echo "[ezdora] gh (GitHub CLI) already installed, skipping."
    exit 0
fi

echo "[ezdora] Installing gh (GitHub CLI)..."
sudo dnf install -y gh

echo "[ezdora] gh installed successfully."
echo "[ezdora] Run 'gh auth login' to authenticate with GitHub."
