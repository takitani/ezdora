#!/usr/bin/env bash
set -euo pipefail

if command -v mise >/dev/null 2>&1; then
  exit 0
fi

echo "[ezdora][mise] Instalando mise via script oficial..."
curl -fsSL https://mise.jdx.dev/install.sh | sh
echo "[ezdora][mise] Concluído. Reinicie o shell para ativar ('~/.local/bin' no PATH)."

