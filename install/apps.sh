#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Executa todos os scripts de app em ordem alfabética
for script in "$SCRIPT_DIR/apps"/*.sh; do
  [ -f "$script" ] || continue
  echo "[ezdora][app] Executando $(basename "$script")"
  bash "$script"
done

