#!/usr/bin/env bash
set -euo pipefail

if rpm -q google-chrome-stable >/dev/null 2>&1; then
  exit 0
fi

echo "[ezdora][chrome] Habilitando repositório do Google..."
sudo dnf install -y fedora-workstation-repositories || true
# Preferir instrução oficial Fedora: setopt google-chrome.enabled=1
if command -v dnf5 >/dev/null 2>&1; then
  sudo dnf5 config-manager setopt google-chrome.enabled=1 || true
else
  sudo dnf config-manager setopt google-chrome.enabled=1 || true
fi
# Garantir enabled=1 no arquivo .repo como fallback
if [ -f /etc/yum.repos.d/google-chrome.repo ]; then
  if ! grep -q '^enabled=1' /etc/yum.repos.d/google-chrome.repo; then
    sudo sed -i 's/^enabled=.*/enabled=1/' /etc/yum.repos.d/google-chrome.repo || true
  fi
fi
sudo dnf makecache -y || true
echo "[ezdora][chrome] Instalando google-chrome-stable..."
sudo dnf install -y google-chrome-stable
