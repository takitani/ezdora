#!/usr/bin/env bash
set -euo pipefail

# Optional Windows 11 on Docker setup with RDP ready.
# - Prompts user (uses gum if available, falls back to y/N)
# - Creates a docker compose config for dockurr/windows
# - Starts the container and generates a Remmina connection

have() { command -v "$1" >/dev/null 2>&1; }

confirm() {
  local prompt="$1"
  if have gum; then
    gum confirm "$prompt"
  else
    read -r -p "$prompt [y/N] " ans
    [[ ${ans:-} =~ ^[Yy]$ ]]
  fi
}

echo "[ezdora][docker-win11] Configurar Windows 11 via Docker (opcional)"

if ! confirm "Deseja configurar Windows 11 (Docker) e conexão RDP agora?"; then
  echo "[ezdora][docker-win11] Pulando configuração do Windows 11."
  exit 0
fi

if ! have docker; then
  echo "[ezdora][docker-win11] Docker não encontrado. Execute 'bash install/apps/docker.sh' e rode este script novamente." >&2
  exit 0
fi

# Vars
CONFIG_DIR="$HOME/.config/ezdora"
COMPOSE_FILE="$CONFIG_DIR/docker-compose-win11.yml"
CONTAINER_NAME="win11-ezdora"
RDP_PORT="3389"
WEB_PORT="8006"
USERNAME="User"
PASSWORD="EzdoraWin11"

mkdir -p "$CONFIG_DIR"

# Create compose file if missing (idempotent)
if [ ! -f "$COMPOSE_FILE" ]; then
  cat >"$COMPOSE_FILE" <<'YAML'
name: ezdora-win11
services:
  win11:
    image: dockurr/windows
    container_name: win11-ezdora
    environment:
      VERSION: "11"
      DISK_SIZE: "64G"
      RAM: "8G"
      CPU_CORES: "4"
      LANGUAGE: "en-US"
      KEYBOARD: "en-US"
      USERNAME: "User"
      PASSWORD: "EzdoraWin11"
      MANUAL: "N"
    devices:
      - /dev/kvm:/dev/kvm
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - NET_ADMIN
    ports:
      - "8006:8006"   # Web viewer
      - "3389:3389"   # RDP
    volumes:
      - win11_data:/storage
      - ${HOME}:/shared:rw
    restart: unless-stopped
    networks:
      - win11_net

volumes:
  win11_data:
    driver: local

networks:
  win11_net:
    driver: bridge
YAML
  echo "[ezdora][docker-win11] Compose criado em $COMPOSE_FILE"
else
  echo "[ezdora][docker-win11] Compose já existe em $COMPOSE_FILE"
fi

# Choose docker compose CLI
compose_cmd=(docker compose)
if ! docker compose version >/dev/null 2>&1; then
  if have docker-compose; then
    compose_cmd=(docker-compose)
  fi
fi

(
  cd "$CONFIG_DIR"
  echo "[ezdora][docker-win11] Baixando imagem (pode demorar a primeira vez)…"
  "${compose_cmd[@]}" -f "$COMPOSE_FILE" pull || true
  echo "[ezdora][docker-win11] Subindo o container em segundo plano…"
  "${compose_cmd[@]}" -f "$COMPOSE_FILE" up -d
)

echo "[ezdora][docker-win11] Container criado/iniciado. Acesso:"
echo "  - Web viewer: http://localhost:${WEB_PORT}"
echo "  - RDP: localhost:${RDP_PORT} (usuário: ${USERNAME} / senha: ${PASSWORD})"

# Open the web viewer to monitor Windows installation
VIEW_URL="http://localhost:${WEB_PORT}"
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$VIEW_URL" >/dev/null 2>&1 || true
elif command -v gio >/dev/null 2>&1; then
  gio open "$VIEW_URL" >/dev/null 2>&1 || true
else
  python3 -c 'import webbrowser,sys; webbrowser.open(sys.argv[1])' "$VIEW_URL" >/dev/null 2>&1 || true
fi

echo "[ezdora][docker-win11] Abrimos o navegador padrão para acompanhar a instalação (pode levar 20–40 min)."

# Generate a Remmina connection (if Remmina present, or still create file for later use)
REMMINA_DIR="$HOME/.local/share/remmina"
mkdir -p "$REMMINA_DIR"

# Base64-encode password (Remmina aceita base64 simples; criptografará ao abrir)
enc_pw=$(printf %s "$PASSWORD" | base64 -w0)
RFILE="$REMMINA_DIR/group_local_win11-docker_localhost-${RDP_PORT}.remmina"

cat >"$RFILE" <<REM
[remmina]
protocol=RDP
name=Win 11 Docker
server=localhost:${RDP_PORT}
username=${USERNAME}
password=${enc_pw}
resolution_mode=2
window_maximize=1
colordepth=32
ignore-tls-errors=1
cert_ignore=1
group=local
drive=${HOME}/Public
REM

echo "[ezdora][docker-win11] Conexão Remmina criada: $RFILE"
echo "[ezdora][docker-win11] Pronto. Monitore a instalação pelo web viewer; depois conecte via Remmina."

# Relembrar credenciais ao final para o usuário não esquecer
echo
echo "[ezdora][docker-win11] Credenciais padrão do Windows 11 (Docker):"
echo "  - Usuário: ${USERNAME}"
echo "  - Senha:   ${PASSWORD}"
echo "  - RDP:     localhost:${RDP_PORT}"
echo "  - Web:     http://localhost:${WEB_PORT}"

# Persistir credenciais em arquivo de referência
CREDS_FILE="$CONFIG_DIR/win11-credentials.txt"
{
  echo "Windows 11 (Docker) - Credenciais"
  echo "Usuário: ${USERNAME}"
  echo "Senha:   ${PASSWORD}"
  echo "RDP:     localhost:${RDP_PORT}"
  echo "Web:     http://localhost:${WEB_PORT}"
} >"$CREDS_FILE"
chmod 600 "$CREDS_FILE" || true
echo "[ezdora][docker-win11] Credenciais salvas em: $CREDS_FILE (permissões 600)"
