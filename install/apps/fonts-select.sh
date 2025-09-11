#!/usr/bin/env bash
set -euo pipefail

# Offer a choice of installed mono fonts and set Ghostty font-family accordingly.

echo "[ezdora][fonts] Configurando fonte do terminal..."

CFG_DIR="$HOME/.config/ghostty"
CFG_FILE="$CFG_DIR/config"
mkdir -p "$CFG_DIR"

# Detect current config
CURRENT_FAMILY=""
CURRENT_SIZE=""
if [ -f "$CFG_FILE" ]; then
  CURRENT_FAMILY=$(grep -E '^font-family\s*=\s*"' "$CFG_FILE" | sed -E 's/^font-family\s*=\s*"(.*)"/\1/' | head -n1 || true)
  CURRENT_SIZE=$(grep -E '^font-size\s*=\s*[0-9]+' "$CFG_FILE" | sed -E 's/^font-size\s*=\s*([0-9]+).*/\1/' | head -n1 || true)
fi

# If a config already exists, ask to keep; default is keep if no TUI picker available
if [ -n "$CURRENT_FAMILY" ] || [ -n "$CURRENT_SIZE" ]; then
  KEEP=1
  if command -v gum >/dev/null 2>&1; then
    if gum confirm "Manter fonte atual '$CURRENT_FAMILY' tamanho ${CURRENT_SIZE:-?}?"; then KEEP=1; else KEEP=0; fi
  elif command -v fzf >/dev/null 2>&1; then
    # crude confirm via fzf
    sel=$(printf 'Manter\nAlterar\n' | FZF_DEFAULT_OPTS='--height=5 --prompt="Fonte> "' fzf || true)
    [ "$sel" = "Alterar" ] && KEEP=0 || KEEP=1
  fi
  if [ $KEEP -eq 1 ]; then
    echo "[ezdora][fonts] Mantendo fonte atual."
    exit 0
  fi
fi

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
if [ -f "$CFG_FILE" ] && grep -q '^font-family\s*=\s*' "$CFG_FILE"; then
  sed -i "s/^font-family\s*=.*/font-family = \"$CHOICE\"/" "$CFG_FILE"
else
  echo "font-family = \"$CHOICE\"" >> "$CFG_FILE"
fi

# Font size selection
SIZES=("11" "12" "13" "14" "15" "16")
SIZE_DEFAULT="13"
SIZE_CHOICE=""

if command -v gum >/dev/null 2>&1; then
  SIZE_CHOICE=$(gum choose --header "Selecione o tamanho da fonte" --selected "$SIZE_DEFAULT" "${SIZES[@]}")
elif command -v fzf >/dev/null 2>&1; then
  SIZE_CHOICE=$(printf '%s\n' "${SIZES[@]}" | FZF_DEFAULT_OPTS='--height=10 --prompt="Tamanho> "' fzf || true)
fi

if [ -z "${SIZE_CHOICE:-}" ]; then
  SIZE_CHOICE="$SIZE_DEFAULT"
fi

if [ -f "$CFG_FILE" ] && grep -q '^font-size\s*=\s*' "$CFG_FILE"; then
  sed -i "s/^font-size\s*=.*/font-size = $SIZE_CHOICE/" "$CFG_FILE"
else
  echo "font-size = $SIZE_CHOICE" >> "$CFG_FILE"
fi

echo "[ezdora][fonts] Ghostty configurado com fonte '$CHOICE' tamanho $SIZE_CHOICE"
