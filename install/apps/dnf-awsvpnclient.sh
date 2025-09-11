#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][dnf-awsvpnclient] Instalando AWS VPN Client (Fedora)…"

is_installed() {
  rpm -qa | grep -qiE 'aws.*vpn.*client' \
    || [ -d "/opt/awsvpnclient" ] \
    || [ -f "/usr/share/applications/awsvpnclient.desktop" ] \
    || [ -f "/usr/share/applications/AWS VPN Client.desktop" ]
}

if is_installed; then
  echo "[ezdora][dnf-awsvpnclient] AWS VPN Client já instalado"
  exit 0
fi

# URL oficial (AWS CloudFront)
AWS_VPN_RPM_URL="${AWS_VPN_RPM_URL:-https://d20adtppz83p9s.cloudfront.net/GTK/latest/x86_64/AWS_VPN_Client.rpm}"

# Dependências comuns (best-effort)
sudo dnf install -y libappindicator-gtk3 || true

# 1) Tenta instalar direto pela URL (dnf)
if sudo dnf install -y "$AWS_VPN_RPM_URL"; then
  echo "[ezdora][dnf-awsvpnclient] Concluído (via URL)."
  exit 0
fi

echo "[ezdora][dnf-awsvpnclient] Falha na URL direta. Tentando download com user-agent e instalação local…" >&2

# 2) Fallback: baixa com user-agent de navegador e instala localmente
TMP_RPM="/tmp/AWS_VPN_Client.rpm"
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126 Safari/537.36"

dl_ok=0
if command -v curl >/dev/null 2>&1; then
  if curl -fL --retry 5 --connect-timeout 10 -A "$UA" -o "$TMP_RPM" "$AWS_VPN_RPM_URL"; then
    dl_ok=1
  fi
elif command -v wget >/dev/null 2>&1; then
  if wget --tries=5 --timeout=15 --user-agent="$UA" -O "$TMP_RPM" "$AWS_VPN_RPM_URL"; then
    dl_ok=1
  fi
fi

if [ "$dl_ok" = "1" ]; then
  if sudo dnf install -y "$TMP_RPM"; then
    echo "[ezdora][dnf-awsvpnclient] Concluído (via arquivo local)."
    exit 0
  fi
fi

echo "[ezdora][dnf-awsvpnclient] Falha ao obter o RPM automaticamente." >&2
echo "[ezdora][dnf-awsvpnclient] Baixe manualmente do site oficial e instale com: sudo dnf install ./AWS_VPN_Client.rpm" >&2
echo "[ezdora][dnf-awsvpnclient] Página: https://aws.amazon.com/vpn/client-vpn-download/" >&2
exit 1
