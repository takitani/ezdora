#!/usr/bin/env bash
set -euo pipefail

# Install desktop applications: Pinta, Bitwarden, 1Password
# Uses DNF for system packages, Flatpak for desktop clients

echo "[ezdora][desktop-apps] Instalando aplicativos desktop..."

# Function to check if a Flatpak app is installed
is_flatpak_installed() {
    flatpak list --app 2>/dev/null | grep -q "$1" || false
}

# Function to check if a DNF package is installed
is_dnf_installed() {
    rpm -q "$1" >/dev/null 2>&1 || false
}

# Ensure Flatpak is installed
if ! command -v flatpak >/dev/null 2>&1; then
    echo "[ezdora][desktop-apps] Instalando Flatpak..."
    sudo dnf install -y flatpak
else
    echo "[ezdora][desktop-apps] Flatpak já está instalado"
fi

# Add Flathub repository if not present
if ! flatpak remotes 2>/dev/null | grep -q flathub; then
    echo "[ezdora][desktop-apps] Adicionando repositório Flathub..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
    echo "[ezdora][desktop-apps] Repositório Flathub já está configurado"
fi

# Install Pinta (image editor)
echo "[ezdora][desktop-apps] Verificando Pinta..."
if ! is_flatpak_installed "com.github.PintaProject.Pinta"; then
    echo "[ezdora][desktop-apps] Instalando Pinta..."
    sudo flatpak install -y flathub com.github.PintaProject.Pinta
    echo "[ezdora][desktop-apps] Pinta instalado com sucesso"
else
    echo "[ezdora][desktop-apps] Pinta já está instalado"
fi

# Install Bitwarden (password manager)
echo "[ezdora][desktop-apps] Verificando Bitwarden..."
if ! is_flatpak_installed "com.bitwarden.desktop"; then
    echo "[ezdora][desktop-apps] Instalando Bitwarden..."
    sudo flatpak install -y flathub com.bitwarden.desktop
    echo "[ezdora][desktop-apps] Bitwarden instalado com sucesso"
else
    echo "[ezdora][desktop-apps] Bitwarden já está instalado"
fi

# Install 1Password (password manager)
echo "[ezdora][desktop-apps] Verificando 1Password..."
if ! is_flatpak_installed "com.1password.1password"; then
    echo "[ezdora][desktop-apps] Instalando 1Password..."
    sudo flatpak install -y flathub com.1password.1password
    echo "[ezdora][desktop-apps] 1Password instalado com sucesso"
else
    echo "[ezdora][desktop-apps] 1Password já está instalado"
fi

# Update Flatpak apps (optional, but good practice)
echo "[ezdora][desktop-apps] Atualizando aplicativos Flatpak..."
sudo flatpak update -y --noninteractive || true

echo "[ezdora][desktop-apps] Instalação de aplicativos desktop concluída!"
echo "[ezdora][desktop-apps] Aplicativos instalados:"
echo "[ezdora][desktop-apps]   - Pinta (editor de imagens)"
echo "[ezdora][desktop-apps]   - Bitwarden (gerenciador de senhas)"
echo "[ezdora][desktop-apps]   - 1Password (gerenciador de senhas)"
echo "[ezdora][desktop-apps] Todos os aplicativos estarão disponíveis no menu de aplicações."
