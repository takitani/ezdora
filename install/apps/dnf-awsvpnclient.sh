#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][dnf-awsvpnclient] Instalando AWS VPN Client (Fedora)…"

is_installed() {
  rpm -qa | grep -qiE 'aws.*vpn.*client' \
    || [ -d "/opt/awsvpnclient" ] \
    || [ -f "/usr/share/applications/awsvpnclient.desktop" ] \
    || [ -f "/usr/share/applications/AWS VPN Client.desktop" ]
}

## Observação: não saímos cedo — aplicamos ajustes mesmo se já instalado

configure_dotnet_globalization() {
  # Cria drop-in para o serviço (melhor que editar arquivo vendor)
  local unit="awsvpnclient.service"
  local drop_dir="/etc/systemd/system/${unit}.d"
  local drop_file="${drop_dir}/override.conf"

  sudo mkdir -p "$drop_dir"
  if [ ! -f "$drop_file" ] || ! grep -q "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT" "$drop_file" 2>/dev/null; then
    echo "[ezdora][dnf-awsvpnclient] Aplicando override de systemd para DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1"
    sudo tee "$drop_file" >/dev/null <<'EOF'
[Service]
Environment=DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
EOF
    sudo systemctl daemon-reload || true
    # Reinicia se o serviço existir/estiver ativo
    if systemctl status "$unit" >/dev/null 2>&1; then
      sudo systemctl restart "$unit" || true
    fi
  fi
}

configure_desktop_launcher() {
  # Cria override do desktop launcher em nível de usuário com o env necessário
  local user_dir="$HOME/.local/share/applications"
  mkdir -p "$user_dir"

  local src=""
  for f in \
    /usr/share/applications/awsvpnclient.desktop \
    "/usr/share/applications/AWS VPN Client.desktop" \
    /usr/share/applications/com.amazonaws.awsvpnclient.desktop \
    /usr/share/applications/com.amazon.awsvpnclient.desktop; do
    if [ -f "$f" ]; then src="$f"; break; fi
  done

  local target
  if [ -n "$src" ]; then
    target="$user_dir/$(basename "$src")"
    cp -f "$src" "$target"
    # Prepend o env à linha Exec= se ainda não existir
    if ! grep -q "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT" "$target" 2>/dev/null; then
      sed -i -E 's/^Exec=([^\n]+)/Exec=env DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \1/' "$target"
    fi
  else
    # Fallback: cria um .desktop mínimo apontando para o binário
    local bin
    bin=$(command -v awsvpnclient || true)
    [ -z "$bin" ] && bin="/opt/awsvpnclient/awsvpnclient"
    target="$user_dir/awsvpnclient.desktop"
    cat > "$target" <<EOF
[Desktop Entry]
Name=AWS VPN Client
Comment=Connect to AWS Client VPN
Exec=env DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 $bin %U
Icon=awsvpnclient
Terminal=false
Type=Application
Categories=Network;
EOF
  fi

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$user_dir" >/dev/null 2>&1 || true
  fi

  echo "[ezdora][dnf-awsvpnclient] Launcher configurado em: $target"
}

ensure_systemd_resolved_ready() {
  # Garante systemd-resolved ativo; não força alterações destrutivas em resolv.conf por padrão
  if systemctl list-unit-files | grep -q '^systemd-resolved\.service'; then
    sudo systemctl enable --now systemd-resolved >/dev/null 2>&1 || true
  fi

  # Verifica modo gerenciado; se não estiver, apenas avisa e oferece correção via env flag
  local managed="0"
  if command -v resolvectl >/dev/null 2>&1 && resolvectl status >/dev/null 2>&1; then
    if resolvectl status 2>/dev/null | grep -q "resolv.conf mode: managed"; then
      managed="1"
    fi
  fi

  if [ "$managed" != "1" ]; then
    echo "[ezdora][dnf-awsvpnclient] Aviso: systemd-resolved não está gerenciando /etc/resolv.conf."
    echo "[ezdora][dnf-awsvpnclient] Se a VPN não resolver DNS corretamente, exporte AWS_VPN_FIX_RESOLV=1 e reexecute."

    if [ "${AWS_VPN_FIX_RESOLV:-0}" = "1" ]; then
      # Tenta alternar o resolv.conf para o stub do resolved
      if [ -f /run/systemd/resolve/stub-resolv.conf ]; then
        sudo mv -f /etc/resolv.conf /etc/resolv.conf.backup-awsvpn 2>/dev/null || true
        sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
        sudo systemctl restart systemd-resolved || true
        echo "[ezdora][dnf-awsvpnclient] /etc/resolv.conf apontado para o stub do systemd-resolved (backup: /etc/resolv.conf.backup-awsvpn)."
      else
        echo "[ezdora][dnf-awsvpnclient] stub-resolv.conf não encontrado; pulei a correção automática."
      fi
    fi
  fi
}

