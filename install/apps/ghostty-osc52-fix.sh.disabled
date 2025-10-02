#!/usr/bin/env bash
set -euo pipefail

# Fix Ghostty OSC-52 config values: convert true/false to allow/deny

CFG_DIR="$HOME/.config/ghostty"
CFG_FILE="$CFG_DIR/config"

if [ ! -f "$CFG_FILE" ]; then
  echo "[ezdora][ghostty] Config não encontrado em $CFG_FILE; nada a ajustar."
  exit 0
fi

TMP_FILE="${CFG_FILE}.tmp.ezdora"
cp "$CFG_FILE" "$TMP_FILE"

# Fix OSC-52 values: true -> allow, false -> deny
sed -i \
  -e 's/^\s*\(osc-52-clipboard-read\s*=\s*\)true\s*$/\1allow/' \
  -e 's/^\s*\(osc-52-clipboard-read\s*=\s*\)false\s*$/\1deny/' \
  -e 's/^\s*\(osc-52-clipboard-write\s*=\s*\)true\s*$/\1allow/' \
  -e 's/^\s*\(osc-52-clipboard-write\s*=\s*\)false\s*$/\1deny/' \
  "$TMP_FILE"

if cmp -s "$CFG_FILE" "$TMP_FILE"; then
  rm -f "$TMP_FILE"
  echo "[ezdora][ghostty] Nenhum valor osc-52 true/false encontrado; nada a fazer."
  exit 0
fi

mv "$TMP_FILE" "$CFG_FILE"
echo "[ezdora][ghostty] Corrigidos valores OSC-52: true -> allow, false -> deny"

