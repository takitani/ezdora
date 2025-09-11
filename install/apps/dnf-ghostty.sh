#!/usr/bin/env bash
set -euo pipefail

if command -v ghostty >/dev/null 2>&1 || rpm -q ghostty >/dev/null 2>&1; then
  exit 0
fi

echo "[ezdora][ghostty] Habilitando COPR scottames/ghostty..."
sudo dnf copr enable -y scottames/ghostty || true
echo "[ezdora][ghostty] Instalando ghostty..."
sudo dnf install -y ghostty

