#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][clipboard-sync] Configurando sincronização de clipboard Wayland-X11..."

# Ensure required packages are installed
if ! command -v wl-copy >/dev/null 2>&1; then
  echo "[ezdora][clipboard-sync] Instalando wl-clipboard..."
  sudo dnf install -y wl-clipboard
fi

if ! command -v xclip >/dev/null 2>&1; then
  echo "[ezdora][clipboard-sync] Instalando xclip..."
  sudo dnf install -y xclip
fi

# Create the sync script
SCRIPT_DIR="$HOME/.local/bin"
mkdir -p "$SCRIPT_DIR"

cat > "$SCRIPT_DIR/wayland-x11-clipboard-sync" <<'EOF'
#!/bin/bash
# Sincronizador de clipboard Wayland <-> X11 para KDE Plasma
# Resolve problemas de Ctrl+V em apps GTK/Electron no KDE Wayland

echo "Starting Wayland-X11 clipboard sync..."

# Variáveis para controlar o estado
last_wayland_content=""

while true; do
    # Sincroniza Wayland -> X11 (para imagens)
    if wl-paste --list-types 2>/dev/null | grep -qi "image"; then
        current_wayland=$(wl-paste 2>/dev/null | md5sum)
        if [ "$current_wayland" != "$last_wayland_content" ]; then
            wl-paste 2>/dev/null | xclip -selection clipboard -t image/png 2>/dev/null
            last_wayland_content="$current_wayland"
            echo "$(date): Synced image Wayland -> X11"
        fi
    fi
    
    # Sincroniza texto também
    if wl-paste --list-types 2>/dev/null | grep -qi "text"; then
        current_text=$(wl-paste -t text 2>/dev/null | md5sum)
        if [ "$current_text" != "$last_wayland_content" ]; then
            wl-paste -t text 2>/dev/null | xclip -selection clipboard 2>/dev/null
            last_wayland_content="$current_text"
        fi
    fi
    
    sleep 0.3
done
EOF

chmod +x "$SCRIPT_DIR/wayland-x11-clipboard-sync"

# Create systemd user service for clipboard synchronization
SERVICE_DIR="$HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_DIR/clipboard-sync.service" <<'EOF'
[Unit]
Description=Wayland-X11 Clipboard Sync for KDE
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/home/opik/.local/bin/wayland-x11-clipboard-sync
Restart=always
RestartSec=1

[Install]
WantedBy=default.target
EOF

# Replace /home/opik with actual home path
sed -i "s|/home/opik|$HOME|g" "$SERVICE_DIR/clipboard-sync.service"

# Reload systemd user daemon and enable service
systemctl --user daemon-reload
systemctl --user enable clipboard-sync.service
systemctl --user restart clipboard-sync.service

echo "[ezdora][clipboard-sync] Service configurado e ativado!"
echo "[ezdora][clipboard-sync] Para verificar status: systemctl --user status clipboard-sync"