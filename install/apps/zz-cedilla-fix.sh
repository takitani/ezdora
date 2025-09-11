#!/usr/bin/env bash
set -euo pipefail

# Minimal cedilla fix based on:
# https://raw.githubusercontent.com/marcopaganini/gnome-cedilla-fix/master/fix-cedilla
# Works across desktops (KDE/GNOME). Creates ~/.XCompose mapping 'c with acute' → cedilla.

LANG=${LANG:=en_US.UTF-8}
COMPOSE_DIR="/usr/share/X11/locale"
USER_COMPOSE="$HOME/.XCompose"

compose_file=$(sed -ne "s/^\([^:]*\):[ \t]*${LANG}/\1/p" <"${COMPOSE_DIR}/compose.dir" | head -1)
if [ -z "${compose_file:-}" ] || [ ! -s "${COMPOSE_DIR}/${compose_file}" ]; then
  echo "[ezdora][cedilla] Não foi possível localizar Compose para LANG='${LANG}'." >&2
  exit 1
fi

SYSTEM_COMPOSE="${COMPOSE_DIR}/${compose_file}"

if [ -s "${USER_COMPOSE}" ]; then
  cp -f "${USER_COMPOSE}" "${USER_COMPOSE}.ORIGINAL"
fi

# Replace accented-c (ć/Ć) with cedilla (ç/Ç)
sed -e 's/\\xc4\\x87/\\xc3\\xa7/g' \
    -e 's/\\xc4\\x86/\\xc3\\x87/g' <"${SYSTEM_COMPOSE}" >"${USER_COMPOSE}"

# Ensure dead_acute sequences also produce cedilla without needing a Compose key
cat >> "${USER_COMPOSE}" <<'EOF_EZDORA_CEDILLA'

# EzDora cedilla mappings for apostrophe dead key
<dead_acute> <c> : "ç" ccedilla
<dead_acute> <C> : "Ç" Ccedilla
<c> <dead_acute> : "ç" ccedilla
<C> <dead_acute> : "Ç" Ccedilla
EOF_EZDORA_CEDILLA

echo "[ezdora][cedilla] ~/.XCompose atualizado. Faça logout/login para aplicar."
