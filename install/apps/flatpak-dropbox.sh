#!/usr/bin/env bash
set -euo pipefail

APP_ID="com.dropbox.Client"

# Ensure flathub user remote exists
flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

if flatpak --user list --app --columns=application | grep -qx "$APP_ID"; then
  echo "[ezdora][dropbox] Já instalado via Flatpak."
  exit 0
fi

echo "[ezdora][dropbox] Instalando Dropbox (Flatpak)..."
flatpak install -y --user flathub "$APP_ID"

echo "[ezdora][dropbox] Concluído. Abra o Dropbox para configurar sua conta."
echo "[ezdora][dropbox] Nota: ícones de sobreposição no Dolphin não são suportados oficialmente; o acesso e sincronização via ~/Dropbox funcionam normalmente."

