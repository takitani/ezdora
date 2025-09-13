#!/usr/bin/env bash
set -euo pipefail

# Install fastfetch system information tool via DNF

echo "[ezdora][fastfetch] Instalando fastfetch (ferramenta de informações do sistema)..."

# Function to check if a DNF package is installed
is_dnf_installed() {
    rpm -q "$1" >/dev/null 2>&1 || false
}

# Install fastfetch via DNF
if ! is_dnf_installed "fastfetch"; then
    echo "[ezdora][fastfetch] Instalando fastfetch..."
    sudo dnf install -y fastfetch
    echo "[ezdora][fastfetch] fastfetch instalado com sucesso"
else
    echo "[ezdora][fastfetch] fastfetch já está instalado"
fi

echo "[ezdora][fastfetch] fastfetch está disponível no terminal"
echo "[ezdora][fastfetch] Execute 'fastfetch' para ver informações do sistema"

