#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][docker] Instalando Docker Engine (Fedora)..."

# Remove versões antigas (não falhar se não existirem)
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine || true

# Pré-requisito
sudo dnf install -y dnf-plugins-core || true

# Adicionar repositório oficial
if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
  if command -v dnf5 >/dev/null 2>&1; then
    sudo dnf5 config-manager addrepo https://download.docker.com/linux/fedora/docker-ce.repo || true
  else
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo || true
  fi
fi

# Fallback: criar arquivo de repositório se ainda não existir
if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
  echo "[ezdora][docker] Escrevendo /etc/yum.repos.d/docker-ce.repo (fallback)"
  sudo tee /etc/yum.repos.d/docker-ce.repo >/dev/null <<'EOF'
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/fedora/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF
fi

# Instalação do Docker Engine e plugins
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Habilita e inicia serviço
sudo systemctl enable --now docker

# Permite uso sem sudo
if getent group docker >/dev/null 2>&1; then
  sudo usermod -aG docker "$USER" || true
fi

echo "[ezdora][docker] Docker instalado. Abra uma nova sessão para aplicar grupo 'docker'."

