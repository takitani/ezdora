#!/usr/bin/env bash
set -euo pipefail

# Install Cursor editor from official RPM.

if command -v cursor >/dev/null 2>&1; then
  echo "[ezdora][cursor] Já instalado. Pulando."
  exit 0
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
cd "$tmpdir"

URL="${CURSOR_RPM_URL:-https://downloader.cursor.sh/linux/rpm}"
OUT="cursor-latest.rpm"

echo "[ezdora][cursor] Baixando RPM do Cursor..."
if ! curl -fL --retry 3 --connect-timeout 10 -A "Mozilla/5.0" -o "$OUT" "$URL"; then
  echo "[ezdora][cursor] Falha ao baixar de $URL" >&2
  echo "[ezdora][cursor] Dica: export CURSOR_RPM_URL=\"<URL diretas do .rpm>\" e reexecute este script." >&2
  exit 1
fi

# Sanity check: ensure it's an RPM file
if ! file "$OUT" | grep -qi 'RPM'; then
  echo "[ezdora][cursor] O arquivo baixado não parece ser um RPM válido." >&2
  exit 1
fi

echo "[ezdora][cursor] Instalando..."
sudo dnf install -y "$OUT"

echo "[ezdora][cursor] Concluído. Execute com 'cursor'."

