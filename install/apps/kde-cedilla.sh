#!/usr/bin/env bash
set -euo pipefail

# Configure cedilla/Compose for KDE/Plasma
# - Create ~/.XCompose with explicit cedilla mappings
# - Set Compose key to Caps Lock (compose:caps) persistently for KDE
# - Apply immediately with setxkbmap

echo "[ezdora][kde] Configurando Compose/Cedilha para KDE..."

# 1) XCompose rules (keeps system defaults via %L and adds cedilla helpers)
XCOMPOSE="$HOME/.XCompose"
if [ ! -f "$XCOMPOSE" ] || ! grep -q "EzDora XCompose" "$XCOMPOSE" 2>/dev/null; then
  cat > "$XCOMPOSE" <<'EOF'
# EzDora XCompose — cedilla helpers + keep locale defaults
include "%L"

# Cedilla convenience mappings using Compose (Multi_key)
<Multi_key> <comma> <c> : "ç" ccedilla
<Multi_key> <comma> <C> : "Ç" Ccedilla
EOF
  echo "[ezdora][kde] ~/.XCompose criado com mapeamentos de cedilha."
fi

# 2) Persist Compose key to Caps in KDE (kxkbrc)
KXK="$HOME/.config/kxkbrc"
mkdir -p "$HOME/.config"

if [ -f "$KXK" ]; then
  if grep -q '^\[Layout\]' "$KXK"; then
    if grep -q '^Options=' "$KXK"; then
      if ! grep -q 'compose:caps' "$KXK"; then
        sed -i 's/^Options=.*/&\,compose:caps/' "$KXK"
      fi
    else
      sed -i '/^\[Layout\]/a Options=compose:caps' "$KXK"
    fi
  else
    {
      echo '[Layout]'
      echo 'Options=compose:caps'
    } >> "$KXK"
  fi
else
  {
    echo '[Layout]'
    echo 'Options=compose:caps'
  } > "$KXK"
fi

# 3) Apply for current session (X11); on Wayland may require relogin
if command -v setxkbmap >/dev/null 2>&1; then
  setxkbmap -option compose:caps || true
fi

echo "[ezdora][kde] Compose em Caps ativado. Se algum app não refletir, relogue a sessão."

