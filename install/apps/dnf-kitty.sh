#!/usr/bin/env bash
set -euo pipefail

if command -v kitty >/dev/null 2>&1 || rpm -q kitty >/dev/null 2>&1; then
  exit 0
fi

echo "[ezdora][kitty] Instalando kitty..."
sudo dnf install -y kitty
