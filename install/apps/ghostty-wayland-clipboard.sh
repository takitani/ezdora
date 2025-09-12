#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][ghostty-clipboard] Configurando correção de clipboard para Ghostty no Wayland..."

# Ensure wl-clipboard is installed
if ! command -v wl-copy >/dev/null 2>&1; then
  echo "[ezdora][ghostty-clipboard] Instalando wl-clipboard..."
  sudo dnf install -y wl-clipboard
fi

# Create systemd user service for clipboard synchronization
SERVICE_DIR="$HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_DIR/ghostty-clipboard-sync.service" <<'EOF'
[Unit]
Description=Ghostty Wayland Clipboard Synchronization
After=graphical-session.target

[Service]
Type=simple
Restart=always
RestartSec=1
ExecStart=/usr/bin/bash -c 'while true; do wl-paste --watch cat; done'
StandardOutput=null
StandardError=journal

[Install]
WantedBy=default.target
EOF

# Enable OSC-52 in Ghostty config for clipboard integration
CFG_DIR="$HOME/.config/ghostty"
CFG_FILE="$CFG_DIR/config"
mkdir -p "$CFG_DIR"

if [ -f "$CFG_FILE" ]; then
  # Backup existing config
  cp "$CFG_FILE" "${CFG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  
  # Add OSC-52 settings if not present
  if ! grep -q "osc-52-clipboard-read" "$CFG_FILE"; then
    echo "osc-52-clipboard-read = allow" >> "$CFG_FILE"
  fi
  
  if ! grep -q "osc-52-clipboard-write" "$CFG_FILE"; then
    echo "osc-52-clipboard-write = allow" >> "$CFG_FILE"
  fi
  
  if ! grep -q "clipboard-read" "$CFG_FILE"; then
    echo "clipboard-read = allow" >> "$CFG_FILE"
  fi
  
  if ! grep -q "clipboard-write" "$CFG_FILE"; then
    echo "clipboard-write = allow" >> "$CFG_FILE"
  fi
else
  # Create new config with clipboard settings
  cat > "$CFG_FILE" <<'EOF'
# Ghostty Wayland Clipboard Configuration
osc-52-clipboard-read = allow
osc-52-clipboard-write = allow
clipboard-read = allow
clipboard-write = allow
EOF
fi

# Reload systemd user daemon and enable service
systemctl --user daemon-reload
systemctl --user enable ghostty-clipboard-sync.service
systemctl --user restart ghostty-clipboard-sync.service

echo "[ezdora][ghostty-clipboard] Service configurado e ativado!"
echo "[ezdora][ghostty-clipboard] Para verificar status: systemctl --user status ghostty-clipboard-sync"
echo "[ezdora][ghostty-clipboard] OSC-52 habilitado no Ghostty para suporte a clipboard"