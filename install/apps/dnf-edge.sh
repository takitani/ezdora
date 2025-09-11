#!/usr/bin/env bash
set -euo pipefail

# Install Microsoft Edge (Stable) on Fedora via official Microsoft repo

if rpm -q microsoft-edge-stable >/dev/null 2>&1; then
  echo "[ezdora][edge] Microsoft Edge já instalado. Pulando."
  exit 0
fi

echo "[ezdora][edge] Configurando repositório da Microsoft para Edge..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || true

sudo tee /etc/yum.repos.d/microsoft-edge.repo >/dev/null <<'EOF'
[microsoft-edge]
name=Microsoft Edge
baseurl=https://packages.microsoft.com/yumrepos/edge
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

sudo dnf check-update || true
echo "[ezdora][edge] Instalando microsoft-edge-stable..."
sudo dnf install -y microsoft-edge-stable

echo "[ezdora][edge] Edge instalado."

