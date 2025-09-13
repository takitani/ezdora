#!/usr/bin/env bash
set -euo pipefail

# Install 1Password password manager via Flatpak

echo "[ezdora][1password] Instalando 1Password (gerenciador de senhas)..."

# Function to check if a Flatpak app is installed
is_flatpak_installed() {
    flatpak list --app 2>/dev/null | grep -q "$1" || false
}

# Ensure Flatpak is installed
if ! command -v flatpak >/dev/null 2>&1; then
    echo "[ezdora][1password] Instalando Flatpak..."
    sudo dnf install -y flatpak
else
    echo "[ezdora][1password] Flatpak já está instalado"
fi

# Add Flathub repository if not present
if ! flatpak remotes 2>/dev/null | grep -q flathub; then
    echo "[ezdora][1password] Adicionando repositório Flathub..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
    echo "[ezdora][1password] Repositório Flathub já está configurado"
fi

# Install 1Password
if ! is_flatpak_installed "com.1password.1password"; then
    echo "[ezdora][1password] Instalando 1Password..."
    sudo flatpak install -y flathub com.1password.1password
    echo "[ezdora][1password] 1Password instalado com sucesso"
else
    echo "[ezdora][1password] 1Password já está instalado"
fi

echo "[ezdora][1password] 1Password (gerenciador de senhas) está disponível no menu de aplicações"
