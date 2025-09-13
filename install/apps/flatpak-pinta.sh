#!/usr/bin/env bash
set -euo pipefail

# Install Pinta image editor via Flatpak

echo "[ezdora][pinta] Instalando Pinta (editor de imagens)..."

# Function to check if a Flatpak app is installed
is_flatpak_installed() {
    flatpak list --app 2>/dev/null | grep -q "$1" || false
}

# Ensure Flatpak is installed
if ! command -v flatpak >/dev/null 2>&1; then
    echo "[ezdora][pinta] Instalando Flatpak..."
    sudo dnf install -y flatpak
else
    echo "[ezdora][pinta] Flatpak já está instalado"
fi

# Add Flathub repository if not present
if ! flatpak remotes 2>/dev/null | grep -q flathub; then
    echo "[ezdora][pinta] Adicionando repositório Flathub..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
    echo "[ezdora][pinta] Repositório Flathub já está configurado"
fi

# Install Pinta
if ! is_flatpak_installed "com.github.PintaProject.Pinta"; then
    echo "[ezdora][pinta] Instalando Pinta..."
    sudo flatpak install -y flathub com.github.PintaProject.Pinta
    echo "[ezdora][pinta] Pinta instalado com sucesso"
else
    echo "[ezdora][pinta] Pinta já está instalado"
fi

echo "[ezdora][pinta] Pinta (editor de imagens) está disponível no menu de aplicações"
