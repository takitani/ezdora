#!/usr/bin/env bash
set -euo pipefail

# Install OBS Studio via DNF (requires RPM Fusion Free)

if rpm -q obs-studio >/dev/null 2>&1; then
  echo "[ezdora][obs] OBS Studio já instalado. Pulando."
  exit 0
fi

echo "[ezdora][obs] Habilitando RPM Fusion (free/nonfree) para OBS..."
FEDORA_VER=$(rpm -E %fedora)
sudo dnf install -y \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm" || true

echo "[ezdora][obs] Instalando obs-studio..."
sudo dnf install -y obs-studio

echo "[ezdora][obs] OBS Studio instalado."

