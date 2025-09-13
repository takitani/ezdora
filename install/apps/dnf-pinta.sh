#!/usr/bin/env bash
set -euo pipefail

# Install Pinta image editor via DNF

echo "[ezdora][pinta] Instalando Pinta (editor de imagens)..."

# Function to check if a DNF package is installed
is_dnf_installed() {
    rpm -q "$1" >/dev/null 2>&1 || false
}

# Install Pinta via DNF
if ! is_dnf_installed "pinta"; then
    echo "[ezdora][pinta] Instalando Pinta..."
    sudo dnf install -y pinta
    echo "[ezdora][pinta] Pinta instalado com sucesso"
else
    echo "[ezdora][pinta] Pinta já está instalado"
fi

echo "[ezdora][pinta] Pinta (editor de imagens) está disponível no menu de aplicações"
