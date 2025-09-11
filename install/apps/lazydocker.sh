#!/usr/bin/env bash
set -euo pipefail

if command -v lazydocker >/dev/null 2>&1; then
  echo "[ezdora][lazydocker] Já instalado. Pulando."
  exit 0
fi

echo "[ezdora][lazydocker] Instalando..."

# Tenta via DNF primeiro
if ! sudo dnf install -y lazydocker; then
  echo "[ezdora][lazydocker] Não encontrado no DNF. Usando script oficial."
  curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
fi

echo "[ezdora][lazydocker] Concluído. Executar com 'lazydocker'."

