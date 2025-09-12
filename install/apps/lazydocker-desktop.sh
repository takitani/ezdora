#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
mkdir -p "$APP_DIR" "$ICON_DIR"

# Download and resize LazyDocker official icon
ICON_PATH="$ICON_DIR/lazydocker.png"
if [ ! -f "$ICON_PATH" ]; then
  echo "[ezdora][lazydocker] Baixando e redimensionando ícone oficial..."
  TEMP_ICON="/tmp/lazydocker_original.png"
  
  if command -v curl >/dev/null 2>&1; then
    if curl -fsSL "https://user-images.githubusercontent.com/8456633/59972109-8e9c8480-95cc-11e9-8350-38f7f86ba76d.png" -o "$TEMP_ICON" 2>/dev/null; then
      # Try to resize with available tools
      if command -v convert >/dev/null 2>&1; then
        convert "$TEMP_ICON" -resize 64x64 "$ICON_PATH" 2>/dev/null
      elif command -v magick >/dev/null 2>&1; then
        magick "$TEMP_ICON" -resize 64x64 "$ICON_PATH" 2>/dev/null
      else
        # Fallback: just copy the original (will be larger but works)
        cp "$TEMP_ICON" "$ICON_PATH" 2>/dev/null
      fi
      rm -f "$TEMP_ICON"
    else
      echo "[ezdora][lazydocker] Falha ao baixar ícone, usando fallback"
      ICON_PATH="utilities-terminal"
    fi
  else
    echo "[ezdora][lazydocker] curl não disponível, usando ícone padrão"
    ICON_PATH="utilities-terminal"
  fi
else
  echo "[ezdora][lazydocker] Ícone já existe: $ICON_PATH"
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
Icon=$ICON_PATH
EOF

update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true

echo "[ezdora][lazydocker] Desktop entry criado em $APP_DIR/lazydocker.desktop"

