#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR"

# Create LazyDocker icons in hicolor theme structure
echo "[ezdora][lazydocker] Criando ícones oficiais em todos os tamanhos..."

# Create hicolor icon theme directories
HICOLOR_DIR="$HOME/.local/share/icons/hicolor"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Create directory structure and install icons
for size in 16x16 32x32 48x48 64x64; do
  TARGET_DIR="$HICOLOR_DIR/${size}/apps"
  mkdir -p "$TARGET_DIR"
  
  ICON_FILE="$TARGET_DIR/lazydocker.png"
  if [ ! -f "$ICON_FILE" ]; then
    echo "[ezdora][lazydocker] Instalando ícone ${size}..."
    if [ -f "$SCRIPT_DIR/assets/icons/lazydocker/${size}.base64" ]; then
      base64 -d "$SCRIPT_DIR/assets/icons/lazydocker/${size}.base64" > "$ICON_FILE"
    fi
  fi
done

# Update icon cache
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache "$HICOLOR_DIR" >/dev/null 2>&1 || true
fi

# Find lazydocker installation path
LAZYDOCKER_PATH="$(which lazydocker 2>/dev/null || echo "")"
if [ -z "$LAZYDOCKER_PATH" ]; then
  echo "[ezdora][lazydocker] Erro: lazydocker não encontrado no PATH"
  exit 1
fi

# Choose terminal: prefer Ghostty, fallback to Konsole
EXEC_CMD="$LAZYDOCKER_PATH"
if command -v ghostty >/dev/null 2>&1; then
  EXEC_CMD="ghostty --class=LazyDocker --title=LazyDocker -e $LAZYDOCKER_PATH"
elif command -v konsole >/dev/null 2>&1; then
  EXEC_CMD="konsole -e $LAZYDOCKER_PATH"
fi

cat > "$APP_DIR/lazydocker.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=LazyDocker
Comment=Simple TUI for docker and docker-compose
Exec=$EXEC_CMD
TryExec=$LAZYDOCKER_PATH
Terminal=false
Categories=System;Utility;Development;
StartupNotify=false
Icon=lazydocker
EOF

update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true

echo "[ezdora][lazydocker] Desktop entry criado em $APP_DIR/lazydocker.desktop"