configure_desktop_launcher() {
  # Cria override do desktop launcher em nível de usuário com o env necessário
  local user_dir="$HOME/.local/share/applications"
  mkdir -p "$user_dir"

  local src=""
  for f in \
    /usr/share/applications/awsvpnclient.desktop \
    "/usr/share/applications/AWS VPN Client.desktop" \
    /usr/share/applications/com.amazonaws.awsvpnclient.desktop \
    /usr/share/applications/com.amazon.awsvpnclient.desktop; do
    if [ -f "$f" ]; then src="$f"; break; fi
  done

  local target
  if [ -n "$src" ]; then
    target="$user_dir/$(basename "$src")"
    cp -f "$src" "$target"
    # Prepend o env à linha Exec= se ainda não existir
    if ! grep -q "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT" "$target" 2>/dev/null; then
      sed -i -E 's/^Exec=([^\n]+)/Exec=env DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \1/' "$target"
    fi
  else
    # Fallback: cria um .desktop mínimo apontando para o binário
    local bin
    bin=$(command -v awsvpnclient || true)
    [ -z "$bin" ] && bin="/opt/awsvpnclient/awsvpnclient"
    target="$user_dir/awsvpnclient.desktop"
    cat > "$target" <<EOF
[Desktop Entry]
Name=AWS VPN Client
Comment=Connect to AWS Client VPN
Exec=env DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 $bin %U
Icon=awsvpnclient
Terminal=false
Type=Application
Categories=Network;
EOF
  fi

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$user_dir" >/dev/null 2>&1 || true
  fi

  echo "[ezdora][dnf-awsvpnclient] Launcher configurado em: $target"
}

ensure_systemd_resolved_ready() {
  # Garante systemd-resolved ativo; não força alterações destrutivas em resolv.conf por padrão
  if systemctl list-unit-files | grep -q '^systemd-resolved\.service'; then
    sudo systemctl enable --now systemd-resolved >/dev/null 2>&1 || true
  fi

  # Verifica modo gerenciado; se não estiver, apenas avisa e oferece correção via env flag
  local managed="0"
  if command -v resolvectl >/dev/null 2>&1 && resolvectl status >/dev/null 2>&1; then
    if resolvectl status 2>/dev/null | grep -q "resolv.conf mode: managed"; then
      managed="1"
    fi
  fi

  if [ "$managed" != "1" ]; then
    echo "[ezdora][dnf-awsvpnclient] Aviso: systemd-resolved não está gerenciando /etc/resolv.conf."
    echo "[ezdora][dnf-awsvpnclient] Se a VPN não resolver DNS corretamente, exporte AWS_VPN_FIX_RESOLV=1 e reexecute."

    if [ "${AWS_VPN_FIX_RESOLV:-0}" = "1" ]; then
      # Tenta alternar o resolv.conf para o stub do resolved
      if [ -f /run/systemd/resolve/stub-resolv.conf ]; then
        sudo mv -f /etc/resolv.conf /etc/resolv.conf.backup-awsvpn 2>/dev/null || true
        sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
        sudo systemctl restart systemd-resolved || true
        echo "[ezdora][dnf-awsvpnclient] /etc/resolv.conf apontado para o stub do systemd-resolved (backup: /etc/resolv.conf.backup-awsvpn)."
      else
        echo "[ezdora][dnf-awsvpnclient] stub-resolv.conf não encontrado; pulei a correção automática."
      fi
    fi
  fi
}

