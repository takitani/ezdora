#!/usr/bin/env bash
set -euo pipefail

# Install Bitwarden password manager - prioritize RPM, fallback to Flatpak

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
if is_rpm_installed "bitwarden"; then
    echo "[ezdora][bitwarden] Bitwarden já está instalado via RPM"
    exit 0
fi

if is_flatpak_installed "com.bitwarden.desktop"; then
    echo "[ezdora][bitwarden] Bitwarden já está instalado via Flatpak"
    exit 0
fi

# Try RPM installation first (preferred)
echo "[ezdora][bitwarden] Tentando instalar via RPM (preferencial)..."

# Add Bitwarden RPM repository if not present
REPO_FILE="/etc/yum.repos.d/bitwarden.repo"
if [ ! -f "$REPO_FILE" ]; then
    echo "[ezdora][bitwarden] Configurando repositório Bitwarden..."
    
    # Import signing key
    sudo rpm --import https://vault.bitwarden.com/download/linux/keys/bitwarden.asc 2>/dev/null || true
    
    # Add repository
    sudo sh -c 'echo -e "[bitwarden]
name=Bitwarden
baseurl=https://vault.bitwarden.com/rpm
enabled=1
gpgcheck=1
gpgkey=https://vault.bitwarden.com/download/linux/keys/bitwarden.asc" > /etc/yum.repos.d/bitwarden.repo'
fi

# Try to install via DNF
if sudo dnf install -y bitwarden 2>/dev/null; then
    echo "[ezdora][bitwarden] ✅ Bitwarden instalado com sucesso via RPM"
    echo "[ezdora][bitwarden] Para executar: bitwarden"
else
    echo "[ezdora][bitwarden] RPM não disponível, tentando via Flatpak..."
    
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
        echo "[ezdora][bitwarden] Para executar: flatpak run com.bitwarden.desktop"
    else
        echo "[ezdora][bitwarden] ❌ ERRO: Falha ao instalar Bitwarden"
        echo "[ezdora][bitwarden] Verifique sua conexão com a internet"
        exit 1
    fi
fi

echo "[ezdora][bitwarden] Bitwarden está disponível no menu de aplicações"
echo "[ezdora][bitwarden] Configure sua conta em: https://bitwarden.com"