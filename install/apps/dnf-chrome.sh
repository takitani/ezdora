#!/usr/bin/env bash
set -euo pipefail

if rpm -q google-chrome-stable >/dev/null 2>&1; then
  exit 0
fi

echo "[ezdora][chrome] Habilitando repositório do Google..."
sudo dnf install -y fedora-workstation-repositories || true
sudo dnf config-manager --set-enabled google-chrome || true
echo "[ezdora][chrome] Instalando google-chrome-stable..."
sudo dnf install -y google-chrome-stable

