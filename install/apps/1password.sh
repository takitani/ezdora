#!/usr/bin/env bash
set -euo pipefail

# Install 1Password password manager - prioritize RPM, fallback to Flatpak

echo "[ezdora][1password] Instalando 1Password (gerenciador de senhas)..."

# Function to check if RPM package is installed
is_rpm_installed() {
    rpm -q "$1" >/dev/null 2>&1 || false
}

# Function to check if Flatpak app is installed
is_flatpak_installed() {
    flatpak list --app 2>/dev/null | grep -q "$1" || false
}

# Check if already installed
if is_rpm_installed "1password"; then
    echo "[ezdora][1password] 1Password já está instalado via RPM"
    exit 0
fi

if is_flatpak_installed "com.onepassword.OnePassword"; then
    echo "[ezdora][1password] 1Password já está instalado via Flatpak"
    exit 0
fi

# Try RPM installation first (preferred)
echo "[ezdora][1password] Tentando instalar via RPM (preferencial)..."

# Add 1Password RPM repository if not present
if [ ! -f /etc/yum.repos.d/1password.repo ]; then
    echo "[ezdora][1password] Configurando repositório 1Password..."
    
    # Import signing key
    sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
    
    # Add repository
    sudo sh -c 'echo -e "[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc" > /etc/yum.repos.d/1password.repo'
fi

# Try to install via DNF
if sudo dnf install -y 1password 2>/dev/null; then
    echo "[ezdora][1password] ✅ 1Password instalado com sucesso via RPM"
    echo "[ezdora][1password] Para executar: 1password"
else
    echo "[ezdora][1password] RPM falhou, tentando via Flatpak..."
    
    # Ensure Flatpak is installed
    if ! command -v flatpak >/dev/null 2>&1; then
        echo "[ezdora][1password] Instalando Flatpak..."
        sudo dnf install -y flatpak
    fi
    
    # Add Flathub repository if not present (without sudo for user installation)
    if ! flatpak remotes | grep -q "^flathub"; then
        echo "[ezdora][1password] Adicionando repositório Flathub..."
        flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi
    
    # Install via Flatpak
    if flatpak install --user -y flathub com.onepassword.OnePassword 2>/dev/null; then
        echo "[ezdora][1password] ✅ 1Password instalado com sucesso via Flatpak"
        echo "[ezdora][1password] Para executar: flatpak run com.onepassword.OnePassword"
    else
        echo "[ezdora][1password] ❌ ERRO: Falha ao instalar 1Password"
        echo "[ezdora][1password] Verifique sua conexão com a internet"
        exit 1
    fi
fi

echo "[ezdora][1password] 1Password está disponível no menu de aplicações"
echo "[ezdora][1password] Configure sua conta em: https://1password.com"