#!/usr/bin/env bash
set -euo pipefail

# Only apply on KDE/Plasma sessions
if [[ "${XDG_CURRENT_DESKTOP:-}" != *KDE* && "${XDG_CURRENT_DESKTOP:-}" != *PLASMA* && "${XDG_SESSION_DESKTOP:-}" != *plasma* ]]; then
  exit 0
fi

# Ensure Ghostty is installed
if ! command -v ghostty >/dev/null 2>&1 && ! rpm -q ghostty >/dev/null 2>&1; then
  echo "[ezdora][kde] Ghostty não instalado ainda; adiando configuração do terminal padrão."
  exit 0
fi

# Try to detect Ghostty desktop ID dynamically; fallback to common ID
APP_ID="dev.kdrag0n.Ghostty.desktop"
for dir in "$HOME/.local/share/applications" /usr/share/applications; do
  if [ -d "$dir" ]; then
    CANDIDATE=$(grep -RIl "^Exec=.*ghostty" "$dir" 2>/dev/null | head -n1)
    if [ -n "$CANDIDATE" ]; then
      APP_ID="$(basename "$CANDIDATE")"
      break
    fi
  fi
done
KW=kwriteconfig6
if ! command -v kwriteconfig6 >/dev/null 2>&1; then
  if command -v kwriteconfig5 >/dev/null 2>&1; then
    KW=kwriteconfig5
  else
    echo "[ezdora][kde] kwriteconfig não encontrado; não foi possível definir terminal padrão."
    exit 0
  fi
fi

echo "[ezdora][kde] Definindo Ghostty como terminal padrão no KDE..."
$KW --file kdeglobals --group General --key TerminalApplication ghostty
$KW --file kdeglobals --group General --key TerminalService "$APP_ID"

# Also remap Ctrl+Alt+T global shortcut from Konsole to Ghostty
CFG="$HOME/.config/kglobalshortcutsrc"

# Disable Konsole's launch shortcut if present
$KW --file kglobalshortcutsrc --group org.kde.konsole.desktop --key _launch "none,none,Konsole" || true
$KW --file kglobalshortcutsrc --group org.kde.konsole.desktop --key New "none,none,Konsole" || true

# Map Ghostty launch to Ctrl+Alt+T
$KW --file kglobalshortcutsrc --group "$APP_ID" --key _launch "Ctrl+Alt+T,none,Launch Ghostty" || true

# Reload or restart global shortcuts service quietly
if command -v kglobalaccel6 >/dev/null 2>&1; then
  # Prefer --replace; fall back to restart sequence
  nohup kglobalaccel6 --replace >/dev/null 2>&1 & disown || true
elif command -v kglobalaccel5 >/dev/null 2>&1; then
  nohup kglobalaccel5 --replace >/dev/null 2>&1 & disown || true
fi

echo "[ezdora][kde] Terminal padrão e atalho Ctrl+Alt+T ajustados para Ghostty. Se não surtir efeito imediato, relogue."
