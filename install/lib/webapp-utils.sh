#!/usr/bin/env bash

# Função utilitária para criar aplicações web no menu do KDE
# Baseado no Omakub mas adaptado para KDE/Fedora

create_webapp() {
    local name="$1"
    local comment="$2"
    local url="$3"
    local browser="${4:-microsoft-edge}"
    local icon="${5:-web-browser}"
    local categories="${6:-Network;WebBrowser;}"
    local extra_flags="${7:-}"

    local desktop_file="$HOME/.local/share/applications/${name// /-}.desktop"

    # Garante que o diretório existe
    mkdir -p "$HOME/.local/share/applications"

    # Cria o arquivo .desktop
    cat <<EOF > "$desktop_file"
[Desktop Entry]
Version=1.0
Name=$name
Comment=$comment
Exec=$browser --app="$url" --name="$name" --class="$name" $extra_flags
Terminal=false
Type=Application
Icon=$icon
Categories=$categories
MimeType=text/html;text/xml;application/xhtml_xml;
StartupNotify=true
StartupWMClass=$name
EOF

    # Torna o arquivo executável (não é obrigatório mas é boa prática)
    chmod +x "$desktop_file"

    echo "[ezdora][webapp] Criado atalho para $name em $desktop_file"

    # Atualiza o cache do menu (para KDE)
    if command -v kbuildsycoca6 >/dev/null 2>&1; then
        kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
    elif command -v kbuildsycoca5 >/dev/null 2>&1; then
        kbuildsycoca5 --noincremental >/dev/null 2>&1 || true
    fi
}

# Função para criar webapp em modo kiosk (sem bordas, fullscreen)
create_webapp_kiosk() {
    local name="$1"
    local comment="$2"
    local url="$3"
    local browser="${4:-microsoft-edge}"
    local icon="${5:-web-browser}"

    # Flags para modo kiosk/app-like
    local kiosk_flags="--start-maximized --disable-session-crashed-bubble --disable-infobars"

    create_webapp "$name" "$comment" "$url" "$browser" "$icon" "Network;WebBrowser;" "$kiosk_flags"
}

# Função para baixar ícone customizado
download_webapp_icon() {
    local name="$1"
    local icon_url="$2"
    local icon_dir="$HOME/.local/share/icons/webapp"
    local icon_file="$icon_dir/${name// /-}.png"

    mkdir -p "$icon_dir"

    if curl -sSL "$icon_url" -o "$icon_file" 2>/dev/null; then
        echo "$icon_file"
    else
        echo "web-browser"  # Fallback para ícone padrão
    fi
}