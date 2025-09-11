#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIST_FILE="$ROOT_DIR/packages/flatpak.txt"

# Garante Flathub no escopo do usuário
flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

[ -f "$LIST_FILE" ] || { echo "[ezdora][flatpak] Lista não encontrada: $LIST_FILE"; exit 0; }

mapfile -t APPS < <(sed -e 's/#.*$//' -e 's/\s\+$//' "$LIST_FILE" | awk 'NF')

if [ ${#APPS[@]} -eq 0 ]; then
  echo "[ezdora][flatpak] Nenhum app listado em $LIST_FILE"
  exit 0
fi

echo "[ezdora][flatpak] Instalando: ${APPS[*]}"
for app in "${APPS[@]}"; do
  flatpak install -y --user flathub "$app"
done
