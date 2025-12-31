#!/usr/bin/env bash
set -euo pipefail

trap 'echo "[ezdora] Falha na instalação. Você pode reexecutar com: bash ./install.sh"' ERR

echo "[ezdora] Verificando distribuição..."
if [ -r /etc/os-release ]; then
  . /etc/os-release
else
  echo "[ezdora] /etc/os-release não encontrado. Abortando." >&2
  exit 1
fi

if [ "${ID:-}" != "fedora" ]; then
  echo "[ezdora] Esta instalação é destinada ao Fedora. Detectado: ${ID:-desconhecido}" >&2
  exit 1
fi

# Verifica versão (Fedora 43+)
VER=${VERSION_ID%%.*}
if [ -z "$VER" ] || [ "$VER" -lt 43 ]; then
  echo "[ezdora] Requer Fedora 43 ou superior. Detectado: ${VERSION_ID:-desconhecido}" >&2
  exit 1
fi

echo "[ezdora] Atualizando sistema (dnf upgrade --refresh)..."
sudo dnf upgrade --refresh -y

echo "[ezdora] Instalando dependências base (git, curl, flatpak, dnf-plugins-core, gum)..."
sudo dnf install -y git curl flatpak dnf-plugins-core gum || {
  # Se gum não estiver disponível no repo padrão, tentar com COPR
  echo "[ezdora] Tentando instalar gum via COPR..."
  sudo dnf copr enable -y alcortesm/gum 2>/dev/null || true
  sudo dnf install -y gum 2>/dev/null || {
    echo "[ezdora] Aviso: gum não pôde ser instalado, interface interativa limitada."
  }
}

echo "[ezdora] Configurando Flathub (user) se necessário..."
flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

echo "[ezdora] Instalando aplicativos (scripts individuais)..."
EZDORA_AUTOMATED=true bash "$(dirname "$0")/install/apps.sh"

echo "[ezdora] Limpeza opcional de pacotes órfãos..."
sudo dnf autoremove -y || true

echo "[ezdora] Instalação concluída. Aproveite!"
