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
  echo "[ezdora][docker-win11] Docker não encontrado." >&2
  
  if have gum; then
    if gum confirm "Docker não está instalado. Deseja instalar agora?"; then
      echo "[ezdora][docker-win11] Instalando Docker..."
      bash "$(dirname "$0")/docker.sh"
      
      # Após instalar, continuar com o script em nova sessão se necessário
      if ! docker ps >/dev/null 2>&1; then
        echo ""
        echo "[ezdora][docker-win11] Docker instalado! Aplicando permissões temporariamente para continuar..."
        exec sg docker -c "PATH=\"$PATH\" $0 $*"
      fi
    else
      echo "[ezdora][docker-win11] Instalação cancelada."
      exit 0
    fi
  else
    echo "[ezdora][docker-win11] Execute 'bash install/apps/docker.sh' primeiro." >&2
    exit 0
  fi
fi

# Check if user can run Docker without sudo
if ! docker ps >/dev/null 2>&1; then
  echo "[ezdora][docker-win11] Detectado problema de permissão Docker." >&2
  
  # Tentar resolver automaticamente
  if groups | grep -q docker; then
    # Usuário está no grupo mas não aplicou ainda
    echo "[ezdora][docker-win11] Você está no grupo docker mas as permissões não estão ativas."
    
    if have gum; then
      ACTION=$(gum choose \
        --header "Como deseja proceder?" \
        "Continuar com permissão temporária" \
        "Aplicar permanentemente (logout necessário)" \
        "Cancelar")
      
      case "$ACTION" in
        "Continuar com permissão temporária")
          echo "[ezdora][docker-win11] Reiniciando script com permissões Docker..."
          exec sg docker -c "PATH=\"$PATH\" $0 $*"
          ;;
        "Aplicar permanentemente"*)
          gum style \
            --border double \
            --border-foreground 212 \
            --padding "1 2" \
            "Faça logout e login, depois execute novamente:" \
            "" \
            "bash $0"
          exit 0
          ;;
        *)
          exit 0
          ;;
      esac
    else
      echo "[ezdora][docker-win11] Tentando aplicar permissões temporariamente..."
      exec sg docker -c "PATH=\"$PATH\" $0 $*"
    fi
  else
    # Usuário não está no grupo docker
    echo "[ezdora][docker-win11] Adicionando você ao grupo docker..."
    sudo usermod -aG docker "$USER"
    
    echo "[ezdora][docker-win11] Aplicando permissões temporariamente para continuar..."
    exec sg docker -c "PATH=\"$PATH\" $0 $*"
  fi
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

# Download da imagem (sem iniciar ainda)
(
  cd "$CONFIG_DIR"
  echo "[ezdora][docker-win11] Baixando imagem (pode demorar a primeira vez)…"
  "${compose_cmd[@]}" -f "$COMPOSE_FILE" pull || true
)

# Perguntar se quer iniciar agora ou deixar para depois
START_NOW=false
if have gum; then
  if gum confirm "Deseja iniciar o Windows 11 agora? (pode levar 20-40 min para instalar)"; then
    START_NOW=true
  fi
else
  read -r -p "Iniciar Windows 11 agora? (pode levar 20-40 min) [y/N] " ans
  [[ ${ans:-} =~ ^[Yy]$ ]] && START_NOW=true
fi

if [ "$START_NOW" = true ]; then
  (
    cd "$CONFIG_DIR"
    echo "[ezdora][docker-win11] Iniciando o container…"
    "${compose_cmd[@]}" -f "$COMPOSE_FILE" up -d
  )
  
  echo "[ezdora][docker-win11] Container iniciado! Acesso:"
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
  
  echo "[ezdora][docker-win11] Abrimos o navegador padrão para acompanhar a instalação."
else
  echo "[ezdora][docker-win11] Container configurado mas não iniciado."
  echo "[ezdora][docker-win11] Use os atalhos do menu ou execute:"
  echo "  cd '$CONFIG_DIR' && docker compose up -d"
fi

# Generate a Remmina connection (if Remmina present, or still create file for later use)
REMMINA_DIR="$HOME/.local/share/remmina"
mkdir -p "$REMMINA_DIR"

