#!/usr/bin/env bash
set -euo pipefail

# Install Bitwarden password manager via Flatpak

echo "[ezdora][bitwarden] Instalando Bitwarden (gerenciador de senhas)..."

# Function to check if a Flatpak app is installed
is_flatpak_installed() {
    flatpak list --app 2>/dev/null | grep -q "$1" || false
}

# Ensure Flatpak is installed
if ! command -v flatpak >/dev/null 2>&1; then
    echo "[ezdora][bitwarden] Instalando Flatpak..."
    sudo dnf install -y flatpak
else
    echo "[ezdora][bitwarden] Flatpak já está instalado"
fi

# Add Flathub repository if not present
if ! flatpak remotes 2>/dev/null | grep -q flathub; then
    echo "[ezdora][bitwarden] Adicionando repositório Flathub..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
    echo "[ezdora][bitwarden] Repositório Flathub já está configurado"
fi

# Install Bitwarden
if ! is_flatpak_installed "com.bitwarden.desktop"; then
    echo "[ezdora][bitwarden] Instalando Bitwarden..."
    sudo flatpak install -y flathub com.bitwarden.desktop
    echo "[ezdora][bitwarden] Bitwarden instalado com sucesso"
else
    echo "[ezdora][bitwarden] Bitwarden já está instalado"
fi

echo "[ezdora][bitwarden] Bitwarden (gerenciador de senhas) está disponível no menu de aplicações"
