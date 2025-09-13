#!/usr/bin/env bash
set -euo pipefail

# Install Pinta image editor - prioritize DNF, fallback to Flatpak

echo "[ezdora][pinta] Instalando Pinta (editor de imagens)..."

# Function to check if a DNF package is installed
is_dnf_installed() {
    rpm -q "$1" >/dev/null 2>&1 || false
}

# Function to check if a Flatpak package is installed
is_flatpak_installed() {
    flatpak list 2>/dev/null | grep -q "$1" || false
}

# Check if already installed
if is_dnf_installed "pinta"; then
    echo "[ezdora][pinta] Pinta já está instalado via DNF"
    exit 0
fi

if is_flatpak_installed "com.github.PintaProject.Pinta"; then
    echo "[ezdora][pinta] Pinta já está instalado via Flatpak"
    exit 0
fi

# Try to install via DNF first (preferred)
echo "[ezdora][pinta] Tentando instalar via DNF (preferencial)..."
if sudo dnf install -y pinta 2>/dev/null; then
    echo "[ezdora][pinta] ✅ Pinta instalado com sucesso via DNF"
    echo "[ezdora][pinta] Para executar: pinta"
else
    echo "[ezdora][pinta] DNF falhou, tentando via Flatpak..."
    
    # Check if Flatpak is installed
    if ! command -v flatpak >/dev/null 2>&1; then
        echo "[ezdora][pinta] ERRO: Nem DNF nem Flatpak conseguiram instalar o Pinta"
        echo "[ezdora][pinta] Flatpak não está instalado. Execute: install/apps/flatpak.sh"
        exit 1
    fi
    
    # Check if Flathub is configured
    if ! flatpak remotes | grep -q "^flathub"; then
        echo "[ezdora][pinta] Adicionando repositório Flathub..."
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi
    
    # Install via Flatpak
    if flatpak install -y flathub com.github.PintaProject.Pinta; then
        echo "[ezdora][pinta] ✅ Pinta instalado com sucesso via Flatpak"
        echo "[ezdora][pinta] Para executar: flatpak run com.github.PintaProject.Pinta"
    else
        echo "[ezdora][pinta] ❌ ERRO: Falha ao instalar Pinta"
        exit 1
    fi
fi

echo "[ezdora][pinta] Pinta está disponível no menu de aplicações"