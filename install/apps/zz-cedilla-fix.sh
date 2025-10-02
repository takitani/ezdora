#!/usr/bin/env bash
set -euo pipefail

# Cedilla fix for US-International users.
# Creates a minimal ~/.XCompose that includes the system compose table
# and overrides apostrophe+'c' to type cedilla (ç/Ç). This approach works
# on X11 and Wayland (libxkbcommon) and avoids heavy system-wide changes.

USER_COMPOSE="$HOME/.XCompose"

# Backup existing file once
if [ -s "${USER_COMPOSE}" ] && ! grep -q "EzDora XCompose" "${USER_COMPOSE}" 2>/dev/null; then
  cp -f "${USER_COMPOSE}" "${USER_COMPOSE}.ORIGINAL"
fi

# Write a minimal XCompose that includes the system table first
# and then our overrides (placed AFTER the include so they take precedence
# for implementations where the last rule wins).
cat > "${USER_COMPOSE}" <<'EOF_XCOMPOSE'
# EzDora XCompose
include "%L"

# Prefer cedilla with apostrophe + c (US-International users)
<dead_acute> <c> : "ç" ccedilla
<dead_acute> <C> : "Ç" Ccedilla
EOF_XCOMPOSE

# Hint environment so Wayland/GTK/Chrome pick this file up
# 1) Per-user environment (recommended, no sudo). This is what apps launched from the menu inherit.
USER_ENV_DIR="$HOME/.config/environment.d"
USER_ENV_FILE="$USER_ENV_DIR/90-ezdora-im.conf"
mkdir -p "$USER_ENV_DIR"
cat > "$USER_ENV_FILE" <<EOF_IM_USER
# EzDora Input Method Configuration (per-user)
# Ensure custom compose file is used by Xlib/GTK (XCOMPOSEFILE)
# and libxkbcommon/Wayland (XKB_DEFAULT_COMPOSE_FILE)
XCOMPOSEFILE="${USER_COMPOSE}"
XKB_DEFAULT_COMPOSE_FILE="${USER_COMPOSE}"
# Force GTK to use 'cedilla' IM for Chrome/Edge to respect XCompose
GTK_IM_MODULE=cedilla
EOF_IM_USER
echo "[ezdora][cedilla] Ambiente por usuário atualizado: $USER_ENV_FILE"

# 2) Optional system-wide environment (requires sudo). Useful for multi-user setups.
IM_CONFIG_FILE="/etc/environment.d/90-ezdora-im.conf"
if { [ -w "/etc/environment.d" ] || sudo -n true; } 2>/dev/null; then
  echo "[ezdora][cedilla] Publicando variáveis no ambiente do sistema..."
  sudo mkdir -p /etc/environment.d
  sudo tee "${IM_CONFIG_FILE}" > /dev/null <<EOF_IM_SYS
# EzDora Input Method Configuration (system-wide)
XCOMPOSEFILE="${USER_COMPOSE}"
XKB_DEFAULT_COMPOSE_FILE="${USER_COMPOSE}"
GTK_IM_MODULE=cedilla
EOF_IM_SYS
  echo "[ezdora][cedilla] Variáveis configuradas em ${IM_CONFIG_FILE}"
fi

# Configure Chrome and Edge to use X11 for proper cedilla support
echo "[ezdora][cedilla] Configurando Chrome e Edge para usar X11..."

# Function to update desktop file with X11 flag
update_browser_x11() {
  local desktop_file="$1"
  local browser_name="$2"
  local user_desktop_dir="$HOME/.local/share/applications"

  if [ -f "$desktop_file" ]; then
    mkdir -p "$user_desktop_dir"
    local user_desktop_file="$user_desktop_dir/$(basename "$desktop_file")"

    # Check if user desktop file already exists and has our modifications
    if [ -f "$user_desktop_file" ] && grep -q "ozone-platform=x11" "$user_desktop_file" 2>/dev/null; then
      echo "[ezdora][cedilla] $browser_name já configurado para X11"
    else
      # Copy system desktop file to user directory
      cp "$desktop_file" "$user_desktop_file"

      # Add --ozone-platform=x11 to all Exec lines that don't already have it
      sed -i 's|^Exec=/usr/bin/\([^[:space:]]*\)\(.*\)|Exec=/usr/bin/\1 --ozone-platform=x11\2|g' "$user_desktop_file"

      # Handle lines that already have flags but not ozone-platform
      sed -i '/ozone-platform=x11/!s|^Exec=/usr/bin/\([^[:space:]]*\) --|Exec=/usr/bin/\1 --ozone-platform=x11 --|g' "$user_desktop_file"

      echo "[ezdora][cedilla] $browser_name configurado para usar X11"
      echo "[ezdora][cedilla] Arquivo criado: $user_desktop_file"
    fi
  fi
}

# Update Chrome
if command -v google-chrome-stable >/dev/null 2>&1; then
  update_browser_x11 "/usr/share/applications/google-chrome.desktop" "Google Chrome"
fi

# Update Edge
if command -v microsoft-edge-stable >/dev/null 2>&1; then
  update_browser_x11 "/usr/share/applications/microsoft-edge.desktop" "Microsoft Edge"
fi

# Update desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

echo "[ezdora][cedilla] ~/.XCompose criado/atualizado. Faça logout/login para aplicar (ou reinicie a sessão)."
echo "[ezdora][cedilla] Chrome e Edge configurados para usar X11 (suporte completo a cedilha)."
echo "[ezdora][cedilla] Teste rápido (sem logout): execute abaixo num terminal e digite ' + c em uma caixa de texto:"
echo "  env XCOMPOSEFILE=\"${USER_COMPOSE}\" XKB_DEFAULT_COMPOSE_FILE=\"${USER_COMPOSE}\" GTK_IM_MODULE=cedilla google-chrome-stable --ozone-platform=x11"
echo "  env XCOMPOSEFILE=\"${USER_COMPOSE}\" XKB_DEFAULT_COMPOSE_FILE=\"${USER_COMPOSE}\" GTK_IM_MODULE=cedilla microsoft-edge-stable --ozone-platform=x11"
