#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIST_FILE="$ROOT_DIR/packages/dnf.txt"

[ -f "$LIST_FILE" ] || { echo "[ezdora][dnf] Lista não encontrada: $LIST_FILE"; exit 0; }

mapfile -t PKGS < <(sed -e 's/#.*$//' -e 's/\s\+$//' "$LIST_FILE" | awk 'NF')

if [ ${#PKGS[@]} -eq 0 ]; then
  echo "[ezdora][dnf] Nenhum pacote listado em $LIST_FILE"
  exit 0
fi

# Se chrome for solicitado, habilita o repositório do Google
if printf '%s\n' "${PKGS[@]}" | grep -q '^google-chrome-stable$'; then
  echo "[ezdora][dnf] Habilitando repositório do Google Chrome..."
  sudo dnf install -y fedora-workstation-repositories || true
  if command -v dnf5 >/dev/null 2>&1; then
    sudo dnf5 config-manager --set-enabled google-chrome || sudo dnf5 config-manager enable google-chrome || true
  else
    sudo dnf config-manager --set-enabled google-chrome || sudo dnf config-manager enable google-chrome || true
  fi
fi

# Se ghostty for solicitado, habilita o COPR correspondente
if printf '%s\n' "${PKGS[@]}" | grep -q '^ghostty$'; then
  echo "[ezdora][dnf] Habilitando COPR scottames/ghostty..."
  if command -v dnf5 >/dev/null 2>&1; then
    sudo dnf5 copr enable -y scottames/ghostty || true
  else
    sudo dnf copr enable -y scottames/ghostty || true
  fi
fi

# Se vlc for solicitado, habilita RPM Fusion (free e nonfree)
if printf '%s\n' "${PKGS[@]}" | grep -q '^vlc$'; then
  echo "[ezdora][dnf] Habilitando RPM Fusion para VLC..."
  FEDORA_VER=$(rpm -E %fedora)
  sudo dnf install -y \
    "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm" || true
fi

echo "[ezdora][dnf] Instalando: ${PKGS[*]}"
sudo dnf install -y "${PKGS[@]}"
