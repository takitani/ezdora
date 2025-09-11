#!/usr/bin/env bash
set -euo pipefail

if rpm -q google-chrome-stable >/dev/null 2>&1; then
  exit 0
fi

echo "[ezdora][chrome] Habilitando repositório do Google..."
sudo dnf install -y fedora-workstation-repositories || true
# Método robusto: habilitar diretamente no arquivo .repo
if [ -f /etc/yum.repos.d/google-chrome.repo ]; then
  if grep -q '^enabled=0' /etc/yum.repos.d/google-chrome.repo; then
    echo "[ezdora][chrome] Ativando /etc/yum.repos.d/google-chrome.repo"
    sudo sed -i 's/^enabled=.*/enabled=1/' /etc/yum.repos.d/google-chrome.repo
  fi
else
  # Fallback: tentar via config-manager (dnf classic ou dnf5)
  if command -v dnf5 >/dev/null 2>&1; then
    sudo dnf5 config-manager --set-enabled google-chrome || sudo dnf5 config-manager enable google-chrome || true
  else
    sudo dnf config-manager --set-enabled google-chrome || sudo dnf config-manager enable google-chrome || true
  fi
fi
echo "[ezdora][chrome] Instalando google-chrome-stable..."
sudo dnf install -y google-chrome-stable