# Para Remmina funcionar corretamente, não usar base64 - deixar em texto plano
# O Remmina criptografará automaticamente na primeira conexão
RFILE="$REMMINA_DIR/group_local_win11-docker_localhost-${RDP_PORT}.remmina"

cat >"$RFILE" <<REM
[remmina]
protocol=RDP
name=Win 11 Docker
server=localhost:${RDP_PORT}
username=${USERNAME}
password=${PASSWORD}
resolution_mode=2
window_maximize=1
colordepth=32
ignore-tls-errors=1
cert_ignore=1
group=local
drive=${HOME}/Public
shareprinter=0
sharesound=0
REM

echo "[ezdora][docker-win11] Conexão Remmina criada: $RFILE"
echo "[ezdora][docker-win11] Pronto. Monitore a instalação pelo web viewer; depois conecte via Remmina."

# Exibir credenciais com cores e formatação bonita
echo
if command -v gum >/dev/null 2>&1; then
  gum style \
    --foreground 212 \
    --border-foreground 212 \
    --border double \
    --align center \
    --width 60 \
    --margin "1 2" \
    --padding "1 2" \
    "🖥️  WINDOWS 11 DOCKER - CREDENCIAIS DE ACESSO  🖥️"
  
  echo
  gum style \
    --foreground 39 \
    --border-foreground 39 \
    --border rounded \
    --padding "1 2" \
    --margin "0 2" \
    "👤 Usuário: ${USERNAME}" \
    "🔑 Senha: ${PASSWORD}" \
    "🌐 RDP: localhost:${RDP_PORT}" \
    "🌍 Web Viewer: http://localhost:${WEB_PORT}"
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🖥️  WINDOWS 11 DOCKER - CREDENCIAIS DE ACESSO"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "👤 Usuário: ${USERNAME}"
  echo "🔑 Senha: ${PASSWORD}"
  echo "🌐 RDP: localhost:${RDP_PORT}"
  echo "🌍 Web Viewer: http://localhost:${WEB_PORT}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

# Salvar credenciais em arquivo no home do usuário para fácil acesso
HOME_CREDS_FILE="$HOME/Windows11-Docker-Credenciais.txt"
CONFIG_CREDS_FILE="$CONFIG_DIR/win11-credentials.txt"

# Criar conteúdo das credenciais
CREDS_CONTENT="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🖥️  WINDOWS 11 DOCKER - CREDENCIAIS DE ACESSO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 Usuário: ${USERNAME}
🔑 Senha: ${PASSWORD}
🌐 RDP: localhost:${RDP_PORT}
🌍 Web Viewer: http://localhost:${WEB_PORT}

📝 INSTRUÇÕES:
- Use o Web Viewer para acompanhar a instalação do Windows (20-40 min)
- Após a instalação, conecte via RDP usando Remmina ou outro cliente RDP
- Pasta compartilhada: ~/Public (acessível no Windows como rede)

🕒 Gerado em: $(date '+%Y-%m-%d %H:%M:%S')
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Salvar no home e no config
echo "$CREDS_CONTENT" > "$HOME_CREDS_FILE"
echo "$CREDS_CONTENT" > "$CONFIG_CREDS_FILE"

# Definir permissões seguras
chmod 600 "$HOME_CREDS_FILE" "$CONFIG_CREDS_FILE" 2>/dev/null || true

echo
if command -v gum >/dev/null 2>&1; then
  gum style \
    --foreground 46 \
    --border-foreground 46 \
    --border rounded \
    --padding "0 1" \
    --margin "0 2" \
    "💾 Credenciais salvas em:" \
    "📁 $HOME_CREDS_FILE" \
    "📁 $CONFIG_CREDS_FILE"
else
  echo "💾 Credenciais salvas em:"
  echo "📁 $HOME_CREDS_FILE"
  echo "📁 $CONFIG_CREDS_FILE"
fi

# Criar atalhos do menu (arquivos .desktop)
echo
echo "[ezdora][docker-win11] Criando atalhos no menu do sistema..."

DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

