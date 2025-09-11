#!/usr/bin/env bash
set -euo pipefail

# Ensure mise is installed
if ! command -v mise >/dev/null 2>&1; then
  echo "[ezdora][mise] mise não encontrado; instalando..."
  bash "$(dirname "$0")/mise.sh"
fi

echo "[ezdora][mise] Instalando e configurando ferramentas globais..."
export MISE_YES=1

# Install Node (includes npm) latest and .NET 9 globally
mise use -g node@latest dotnet@9 || true

# Reshim to ensure shims are up-to-date
mise reshim || true

echo "[ezdora][mise] Concluído. Ative o shell: 'eval \"$(mise activate zsh)\"' (já adicionado ao .zshrc)."