# Se já estiver instalado, ainda aplicamos ajustes
if is_installed; then
  echo "[ezdora][dnf-awsvpnclient] AWS VPN Client já instalado — aplicando ajustes (env .NET, launcher, DNS)…"
  configure_dotnet_globalization
  configure_desktop_launcher
  ensure_systemd_resolved_ready
  exit 0
fi

# Dependências comuns (best-effort)
sudo dnf install -y libappindicator-gtk3 || true

# 1) Método recomendado para Fedora: COPR vorona/aws-rpm-packages
if ! rpm -q awsvpnclient >/dev/null 2>&1; then
  echo "[ezdora][dnf-awsvpnclient] Habilitando COPR vorona/aws-rpm-packages…"
  if sudo dnf copr enable -y vorona/aws-rpm-packages; then
    echo "[ezdora][dnf-awsvpnclient] Instalando awsvpnclient…"
    sudo dnf install -y awsvpnclient || true
  fi
fi

if rpm -q awsvpnclient >/dev/null 2>&1; then
  echo "[ezdora][dnf-awsvpnclient] AWS VPN Client instalado via COPR."
  configure_dotnet_globalization
  configure_desktop_launcher
  ensure_systemd_resolved_ready
  exit 0
fi

# 2) URL oficial (AWS CloudFront) — pode falhar com 403
AWS_VPN_RPM_URL="${AWS_VPN_RPM_URL:-https://d20adtppz83p9s.cloudfront.net/GTK/latest/x86_64/AWS_VPN_Client.rpm}"

echo "[ezdora][dnf-awsvpnclient] Tentando instalar via URL oficial (pode falhar com 403)…"
if sudo dnf install -y "$AWS_VPN_RPM_URL"; then
  echo "[ezdora][dnf-awsvpnclient] Concluído (via URL)."
  configure_dotnet_globalization
  configure_desktop_launcher
  ensure_systemd_resolved_ready
  exit 0
fi

echo "[ezdora][dnf-awsvpnclient] Falha na URL direta. Tentando download com user-agent e instalação local…" >&2

# 3) Fallback: baixa com user-agent de navegador e instala localmente
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
    configure_dotnet_globalization
    configure_desktop_launcher
    ensure_systemd_resolved_ready
    exit 0
  fi
fi

# 4) Se usuário fornecer caminho local via env, tenta instalar
if [ -n "${AWS_VPN_RPM_PATH:-}" ] && [ -f "${AWS_VPN_RPM_PATH}" ]; then
  echo "[ezdora][dnf-awsvpnclient] Instalando a partir de arquivo local: ${AWS_VPN_RPM_PATH}"
  if sudo dnf install -y "${AWS_VPN_RPM_PATH}"; then
    echo "[ezdora][dnf-awsvpnclient] Concluído (via caminho local)."
    configure_dotnet_globalization
    configure_desktop_launcher
    ensure_systemd_resolved_ready
    exit 0
  fi
fi

# 5) Procura em ~/Downloads por um RPM do AWS VPN Client já baixado
DL_DIR="$HOME/Downloads"
if [ -d "$DL_DIR" ]; then
  candidate=$(ls -1t "$DL_DIR"/*AWS*VPN*Client*.rpm 2>/dev/null | head -n1 || true)
  if [ -n "${candidate:-}" ] && [ -f "$candidate" ]; then
    echo "[ezdora][dnf-awsvpnclient] Encontrado RPM em Downloads: $candidate"
    if sudo dnf install -y "$candidate"; then
      echo "[ezdora][dnf-awsvpnclient] Concluído (via Downloads)."
      configure_dotnet_globalization
      configure_desktop_launcher
      ensure_systemd_resolved_ready
      exit 0
    fi
  fi
fi

# 6) Último recurso: abre página oficial para download manual
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
