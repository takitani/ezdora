#!/usr/bin/env bash
set -euo pipefail

# Install Bitwarden password manager - prioritize Flatpak for auto-updates

echo "[ezdora][bitwarden] Instalando Bitwarden (gerenciador de senhas)..."

# Function to check if RPM package is installed
is_rpm_installed() {
    rpm -q "$1" >/dev/null 2>&1 || false
}

# Function to check if Flatpak app is installed
is_flatpak_installed() {
    flatpak list --app 2>/dev/null | grep -q "$1" || false
}

# Check if already installed
if is_flatpak_installed "com.bitwarden.desktop"; then
    echo "[ezdora][bitwarden] Bitwarden já está instalado via Flatpak (com auto-update)"
    exit 0
fi

if is_rpm_installed "bitwarden"; then
    echo "[ezdora][bitwarden] Bitwarden já está instalado via RPM"
    echo "[ezdora][bitwarden] NOTA: Considere migrar para Flatpak para ter auto-update"
    exit 0
fi

# Install via Flatpak (preferred for auto-updates)
echo "[ezdora][bitwarden] Instalando via Flatpak (auto-update habilitado)..."

# Ensure Flatpak is installed
if ! command -v flatpak >/dev/null 2>&1; then
    echo "[ezdora][bitwarden] Instalando Flatpak..."
    sudo dnf install -y flatpak
fi

# Add Flathub repository if not present (user installation)
if ! flatpak remotes | grep -q "^flathub"; then
    echo "[ezdora][bitwarden] Adicionando repositório Flathub..."
    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

# Install via Flatpak
if flatpak install --user -y flathub com.bitwarden.desktop; then
    echo "[ezdora][bitwarden] ✅ Bitwarden instalado com sucesso via Flatpak"
    echo "[ezdora][bitwarden] ✨ Auto-update habilitado via Flatpak"
    echo "[ezdora][bitwarden] Para executar: flatpak run com.bitwarden.desktop"
else
    echo "[ezdora][bitwarden] ❌ ERRO: Falha ao instalar Bitwarden via Flatpak"
    echo "[ezdora][bitwarden] Verifique sua conexão com a internet"
    echo "[ezdora][bitwarden] NOTA: Bitwarden não tem repositório RPM oficial"
    exit 1
fi

echo "[ezdora][bitwarden] Bitwarden está disponível no menu de aplicações"
echo "[ezdora][bitwarden] Configure sua conta em: https://bitwarden.com"