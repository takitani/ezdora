#!/usr/bin/env bash
set -euo pipefail

if rpm -q vlc >/dev/null 2>&1; then
  exit 0
fi

echo "[ezdora][vlc] Habilitando RPM Fusion (free e nonfree)..."
FEDORA_VER=$(rpm -E %fedora)
sudo dnf install -y \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm" || true

echo "[ezdora][vlc] Instalando vlc via DNF..."
sudo dnf install -y vlc

