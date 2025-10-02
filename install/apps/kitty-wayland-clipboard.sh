#!/usr/bin/env bash
set -euo pipefail

# Only apply on Wayland sessions
if [[ "${XDG_SESSION_TYPE:-}" != "wayland" ]]; then
  echo "[ezdora][kitty] Não é uma sessão Wayland. Pulando configuração."
  exit 0
fi

# Ensure Kitty is installed
if ! command -v kitty >/dev/null 2>&1; then
  echo "[ezdora][kitty] Kitty não instalado; pulando configuração."
  exit 0
fi

# Ensure clip2path script exists
if [ ! -f "$HOME/.local/bin/clip2path" ]; then
  echo "[ezdora][kitty] Script clip2path não encontrado. Execute kitty-clip2path-setup.sh primeiro."
  exit 0
fi

KITTY_CONF="$HOME/.config/kitty/kitty.conf"

echo "[ezdora][kitty] Configurando kitty.conf para suporte a clipboard de imagem..."

# Create config directory if it doesn't exist
mkdir -p "$HOME/.config/kitty"

# Backup existing config
if [ -f "$KITTY_CONF" ]; then
  if [ ! -f "$KITTY_CONF.ezdora.bak" ]; then
    cp "$KITTY_CONF" "$KITTY_CONF.ezdora.bak"
    echo "[ezdora][kitty] Backup criado: $KITTY_CONF.ezdora.bak"
  fi
fi

# Check if configuration already exists
if grep -q "allow_remote_control yes" "$KITTY_CONF" 2>/dev/null && \
   grep -q "clip2path" "$KITTY_CONF" 2>/dev/null; then
  echo "[ezdora][kitty] Configuração de clipboard já presente."
  exit 0
fi

# Add configuration
cat >> "$KITTY_CONF" << 'EOF'

# Configuração para suporte a paste de imagem (clipboard)
# Ref: https://github.com/anthropics/claude-code/issues/834#issuecomment-2907685247
allow_remote_control yes

map ctrl+v launch --type=background --allow-remote-control --keep-focus ~/.local/bin/clip2path
EOF

echo "[ezdora][kitty] Configuração de clipboard adicionada ao kitty.conf"
echo "[ezdora][kitty] Reinicie o Kitty para aplicar as mudanças."
