#!/usr/bin/env bash
set -euo pipefail

# Skip if already installed (regardless of package manager)
if command -v starship >/dev/null 2>&1; then
  echo "[ezdora][starship] Já instalado. Pulando."
  exit 0
fi

# Try DNF first
echo "[ezdora][starship] Tentando instalar via DNF..."
if ! sudo dnf install -y starship; then
  echo "[ezdora][starship] Pacote não encontrado no DNF. Instalando via script oficial..."
  # Install to /usr/local/bin non-interactively
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y || {
    echo "[ezdora][starship] Falha ao instalar starship via script oficial." >&2
    exit 1
  }
fi
