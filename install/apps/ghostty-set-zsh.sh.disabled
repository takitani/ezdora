#!/usr/bin/env bash
set -euo pipefail

# Force Ghostty to launch with zsh right away (no need to relogin)

ZSH_PATH="$(command -v zsh || true)"
if [ -z "$ZSH_PATH" ]; then
  echo "[ezdora][ghostty] zsh não encontrado; pulando configuração de 'command'."
  exit 0
fi

CFG_DIR="$HOME/.config/ghostty"
CFG_FILE="$CFG_DIR/config"
mkdir -p "$CFG_DIR"

if [ -f "$CFG_FILE" ] && grep -q '^command\s*=\s*' "$CFG_FILE"; then
  # Update existing command to zsh
  sed -i "s|^command\s*=.*|command = \"$ZSH_PATH\"|" "$CFG_FILE"
else
  echo "command = \"$ZSH_PATH\"" >> "$CFG_FILE"
fi

echo "[ezdora][ghostty] 'command' configurado para: $ZSH_PATH"

