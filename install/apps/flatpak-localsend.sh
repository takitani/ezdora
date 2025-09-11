#!/usr/bin/env bash
set -euo pipefail

APP_ID=org.localsend.localsend_app
if flatpak --user list --app --columns=application | grep -qx "$APP_ID"; then
  exit 0
fi

flatpak install -y --user flathub "$APP_ID"
