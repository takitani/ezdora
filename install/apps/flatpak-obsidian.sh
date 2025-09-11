#!/usr/bin/env bash
set -euo pipefail

APP_ID=md.obsidian.Obsidian
if flatpak list --app --columns=application | grep -qx "$APP_ID"; then
  exit 0
fi

flatpak install -y flathub "$APP_ID"

