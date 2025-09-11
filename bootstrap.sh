#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora] Preparando ambiente e clonando o repositório..."

# Pacotes mínimos para clonar e executar
sudo dnf install -y git curl flatpak || true

TARGET_DIR="$HOME/.local/share/ezdora"
REPO_URL="${EZDORA_REPO_URL:-git@github.com:takitani/ezdora.git}"

rm -rf "$TARGET_DIR"
mkdir -p "$(dirname "$TARGET_DIR")"

if git ls-remote "$REPO_URL" &>/dev/null; then
  git clone "$REPO_URL" "$TARGET_DIR"
else
  echo "[ezdora] Aviso: REPO_URL inválida ou sem rede. Copie o projeto manualmente para $TARGET_DIR."
  exit 1
fi

echo "[ezdora] Iniciando instalação..."
bash "$TARGET_DIR/install.sh"
