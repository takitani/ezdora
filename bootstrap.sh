#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora] Preparando ambiente e clonando o repositório..."

# Pacotes mínimos para clonar e executar
sudo dnf install -y git curl flatpak dnf-plugins-core || true

TARGET_DIR="$HOME/.local/share/ezdora"
# Repositório público (HTTPS fixo)
REPO_URL="https://github.com/takitani/ezdora.git"
BRANCH="master"

rm -rf "$TARGET_DIR"
mkdir -p "$(dirname "$TARGET_DIR")"

git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR" || {
  echo "[ezdora] Erro ao clonar $REPO_URL (branch: $BRANCH). Verifique a conexão de rede e tente novamente."
  exit 1
}

echo "[ezdora] Iniciando instalação..."
bash "$TARGET_DIR/install.sh"
