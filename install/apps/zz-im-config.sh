#!/usr/bin/env bash
set -euo pipefail

# Configure Input Method so ~/.XCompose is honored across apps
# Keeps Fedora defaults (IBus) and exports XCOMPOSEFILE for Wayland/GTK/Qt

echo "[ezdora][im] Configurando Input Method para suporte correto de cedilha..."

# Set up system-wide configuration
if [ -w "/etc/environment.d" ] || sudo -n true 2>/dev/null; then
  echo "[ezdora][im] Configurando Input Method system-wide..."
  sudo mkdir -p /etc/environment.d
  sudo tee "/etc/environment.d/90-ezdora-im.conf" > /dev/null <<EOF
# EzDora Input Method Configuration
# Ensure custom compose file is used by GTK/Qt (X11/Wayland)
XCOMPOSEFILE="${HOME}/.XCompose"
EOF
  echo "[ezdora][im] Configuração system-wide criada em /etc/environment.d/90-ezdora-im.conf"
fi

# Configure for current user's shell
SHELL_CONFIG=""
if [ -f "$HOME/.zshrc" ]; then
  SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_CONFIG="$HOME/.bashrc"
fi

if [ -n "$SHELL_CONFIG" ]; then
  # Check if already configured
  if ! grep -q "# EzDora Input Method" "$SHELL_CONFIG" 2>/dev/null; then
    echo "[ezdora][im] Adicionando configuração ao $SHELL_CONFIG..."
    cat >> "$SHELL_CONFIG" <<'EOF'

# EzDora Input Method Configuration
export XCOMPOSEFILE="$HOME/.XCompose"
EOF
    echo "[ezdora][im] Configuração adicionada ao $SHELL_CONFIG"
  else
    echo "[ezdora][im] Configuração já existe em $SHELL_CONFIG"
  fi
fi

# Configure for KDE session specifically
if [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]] || [[ "$DESKTOP_SESSION" == *"plasma"* ]]; then
  KDE_ENV_FILE="$HOME/.config/plasma-workspace/env/ezdora-im.sh"
  mkdir -p "$(dirname "$KDE_ENV_FILE")"

  cat > "$KDE_ENV_FILE" <<'EOF'
#!/bin/sh
# EzDora Input Method Configuration for KDE
export XCOMPOSEFILE="$HOME/.XCompose"
EOF
  chmod +x "$KDE_ENV_FILE"
  echo "[ezdora][im] Configuração criada para sessão KDE em $KDE_ENV_FILE"
fi

echo "[ezdora][im] Configuração completa!"
echo "[ezdora][im] IMPORTANTE: Faça logout e login novamente para aplicar as mudanças"
echo "[ezdora][im] Após o login, as sequências de compose serão respeitadas nos navegadores"
