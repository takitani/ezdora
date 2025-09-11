#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][dnf-awsvpnclient] Instalando AWS VPN Client (Fedora)…"

# Pacote provê: aws-vpn-client
if rpm -q aws-vpn-client >/dev/null 2>&1; then
  echo "[ezdora][dnf-awsvpnclient] aws-vpn-client já instalado"
  exit 0
fi

# URL oficial (AWS CloudFront)
AWS_VPN_RPM_URL="${AWS_VPN_RPM_URL:-https://d20adtppz83p9s.cloudfront.net/GTK/latest/x86_64/AWS_VPN_Client.rpm}"

# Dependências comuns (best-effort)
sudo dnf install -y libappindicator-gtk3 || true

# Instala diretamente via dnf a partir da URL HTTPS oficial
if ! sudo dnf install -y "$AWS_VPN_RPM_URL"; then
  echo "[ezdora][dnf-awsvpnclient] Falha ao instalar a partir da URL: $AWS_VPN_RPM_URL" >&2
  exit 1
fi

echo "[ezdora][dnf-awsvpnclient] Concluído. Procure por 'AWS VPN Client' no menu de aplicativos."

