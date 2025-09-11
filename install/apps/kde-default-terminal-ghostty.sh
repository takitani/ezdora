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
    # Avoid set -e with pipefail when grep finds nothing
    CANDIDATE=$( (grep -RIl "^Exec=.*ghostty" "$dir" 2>/dev/null || true) | head -n1 )
    if [ -n "${CANDIDATE:-}" ]; then
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
$KW --file kdeglobals --group General --key TerminalApplication ghostty || true
$KW --file kdeglobals --group General --key TerminalService "$APP_ID" || true

# Also remap Ctrl+Alt+T global shortcut from Konsole to Ghostty
CFG="$HOME/.config/kglobalshortcutsrc"

# Disable Konsole's launch shortcut if present
$KW --file kglobalshortcutsrc --group org.kde.konsole.desktop --key _launch "none,none,Konsole" || true
$KW --file kglobalshortcutsrc --group org.kde.konsole.desktop --key New "none,none,Konsole" || true

# Map Ghostty launch to Ctrl+Alt+T with correct format
# Format: shortcut,backup_shortcut,description
$KW --file kglobalshortcutsrc --group "$APP_ID" --key _launch "Ctrl+Alt+T,Ctrl+Alt+T,Launch Ghostty" || true

# Also add a custom shortcut as backup method
$KW --file khotkeysrc --group Data --key DataCount 1 || true
$KW --file khotkeysrc --group Data_1 --key Comment "Launch Ghostty Terminal" || true
$KW --file khotkeysrc --group Data_1 --key Enabled true || true
$KW --file khotkeysrc --group Data_1 --key Name "Ghostty" || true
$KW --file khotkeysrc --group Data_1 --key Type SIMPLE_ACTION_DATA || true

$KW --file khotkeysrc --group Data_1Conditions --key Comment "" || true
$KW --file khotkeysrc --group Data_1Conditions --key ConditionsCount 0 || true

$KW --file khotkeysrc --group Data_1Triggers --key Comment "Simple_action" || true
$KW --file khotkeysrc --group Data_1Triggers --key TriggersCount 1 || true

$KW --file khotkeysrc --group Data_1Triggers0 --key Key "Ctrl+Alt+T" || true
$KW --file khotkeysrc --group Data_1Triggers0 --key Type SHORTCUT || true
$KW --file khotkeysrc --group Data_1Triggers0 --key Uuid "{$(uuidgen 2>/dev/null || echo "00000000-0000-0000-0000-000000000001")}" || true

$KW --file khotkeysrc --group Data_1Actions --key ActionsCount 1 || true
$KW --file khotkeysrc --group Data_1Actions0 --key CommandURL "ghostty" || true
$KW --file khotkeysrc --group Data_1Actions0 --key Type COMMAND_URL || true

# Reload or restart global shortcuts service quietly
if command -v kglobalaccel6 >/dev/null 2>&1; then
  # Stop existing service
  killall kglobalaccel6 2>/dev/null || true
  sleep 0.5
  # Start new instance
  nohup kglobalaccel6 >/dev/null 2>&1 & disown || true
elif command -v kglobalaccel5 >/dev/null 2>&1; then
  killall kglobalaccel5 2>/dev/null || true
  sleep 0.5
  nohup kglobalaccel5 >/dev/null 2>&1 & disown || true
fi

# Also restart khotkeys if running
if pgrep -x khotkeys >/dev/null 2>&1; then
  killall khotkeys 2>/dev/null || true
  sleep 0.5
  nohup khotkeys >/dev/null 2>&1 & disown || true
fi

echo "[ezdora][kde] Terminal padrão e atalho Ctrl+Alt+T ajustados para Ghostty. Se não surtir efeito imediato, relogue."
