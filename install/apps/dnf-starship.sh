#!/usr/bin/env bash
set -euo pipefail

if rpm -q starship >/dev/null 2>&1; then
  exit 0
fi

echo "[ezdora][starship] Tentando instalar via DNF..."
if ! sudo dnf install -y starship; then
  echo "[ezdora][starship] Pacote não encontrado no DNF. Instalando via script oficial..."
  # Instala sem prompts (-y). Não altera configuração do shell por padrão.
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y || {
    echo "[ezdora][starship] Falha ao instalar starship via script oficial." >&2
    exit 1
  }
fi
