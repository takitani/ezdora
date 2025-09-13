#!/usr/bin/env bash
set -euo pipefail

# Install Spotify music streaming app via Flatpak

echo "[ezdora][spotify] Instalando Spotify (streaming de música)..."

# Function to check if Flatpak app is installed
is_flatpak_installed() {
    flatpak list --app 2>/dev/null | grep -q "$1" || false
}

# Check if already installed
if is_flatpak_installed "com.spotify.Client"; then
    echo "[ezdora][spotify] Spotify já está instalado via Flatpak"
    exit 0
fi

# Ensure Flatpak is installed
if ! command -v flatpak >/dev/null 2>&1; then
    echo "[ezdora][spotify] Instalando Flatpak..."
    sudo dnf install -y flatpak
fi

# Add Flathub repository if not present (user installation)
if ! flatpak remotes | grep -q "^flathub"; then
    echo "[ezdora][spotify] Adicionando repositório Flathub..."
    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

# Install Spotify via Flatpak
echo "[ezdora][spotify] Instalando Spotify via Flatpak..."
if flatpak install --user -y flathub com.spotify.Client; then
    echo "[ezdora][spotify] ✅ Spotify instalado com sucesso via Flatpak"
    echo "[ezdora][spotify] ✨ Auto-update habilitado via Flatpak"
    echo "[ezdora][spotify] Para executar: flatpak run com.spotify.Client"
else
    echo "[ezdora][spotify] ❌ ERRO: Falha ao instalar Spotify via Flatpak"
    echo "[ezdora][spotify] Verifique sua conexão com a internet"
    exit 1
fi

echo "[ezdora][spotify] Spotify está disponível no menu de aplicações"
echo "[ezdora][spotify] Faça login em: https://spotify.com"