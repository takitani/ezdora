#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][dropbox] Instalando Dropbox (Fedora)..."

# Try to add official repo first (might be temporarily unavailable)
if [ ! -f /etc/yum.repos.d/dropbox.repo ]; then
  echo "[ezdora][dropbox] Tentando adicionar repositório oficial..."
  if command -v dnf5 >/dev/null 2>&1; then
    sudo dnf5 config-manager addrepo --from-repofile=https://linux.dropbox.com/fedora/dropbox.repo 2>/dev/null || {
      echo "[ezdora][dropbox] Repositório oficial indisponível, usando método alternativo..."
    }
  else
    sudo dnf config-manager --add-repo https://linux.dropbox.com/fedora/dropbox.repo 2>/dev/null || {
      echo "[ezdora][dropbox] Repositório oficial indisponível, usando método alternativo..."
    }
  fi
fi

# Try to install from repo first
if sudo dnf install -y dropbox 2>/dev/null; then
  echo "[ezdora][dropbox] Instalado com sucesso via repositório."
else
  echo "[ezdora][dropbox] Instalando via download direto do RPM..."
  
  # Detect Fedora version
  FEDORA_VERSION=$(rpm -E %fedora)
  
  # Download and install RPM directly
  TEMP_RPM="/tmp/dropbox-fedora.rpm"
  wget -q -O "$TEMP_RPM" "https://www.dropbox.com/download?dl=packages/fedora/dropbox-${FEDORA_VERSION}-1.fedora.x86_64.rpm" || {
    # Fallback to latest version if specific version not found
    echo "[ezdora][dropbox] Tentando versão mais recente..."
    wget -q -O "$TEMP_RPM" "https://www.dropbox.com/download?dl=packages/fedora/dropbox-2024.04.17-1.fedora.x86_64.rpm" || {
      echo "[ezdora][dropbox] Falha ao baixar RPM do Dropbox." >&2
      exit 1
    }
  }
  
  sudo dnf install -y "$TEMP_RPM" || {
    echo "[ezdora][dropbox] Falha ao instalar RPM do Dropbox." >&2
    rm -f "$TEMP_RPM"
    exit 1
  }
  
  rm -f "$TEMP_RPM"
  echo "[ezdora][dropbox] Instalado com sucesso via RPM."
fi

echo "[ezdora][dropbox] Concluído. Inicie o Dropbox para baixar o daemon do usuário e conectar sua conta."
echo "[ezdora][dropbox] Nota: ícones de sobreposição no Dolphin não são oficialmente suportados."

