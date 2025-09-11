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
  
  # Download and install RPM directly - using nautilus-dropbox package
  TEMP_RPM="/tmp/nautilus-dropbox.rpm"
  
  # Try to download the latest nautilus-dropbox RPM
  echo "[ezdora][dropbox] Baixando nautilus-dropbox RPM..."
  wget -O "$TEMP_RPM" "https://www.dropbox.com/download?dl=packages/fedora/nautilus-dropbox-2025.05.20-1.fc42.x86_64.rpm" || {
    # Fallback to generic latest version
    echo "[ezdora][dropbox] Tentando versão alternativa..."
    wget -O "$TEMP_RPM" "https://www.dropbox.com/download?dl=packages/fedora/nautilus-dropbox-2024.04.17-1.fedora.x86_64.rpm" || {
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

