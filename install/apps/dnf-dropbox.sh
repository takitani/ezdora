#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][dropbox] Instalando Dropbox via repositório oficial (Fedora)..."

# Add official Dropbox repo
if [ ! -f /etc/yum.repos.d/dropbox.repo ]; then
  if command -v dnf5 >/dev/null 2>&1; then
    sudo dnf5 config-manager addrepo --from-repofile=https://linux.dropbox.com/fedora/dropbox.repo || true
  else
    sudo dnf config-manager --add-repo https://linux.dropbox.com/fedora/dropbox.repo || true
  fi
fi

# Install dropbox package (will download user daemon on first run)
sudo dnf install -y dropbox || {
  echo "[ezdora][dropbox] Falha ao instalar pacote 'dropbox'." >&2
  exit 1
}

echo "[ezdora][dropbox] Concluído. Inicie o Dropbox para baixar o daemon do usuário e conectar sua conta."
echo "[ezdora][dropbox] Nota: ícones de sobreposição no Dolphin não são oficialmente suportados."

