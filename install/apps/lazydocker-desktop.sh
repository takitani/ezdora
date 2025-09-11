#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR"

# Choose terminal: prefer Ghostty, fallback to Konsole
EXEC_CMD="lazydocker"
if command -v ghostty >/dev/null 2>&1; then
  EXEC_CMD="ghostty --class=LazyDocker --title=LazyDocker -e lazydocker"
elif command -v konsole >/dev/null 2>&1; then
  EXEC_CMD="konsole -e lazydocker"
fi

cat > "$APP_DIR/lazydocker.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=LazyDocker
Comment=Simple TUI for docker and docker-compose
Exec=$EXEC_CMD
TryExec=lazydocker
Terminal=false
Categories=System;Utility;Development;
StartupNotify=false
Icon=utilities-terminal
EOF

update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true

echo "[ezdora][lazydocker] Desktop entry criado em $APP_DIR/lazydocker.desktop"

