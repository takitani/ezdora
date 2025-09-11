#!/usr/bin/env bash
set -euo pipefail

if rpm -q code >/dev/null 2>&1; then
  exit 0
fi

echo "[ezdora][vscode] Configurando repositório da Microsoft..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || true
sudo tee /etc/yum.repos.d/vscode.repo >/dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

echo "[ezdora][vscode] Instalando code..."
sudo dnf check-update || true
sudo dnf install -y code

