#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora] Preparando ambiente e clonando o repositório..."

# Pacotes mínimos para clonar e executar
sudo dnf install -y git curl flatpak dnf-plugins-core || true

TARGET_DIR="$HOME/.local/share/ezdora"
# Use HTTPS por padrão para evitar prompt de fingerprint/SSH
REPO_URL="${EZDORA_REPO_URL:-https://github.com/takitani/ezdora.git}"
BRANCH="${EZDORA_BRANCH:-master}"

rm -rf "$TARGET_DIR"
mkdir -p "$(dirname "$TARGET_DIR")"

git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR" || {
  echo "[ezdora] Erro ao clonar $REPO_URL (branch: $BRANCH).\n"
  echo "Sugestões:"
  echo "- Verifique conexão de rede e URL."
  echo "- Para usar SSH (se preferir e já tiver chave configurada): export EZDORA_REPO_URL=git@github.com:takitani/ezdora.git"
  exit 1
}

echo "[ezdora] Iniciando instalação..."
bash "$TARGET_DIR/install.sh"
