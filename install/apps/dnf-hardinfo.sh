#!/usr/bin/env bash
set -euo pipefail

if rpm -q hardinfo >/dev/null 2>&1; then
  exit 0
fi

echo "[ezdora][hardinfo] Instalando hardinfo (se disponível)..."
if ! sudo dnf install -y hardinfo; then
  echo "[ezdora][hardinfo] Pacote 'hardinfo' não disponível neste Fedora. Ignorando."
fi

