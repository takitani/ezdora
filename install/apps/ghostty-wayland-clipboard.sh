#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][clipboard-sync] Configurando sincronização de clipboard Wayland-X11 para Ghostty..."

# Ensure required packages are installed
if ! command -v wl-copy >/dev/null 2>&1; then
  echo "[ezdora][clipboard-sync] Instalando wl-clipboard..."
  sudo dnf install -y wl-clipboard
fi

if ! command -v xclip >/dev/null 2>&1; then
  echo "[ezdora][clipboard-sync] Instalando xclip..."
  sudo dnf install -y xclip
fi

# Configure Ghostty for proper clipboard and image support
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
GHOSTTY_CONFIG="$GHOSTTY_CONFIG_DIR/config"

if command -v ghostty >/dev/null 2>&1; then
  echo "[ezdora][clipboard-sync] Configurando Ghostty para suporte a imagens..."

  mkdir -p "$GHOSTTY_CONFIG_DIR"

  # Add OSC52 and image support if not already present
  if [[ -f "$GHOSTTY_CONFIG" ]]; then
    # Check if configurations already exist
    if ! grep -q "^osc52-read" "$GHOSTTY_CONFIG"; then
      echo "" >> "$GHOSTTY_CONFIG"
      echo "# Enable OSC 52 for clipboard operations" >> "$GHOSTTY_CONFIG"
      echo "osc52-read = true" >> "$GHOSTTY_CONFIG"
      echo "osc52-write = true" >> "$GHOSTTY_CONFIG"
    fi

    if ! grep -q "^images" "$GHOSTTY_CONFIG"; then
      echo "" >> "$GHOSTTY_CONFIG"
      echo "# Enable image support" >> "$GHOSTTY_CONFIG"
      echo "images = true" >> "$GHOSTTY_CONFIG"
    fi
  else
    # Create new config with all necessary settings
    cat > "$GHOSTTY_CONFIG" <<'EOF'
# Enable clipboard support
clipboard-read = allow
clipboard-write = allow
clipboard-paste-protection = false
copy-on-select = clipboard

# Enable OSC 52 for clipboard operations
osc52-read = true
osc52-write = true

# Enable image support
images = true
EOF
  fi

  echo "[ezdora][clipboard-sync] Configuração do Ghostty atualizada"
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
last_wayland_type=""

while true; do
    # Get current clipboard types
    types=$(wl-paste --list-types 2>/dev/null || echo "")

    if [[ -z "$types" ]]; then
        sleep 0.3
        continue
    fi

    # Determine content type
    current_type=""
    if echo "$types" | grep -qi "^image"; then
        current_type="image"
    elif echo "$types" | grep -qi "^text"; then
        current_type="text"
    fi

    # Get content hash to detect changes
    current_hash=$(wl-paste 2>/dev/null | md5sum | cut -d' ' -f1)

    # Check if content changed
    if [[ "$current_hash" != "$last_wayland_content" ]] || [[ "$current_type" != "$last_wayland_type" ]]; then
        case "$current_type" in
            "image")
                # Sync image to X11 clipboard (both as image and save path)
                temp_file="/tmp/clipboard_img_$(date +%s).png"
                wl-paste 2>/dev/null > "$temp_file"

                # Set image in X11 clipboard
                xclip -selection clipboard -t image/png -i "$temp_file" 2>/dev/null

                # Also set the path as text alternative
                echo -n "$temp_file" | xclip -selection clipboard 2>/dev/null &

                echo "$(date): Synced image Wayland -> X11 (saved to $temp_file)"
                ;;
            "text")
                # Sync text to X11 clipboard
                wl-paste -t text 2>/dev/null | xclip -selection clipboard 2>/dev/null
                echo "$(date): Synced text Wayland -> X11"
                ;;
        esac

        last_wayland_content="$current_hash"
        last_wayland_type="$current_type"
    fi

    sleep 0.2
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