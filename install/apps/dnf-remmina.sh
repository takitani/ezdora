#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][dnf-remmina] Instalando Remmina (RDP)…"

# Instala Remmina somente se não estiver presente
if ! rpm -q remmina >/dev/null 2>&1; then
  sudo dnf install -y remmina || {
    echo "[ezdora][dnf-remmina] Falha ao instalar remmina" >&2
    exit 1
  }
else
  echo "[ezdora][dnf-remmina] remmina já instalado"
fi

# FreeRDP (cliente RDP usado por Remmina)
if ! rpm -q freerdp >/dev/null 2>&1; then
  sudo dnf install -y freerdp || true
fi

echo "[ezdora][dnf-remmina] Concluído. Abra o Remmina para testar conexões RDP."

