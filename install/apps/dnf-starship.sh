#!/usr/bin/env bash
set -euo pipefail
rpm -q starship >/dev/null 2>&1 || sudo dnf install -y starship || {
  echo "[ezdora][starship] Pacote não encontrado no DNF padrão. Você pode instalar via script oficial: https://starship.rs/"
}

