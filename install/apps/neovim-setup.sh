#!/usr/bin/env bash
set -euo pipefail

# Configure Neovim similar to Omakub: use LazyVim starter if no config exists

if [ -d "$HOME/.config/nvim" ]; then
  echo "[ezdora][neovim] Configuração existente detectada em ~/.config/nvim. Pulando starter."
  exit 0
fi

echo "[ezdora][neovim] Aplicando configuração inicial (LazyVim starter)..."

git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
rm -rf "$HOME/.config/nvim/.git"

# Ajustes simples: desativar relative number como no Omakub
mkdir -p "$HOME/.config/nvim/lua/config"
echo 'vim.opt.relativenumber = false' >> "$HOME/.config/nvim/lua/config/options.lua"

echo "[ezdora][neovim] Pronto. Abra o Neovim para concluir a instalação dos plugins."

