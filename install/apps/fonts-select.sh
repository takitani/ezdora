#!/usr/bin/env bash
set -euo pipefail

# Offer a choice of installed mono fonts and set Ghostty font-family accordingly.

echo "[ezdora][fonts] Selecionando fonte do terminal..."

# Candidate font names to look for
declare -a CANDIDATES=(
  "CaskaydiaMono Nerd Font"
  "JetBrainsMono Nerd Font"
  "iA Writer Mono S"
)

# Build available list via fc-list
mapfile -t FCLIST < <(fc-list : family | tr ',' '\n' | sed 's/^\s\+//; s/\s\+$//' | sort -u)
AVAILABLE=()
for name in "${CANDIDATES[@]}"; do
  if printf '%s\n' "${FCLIST[@]}" | grep -Fxq "$name"; then
    AVAILABLE+=("$name")
  fi
done

if [ ${#AVAILABLE[@]} -eq 0 ]; then
  echo "[ezdora][fonts] Nenhuma das fontes candidatas foi encontrada. Pulando seleção."
  exit 0
fi

DEFAULT_CHOICE=${AVAILABLE[0]}
CHOICE=""

if command -v gum >/dev/null 2>&1; then
  CHOICE=$(gum choose --header "Selecione a fonte do terminal" --selected "$DEFAULT_CHOICE" "${AVAILABLE[@]}")
elif command -v fzf >/dev/null 2>&1; then
  CHOICE=$(printf '%s\n' "${AVAILABLE[@]}" | FZF_DEFAULT_OPTS='--height=10 --prompt="Fonte> "' fzf || true)
fi

if [ -z "${CHOICE:-}" ]; then
  CHOICE="$DEFAULT_CHOICE"
  echo "[ezdora][fonts] Usando fonte padrão: $CHOICE"
else
  echo "[ezdora][fonts] Fonte selecionada: $CHOICE"
fi

# Configure Ghostty to use the selected font
CFG_DIR="$HOME/.config/ghostty"
CFG_FILE="$CFG_DIR/config"
mkdir -p "$CFG_DIR"

if [ -f "$CFG_FILE" ] && grep -q '^font-family\s*=\s*' "$CFG_FILE"; then
  sed -i "s/^font-family\s*=.*/font-family = \"$CHOICE\"/" "$CFG_FILE"
else
  echo "font-family = \"$CHOICE\"" >> "$CFG_FILE"
fi

echo "[ezdora][fonts] Ghostty configurado para usar: $CHOICE"

