#!/usr/bin/env bash
set -euo pipefail

# Only apply on KDE/Plasma sessions
if [[ "${XDG_CURRENT_DESKTOP:-}" != *KDE* && "${XDG_CURRENT_DESKTOP:-}" != *PLASMA* && "${XDG_SESSION_DESKTOP:-}" != *plasma* ]]; then
  echo "[ezdora][kde] Não é uma sessão KDE/Plasma. Pulando configuração."
  exit 0
fi

# Ensure Ghostty is installed
if ! command -v ghostty >/dev/null 2>&1 && ! rpm -q ghostty >/dev/null 2>&1; then
  echo "[ezdora][kde] Ghostty não instalado ainda; adiando configuração do terminal padrão."
  exit 0
fi

# Try to detect Ghostty desktop ID dynamically
APP_ID=""
GHOSTTY_DESKTOP=""
for dir in "$HOME/.local/share/applications" /usr/share/applications /usr/local/share/applications; do
  if [ -d "$dir" ]; then
    for desktop_file in "$dir"/*ghostty*.desktop "$dir"/*Ghostty*.desktop; do
      if [ -f "$desktop_file" ]; then
        APP_ID="$(basename "$desktop_file")"
        GHOSTTY_DESKTOP="$desktop_file"
        echo "[ezdora][kde] Encontrado arquivo desktop: $APP_ID em $dir"
        break 2
      fi
    done
  fi
done

# Fallback to common IDs if not found
if [ -z "$APP_ID" ]; then
  echo "[ezdora][kde] Arquivo .desktop do Ghostty não encontrado, usando ID padrão"
  APP_ID="ghostty.desktop"
fi

# Find kwriteconfig tool
KW=""
for tool in kwriteconfig6 kwriteconfig5; do
  if command -v "$tool" >/dev/null 2>&1; then
    KW="$tool"
    break
  fi
done

if [ -z "$KW" ]; then
  echo "[ezdora][kde] kwriteconfig não encontrado; não foi possível definir terminal padrão."
  exit 1
fi

echo "[ezdora][kde] Usando $KW para configuração"
echo "[ezdora][kde] Definindo Ghostty como terminal padrão no KDE..."

# Set default terminal in multiple places for better coverage
$KW --file kdeglobals --group General --key TerminalApplication "ghostty" || true
$KW --file kdeglobals --group General --key TerminalService "$APP_ID" || true

# Also set in kservices for some KDE versions
$KW --file "$HOME/.config/mimeapps.list" --group "Default Applications" --key "x-scheme-handler/terminal" "$APP_ID" || true

# Update systemsettings terminal config if it exists
if [ -f "$HOME/.config/systemsettingsrc" ]; then
  $KW --file systemsettingsrc --group Defaults --key TerminalApplication "ghostty" || true
fi

echo "[ezdora][kde] Configurando atalho Ctrl+Alt+T para Ghostty..."

# Clear any existing Ctrl+Alt+T shortcuts first
echo "[ezdora][kde] Removendo atalhos existentes de Ctrl+Alt+T..."
for group in org.kde.konsole.desktop konsole.desktop org.kde.yakuake.desktop terminator.desktop; do
  $KW --file kglobalshortcutsrc --group "$group" --key _launch "none,none,none" 2>/dev/null || true
  $KW --file kglobalshortcutsrc --group "$group" --key New "none,none,none" 2>/dev/null || true
done

# Create custom shortcut through System Settings format
echo "[ezdora][kde] Criando atalho customizado para Ghostty..."

# Method 1: Through kglobalshortcutsrc with proper format
$KW --file kglobalshortcutsrc --group "$APP_ID" --key _launch "Ctrl+Alt+T,Ctrl+Alt+T,Ghostty" || true
$KW --file kglobalshortcutsrc --group "$APP_ID" --key _k_friendly_name "Ghostty Terminal" || true

# Method 2: Through custom shortcuts
CUSTOM_GROUP="custom-ghostty-launch"
$KW --file kglobalshortcutsrc --group "$CUSTOM_GROUP" --key "Launch Ghostty" "Ctrl+Alt+T,none,Launch Ghostty Terminal" || true
$KW --file kglobalshortcutsrc --group "$CUSTOM_GROUP" --key "_k_friendly_name" "Custom Shortcuts" || true

# Method 3: Through khotkeysrc for KDE 5
if [ -f "$HOME/.config/khotkeysrc" ] || [ ! -f "$HOME/.config/kglobalshortcutsrc" ]; then
  echo "[ezdora][kde] Configurando através do khotkeys..."
  
  # Create a new hotkey entry
  UUID=$(uuidgen 2>/dev/null || echo "ghostty-$(date +%s)")
  
  $KW --file khotkeysrc --group Data --key DataCount 1 || true
  $KW --file khotkeysrc --group Data_1 --key Comment "Terminal Ghostty" || true
  $KW --file khotkeysrc --group Data_1 --key Enabled true || true
  $KW --file khotkeysrc --group Data_1 --key Name "Launch Ghostty" || true
  $KW --file khotkeysrc --group Data_1 --key Type SIMPLE_ACTION_DATA || true
  
  $KW --file khotkeysrc --group Data_1Conditions --key Comment "" || true
  $KW --file khotkeysrc --group Data_1Conditions --key ConditionsCount 0 || true
  
  $KW --file khotkeysrc --group Data_1Triggers --key Comment "Simple_action" || true
  $KW --file khotkeysrc --group Data_1Triggers --key TriggersCount 1 || true
  
  $KW --file khotkeysrc --group Data_1Triggers0 --key Key "Ctrl+Alt+T" || true
  $KW --file khotkeysrc --group Data_1Triggers0 --key Type SHORTCUT || true
  $KW --file khotkeysrc --group Data_1Triggers0 --key Uuid "{$UUID}" || true
  
  $KW --file khotkeysrc --group Data_1Actions --key ActionsCount 1 || true
  $KW --file khotkeysrc --group Data_1Actions0 --key CommandURL "ghostty" || true
  $KW --file khotkeysrc --group Data_1Actions0 --key Type COMMAND_URL || true
fi

# Method 4: Direct command binding through plasma
if command -v qdbus >/dev/null 2>&1; then
  echo "[ezdora][kde] Registrando atalho via qdbus..."
  qdbus org.kde.kglobalaccel /component/khotkeys org.kde.kglobalaccel.Component.setShortcutContext \
    "Launch Ghostty" "Ctrl+Alt+T" 0 2>/dev/null || true
fi

# Reload shortcuts daemon
echo "[ezdora][kde] Recarregando serviços de atalhos..."
if command -v kquitapp5 >/dev/null 2>&1; then
  kquitapp5 kglobalaccel 2>/dev/null || true
  sleep 1
  kglobalaccel5 2>/dev/null & disown || true
elif command -v kquitapp6 >/dev/null 2>&1; then
  kquitapp6 kglobalaccel 2>/dev/null || true
  sleep 1
  kglobalaccel6 2>/dev/null & disown || true
fi

# Restart khotkeys daemon if exists
pkill -HUP khotkeys 2>/dev/null || true

echo "[ezdora][kde] Terminal padrão definido como Ghostty"
echo "[ezdora][kde] Atalho Ctrl+Alt+T configurado para abrir Ghostty"
echo "[ezdora][kde] NOTA: Pode ser necessário fazer logout/login para atalho funcionar"
