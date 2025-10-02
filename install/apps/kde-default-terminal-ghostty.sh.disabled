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

echo "[ezdora][kde] Configurando atalho Ctrl+Alt+T para Ghostty..."

# Step 1: Create desktop file for Ghostty if it doesn't exist
DESKTOP_FILE="$HOME/.local/share/applications/ghostty.desktop"
if [ ! -f "$DESKTOP_FILE" ]; then
  mkdir -p "$HOME/.local/share/applications"
  cat > "$DESKTOP_FILE" << 'EOF'
[Desktop Entry]
Exec=/usr/bin/ghostty
Name=Ghostty
Comment=Fast GPU-accelerated terminal emulator
NoDisplay=true
Type=Application
Icon=ghostty
Categories=System;TerminalEmulator;
X-KDE-GlobalAccel-CommandShortcut=true
EOF
  echo "[ezdora][kde] Arquivo desktop criado: $DESKTOP_FILE"
fi

# Step 2: Backup kglobalshortcutsrc before modifications
SHORTCUTS_FILE="$HOME/.config/kglobalshortcutsrc"
if [ -f "$SHORTCUTS_FILE" ] && [ ! -f "$SHORTCUTS_FILE.ezdora.bak" ]; then
  cp "$SHORTCUTS_FILE" "$SHORTCUTS_FILE.ezdora.bak"
  echo "[ezdora][kde] Backup criado: $SHORTCUTS_FILE.ezdora.bak"
fi

# Step 3: Remove/disable Konsole Ctrl+Alt+T shortcut if it exists
if grep -q "org.kde.konsole" "$SHORTCUTS_FILE" 2>/dev/null; then
  # Check if Konsole shortcut is already disabled
  if ! grep -q "_launch=none" "$SHORTCUTS_FILE" 2>/dev/null; then
    # Use sed to disable Konsole shortcut
    sed -i '/\[services\]\[org.kde.konsole.desktop\]/,/^$/s/_launch=.*/_launch=none/' "$SHORTCUTS_FILE" 2>/dev/null || true
    sed -i '/\[org.kde.konsole.desktop\]/,/^$/s/_launch=.*/_launch=none,none,Konsole/' "$SHORTCUTS_FILE" 2>/dev/null || true
    echo "[ezdora][kde] Atalho Ctrl+Alt+T do Konsole desabilitado"
  else
    echo "[ezdora][kde] Atalho do Konsole já está desabilitado"
  fi
fi

# Step 4: Add Ghostty shortcut configuration
# Remove existing broken entries first
sed -i '/\[ghostty.desktop\]/,/^$/d' "$SHORTCUTS_FILE" 2>/dev/null || true
sed -i '/\[services\]\[ghostty.desktop\]/,/^$/d' "$SHORTCUTS_FILE" 2>/dev/null || true

# Add clean Ghostty shortcut configuration
cat >> "$SHORTCUTS_FILE" << 'EOF'

[ghostty.desktop]
_k_friendly_name=Ghostty
_launch=Ctrl+Alt+T,none,Launch Ghostty Terminal
EOF

echo "[ezdora][kde] Atalho Ctrl+Alt+T configurado para Ghostty (limpeza e reconfiguração)"

# Step 5: Restart kglobalaccel to apply changes only if changes were made
CHANGES_MADE=false
if grep -q "_launch=Ctrl+Alt+T,none,Launch Ghostty Terminal" "$SHORTCUTS_FILE" 2>/dev/null; then
  # Only restart if this run made actual changes (check if backup was created this run)
  if [ -f "$SHORTCUTS_FILE.ezdora.bak" ] && [ "$SHORTCUTS_FILE" -nt "$SHORTCUTS_FILE.ezdora.bak" ]; then
    CHANGES_MADE=true
  fi
fi

if [ "$CHANGES_MADE" = true ]; then
  echo "[ezdora][kde] Reiniciando kglobalaccel para aplicar mudanças..."
  killall kglobalaccel5 2>/dev/null || killall kglobalaccel 2>/dev/null || true
  sleep 1
  if command -v kglobalaccel5 >/dev/null 2>&1; then
    kglobalaccel5 &
    disown
  elif command -v kglobalaccel >/dev/null 2>&1; then
    kglobalaccel &
    disown
  fi
else
  echo "[ezdora][kde] Nenhuma mudança necessária, kglobalaccel não reiniciado"
fi

echo "[ezdora][kde] Configuração do atalho concluída!"