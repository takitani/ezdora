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
    # Check for com.mitchellh.ghostty.desktop first (official name)
    if [ -f "$dir/com.mitchellh.ghostty.desktop" ]; then
      APP_ID="com.mitchellh.ghostty.desktop"
      GHOSTTY_DESKTOP="$dir/com.mitchellh.ghostty.desktop"
      echo "[ezdora][kde] Encontrado arquivo desktop: $APP_ID em $dir"
      break
    fi
    # Fallback to pattern matching
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
  APP_ID="com.mitchellh.ghostty.desktop"
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
for group in org.kde.konsole.desktop konsole.desktop org.kde.yakuake.desktop terminator.desktop lazydocker.desktop; do
  $KW --file kglobalshortcutsrc --group "$group" --key _launch "none,none,none" 2>/dev/null || true
  $KW --file kglobalshortcutsrc --group "$group" --key New "none,none,none" 2>/dev/null || true
done

# Also remove from services section
$KW --file kglobalshortcutsrc --group "services" --group "lazydocker.desktop" --key _launch "none" 2>/dev/null || true

# Clean up old custom shortcuts
$KW --file kglobalshortcutsrc --group "custom-ghostty-launch" --deletegroup 2>/dev/null || true

# Method 1: Configure through khotkeysrc (most reliable)
echo "[ezdora][kde] Configurando através do khotkeys..."

# Backup existing khotkeysrc if exists
if [ -f "$HOME/.config/khotkeysrc" ]; then
  cp "$HOME/.config/khotkeysrc" "$HOME/.config/khotkeysrc.bak.$(date +%s)" 2>/dev/null || true
fi

# Create a simple action for Ghostty
UUID=$(uuidgen 2>/dev/null || echo "{$(date +%s)-ghostty}")

# Update main configuration
$KW --file khotkeysrc --group Main --key Disabled false || true
$KW --file khotkeysrc --group Main --key Version 3 || true

# Set data count
$KW --file khotkeysrc --group Data --key DataCount 1 || true

# Configure the action group
$KW --file khotkeysrc --group Data_1 --key Comment "Launch Ghostty Terminal" || true
$KW --file khotkeysrc --group Data_1 --key Enabled true || true
$KW --file khotkeysrc --group Data_1 --key Name "Ghostty Terminal" || true
$KW --file khotkeysrc --group Data_1 --key Type SIMPLE_ACTION_DATA || true

# No conditions needed
$KW --file khotkeysrc --group Data_1Conditions --key Comment "" || true
$KW --file khotkeysrc --group Data_1Conditions --key ConditionsCount 0 || true

# Configure the trigger (Ctrl+Alt+T)
$KW --file khotkeysrc --group Data_1Triggers --key Comment "Simple_action" || true
$KW --file khotkeysrc --group Data_1Triggers --key TriggersCount 1 || true

$KW --file khotkeysrc --group Data_1Triggers0 --key Key "Ctrl+Alt+T" || true
$KW --file khotkeysrc --group Data_1Triggers0 --key Type SHORTCUT || true
$KW --file khotkeysrc --group Data_1Triggers0 --key Uuid "$UUID" || true

# Configure the action (launch ghostty)
$KW --file khotkeysrc --group Data_1Actions --key ActionsCount 1 || true
$KW --file khotkeysrc --group Data_1Actions0 --key CommandURL "ghostty" || true
$KW --file khotkeysrc --group Data_1Actions0 --key Type COMMAND_URL || true

# Method 2: Also set in kglobalshortcutsrc as backup
echo "[ezdora][kde] Configurando em kglobalshortcutsrc..."
$KW --file kglobalshortcutsrc --group khotkeys --key "$UUID" "Ctrl+Alt+T,none,Ghostty Terminal" || true

# Method 3: Through application shortcuts
if [ -n "$APP_ID" ]; then
  $KW --file kglobalshortcutsrc --group "$APP_ID" --key _launch "Ctrl+Alt+T,Ctrl+Alt+T,Launch Ghostty" || true
  $KW --file kglobalshortcutsrc --group "$APP_ID" --key _k_friendly_name "Ghostty Terminal" || true
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
