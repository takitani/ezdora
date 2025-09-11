#!/usr/bin/env bash
set -euo pipefail

# Configure cedilla/Compose for KDE/Plasma
# - Create ~/.XCompose with explicit cedilla mappings
# - Set Compose key to Right Alt (compose:ralt) persistently for KDE
# - Apply immediately with setxkbmap

echo "[ezdora][kde] Configurando Compose/Cedilha para KDE..."

# 1) XCompose rules (keeps system defaults via %L and adds cedilla helpers)
XCOMPOSE="$HOME/.XCompose"
if [ ! -f "$XCOMPOSE" ] || ! grep -q "EzDora XCompose" "$XCOMPOSE" 2>/dev/null; then
  cat > "$XCOMPOSE" <<'EOF'
# EzDora XCompose — cedilla helpers + keep locale defaults
include "%L"

# Cedilla convenience mappings using Compose (Multi_key)
# Common sequences:
#   Compose + ',' + 'c'  -> ç
#   Compose + '\'' + 'c' -> ç  (apostrophe)
#   Compose + 'c' + '\'' -> ç  (your preferred order)
<Multi_key> <comma> <c>        : "ç" ccedilla
<Multi_key> <comma> <C>        : "Ç" Ccedilla
<Multi_key> <apostrophe> <c>   : "ç" ccedilla
<Multi_key> <apostrophe> <C>   : "Ç" Ccedilla
<Multi_key> <c> <apostrophe>   : "ç" ccedilla
<Multi_key> <C> <apostrophe>   : "Ç" Ccedilla
EOF
  echo "[ezdora][kde] ~/.XCompose criado com mapeamentos de cedilha."
fi

# 2) Persist Compose key to Right Alt in KDE (kxkbrc)
KXK="$HOME/.config/kxkbrc"
mkdir -p "$HOME/.config"

if [ -f "$KXK" ]; then
  if grep -q '^\[Layout\]' "$KXK"; then
    if grep -q '^Options=' "$KXK"; then
      if ! grep -q 'compose:ralt' "$KXK"; then
        sed -i 's/^Options=.*/&\,compose:ralt/' "$KXK"
      fi
    else
      sed -i '/^\[Layout\]/a Options=compose:ralt' "$KXK"
    fi
  else
    {
      echo '[Layout]'
      echo 'Options=compose:ralt'
    } >> "$KXK"
  fi
else
  {
    echo '[Layout]'
    echo 'Options=compose:ralt'
  } > "$KXK"
fi

# 3) Apply for current session (X11); on Wayland may require relogin
if command -v setxkbmap >/dev/null 2>&1; then
  setxkbmap -option compose:ralt || true
fi

echo "[ezdora][kde] Compose em Right Alt ativado. Se algum app não refletir, relogue a sessão."
