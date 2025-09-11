#!/usr/bin/env bash
set -euo pipefail

if rpm -q google-chrome-stable >/dev/null 2>&1; then
  exit 0
fi

echo "[ezdora][chrome] Habilitando repositório do Google..."
sudo dnf install -y fedora-workstation-repositories || true
# Compatibilidade com dnf5 e dnf clássicos
if command -v dnf5 >/dev/null 2>&1; then
  sudo dnf5 config-manager enable google-chrome || true
else
  # dnf plugin pode aceitar --set-enabled ou 'enable'
  sudo dnf config-manager --set-enabled google-chrome || sudo dnf config-manager enable google-chrome || true
fi
echo "[ezdora][chrome] Instalando google-chrome-stable..."
sudo dnf install -y google-chrome-stable
