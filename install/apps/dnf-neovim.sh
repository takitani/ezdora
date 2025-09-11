#!/usr/bin/env bash
set -euo pipefail

if command -v nvim >/dev/null 2>&1; then
  echo "[ezdora][neovim] Já instalado. Pulando DNF."
else
  echo "[ezdora][neovim] Instalando Neovim e bindings Python..."
  sudo dnf install -y neovim python3-neovim || {
    echo "[ezdora][neovim] Falha no DNF para neovim/python3-neovim" >&2
    exit 1
  }
fi

# Extras úteis (sem falhar se indisponível)
sudo dnf install -y luarocks || true

# tree-sitter-cli ajuda no :checkhealth do LazyVim. Tenta DNF, senão npm.
if ! command -v tree-sitter >/dev/null 2>&1; then
  sudo dnf install -y tree-sitter-cli tree-sitter || true
  if ! command -v tree-sitter >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    npm install -g tree-sitter-cli || true
  fi
fi

