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

# Verifica versão (Fedora 42+)
VER=${VERSION_ID%%.*}
if [ -z "$VER" ] || [ "$VER" -lt 42 ]; then
  echo "[ezdora] Requer Fedora 42 ou superior. Detectado: ${VERSION_ID:-desconhecido}" >&2
  exit 1
fi

echo "[ezdora] Atualizando sistema (dnf upgrade --refresh)..."
sudo dnf upgrade --refresh -y

echo "[ezdora] Instalando dependências base (git, curl, flatpak, dnf-plugins-core)..."
sudo dnf install -y git curl flatpak dnf-plugins-core

echo "[ezdora] Configurando Flathub (se necessário)..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

echo "[ezdora] Instalando aplicativos (scripts individuais)..."
bash "$(dirname "$0")/install/apps.sh"

echo "[ezdora] Limpeza opcional de pacotes órfãos..."
sudo dnf autoremove -y || true

echo "[ezdora] Instalação concluída. Aproveite!"