# Atalho para iniciar Windows 11
START_DESKTOP="$DESKTOP_DIR/ezdora-win11-start.desktop"
cat > "$START_DESKTOP" <<'DESKTOP_EOF'
[Desktop Entry]
Name=🚀 Windows 11 Docker - Start
Comment=Iniciar máquina virtual Windows 11 no Docker
Exec=bash -c 'cd ~/.config/ezdora && docker compose -f docker-compose-win11.yml up -d && notify-send "Windows 11 Docker" "Container iniciado! Abra o Web Viewer para acompanhar." --icon=virtualbox'
Icon=virtualbox
Terminal=false
Type=Application
Categories=System;Utility;
Keywords=windows;docker;vm;virtual;machine;start;
DESKTOP_EOF

# Atalho para parar Windows 11
STOP_DESKTOP="$DESKTOP_DIR/ezdora-win11-stop.desktop"
cat > "$STOP_DESKTOP" <<'DESKTOP_EOF'
[Desktop Entry]
Name=🛑 Windows 11 Docker - Stop
Comment=Parar máquina virtual Windows 11 no Docker
Exec=bash -c 'cd ~/.config/ezdora && docker compose -f docker-compose-win11.yml down && notify-send "Windows 11 Docker" "Container parado com sucesso." --icon=virtualbox'
Icon=virtualbox
Terminal=false
Type=Application
Categories=System;Utility;
Keywords=windows;docker;vm;virtual;machine;stop;
DESKTOP_EOF

# Atalho para abrir Web Viewer
VIEWER_DESKTOP="$DESKTOP_DIR/ezdora-win11-viewer.desktop"
cat > "$VIEWER_DESKTOP" <<'DESKTOP_EOF'
[Desktop Entry]
Name=🌍 Windows 11 Docker - Web Viewer
Comment=Abrir o visualizador web do Windows 11
Exec=bash -c 'xdg-open "http://localhost:8006" || firefox "http://localhost:8006" || google-chrome "http://localhost:8006"'
Icon=applications-internet
Terminal=false
Type=Application
Categories=System;Utility;
Keywords=windows;docker;vm;virtual;machine;viewer;web;
DESKTOP_EOF

# Atalho para status/controle
STATUS_DESKTOP="$DESKTOP_DIR/ezdora-win11-status.desktop"
cat > "$STATUS_DESKTOP" <<'DESKTOP_EOF'
[Desktop Entry]
Name=📊 Windows 11 Docker - Status
Comment=Ver status e controlar o Windows 11 Docker
Exec=bash -c 'cd ~/.config/ezdora && STATUS=$(docker compose -f docker-compose-win11.yml ps --format "table {{.Name}}\t{{.Status}}" 2>/dev/null) && if echo "$STATUS" | grep -q "Up"; then notify-send "Windows 11 Docker" "Status: EXECUTANDO\n\nWeb Viewer: http://localhost:8006\nRDP: localhost:3389" --icon=dialog-information; else notify-send "Windows 11 Docker" "Status: PARADO\n\nUse o atalho Start para iniciar." --icon=dialog-information; fi'
Icon=dialog-information
Terminal=false
Type=Application
Categories=System;Utility;
Keywords=windows;docker;vm;virtual;machine;status;
DESKTOP_EOF

# Tornar executáveis
chmod +x "$START_DESKTOP" "$STOP_DESKTOP" "$VIEWER_DESKTOP" "$STATUS_DESKTOP" 2>/dev/null || true

if command -v gum >/dev/null 2>&1; then
  gum style \
    --foreground 82 \
    --border-foreground 82 \
    --border rounded \
    --padding "0 1" \
    --margin "0 2" \
    "🎯 Atalhos criados no menu:" \
    "🚀 Windows 11 Docker - Start" \
    "🛑 Windows 11 Docker - Stop" \
    "🌍 Windows 11 Docker - Web Viewer" \
    "📊 Windows 11 Docker - Status"
else
  echo "🎯 Atalhos criados no menu:"
  echo "🚀 Windows 11 Docker - Start"
  echo "🛑 Windows 11 Docker - Stop"
  echo "🌍 Windows 11 Docker - Web Viewer"
  echo "📊 Windows 11 Docker - Status"
fi
