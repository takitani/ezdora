#!/usr/bin/env bash
set -euo pipefail

# Skip if already installed (regardless of package manager)
if command -v starship >/dev/null 2>&1; then
  echo "[ezdora][starship] Já instalado. Pulando."
  exit 0
fi

# Ensure ~/.local/bin exists and is in PATH
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# Try DNF first (if sudo available without password)
if sudo -n true 2>/dev/null; then
  echo "[ezdora][starship] Tentando instalar via DNF..."
  if sudo dnf install -y starship 2>/dev/null; then
    echo "[ezdora][starship] Instalado via DNF."
    exit 0
  fi
fi

# Fallback: install to ~/.local/bin (no sudo needed)
echo "[ezdora][starship] Instalando via script oficial em ~/.local/bin..."
curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" || {
  echo "[ezdora][starship] Falha ao instalar starship." >&2
  exit 1
}

echo "[ezdora][starship] Instalado em ~/.local/bin/starship"
