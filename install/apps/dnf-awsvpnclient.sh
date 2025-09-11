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

# 3) Se usuário fornecer caminho local via env, tenta instalar
if [ -n "${AWS_VPN_RPM_PATH:-}" ] && [ -f "${AWS_VPN_RPM_PATH}" ]; then
  echo "[ezdora][dnf-awsvpnclient] Instalando a partir de arquivo local: ${AWS_VPN_RPM_PATH}"
  if sudo dnf install -y "${AWS_VPN_RPM_PATH}"; then
    echo "[ezdora][dnf-awsvpnclient] Concluído (via caminho local)."
    exit 0
  fi
fi

# 4) Procura em ~/Downloads por um RPM do AWS VPN Client já baixado
DL_DIR="$HOME/Downloads"
if [ -d "$DL_DIR" ]; then
  candidate=$(ls -1t "$DL_DIR"/*AWS*VPN*Client*.rpm 2>/dev/null | head -n1 || true)
  if [ -n "${candidate:-}" ] && [ -f "$candidate" ]; then
    echo "[ezdora][dnf-awsvpnclient] Encontrado RPM em Downloads: $candidate"
    if sudo dnf install -y "$candidate"; then
      echo "[ezdora][dnf-awsvpnclient] Concluído (via Downloads)."
      exit 0
    fi
  fi
fi

# 5) Último recurso: abre página oficial para download manual
page="https://aws.amazon.com/vpn/client-vpn-download/"
echo "[ezdora][dnf-awsvpnclient] Falha ao obter o RPM automaticamente." >&2
echo "[ezdora][dnf-awsvpnclient] Abrindo a página oficial para download: $page" >&2
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$page" >/dev/null 2>&1 || true
elif command -v gio >/dev/null 2>&1; then
  gio open "$page" >/dev/null 2>&1 || true
fi
echo "[ezdora][dnf-awsvpnclient] Após baixar, reexecute: bash install/apps/dnf-awsvpnclient.sh" >&2
exit 1
