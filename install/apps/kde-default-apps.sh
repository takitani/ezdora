#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][kde-defaults] Configurando aplicativos padrão no KDE"
echo "========================================================"
echo ""

# Verificar se estamos no KDE
if [[ "${XDG_CURRENT_DESKTOP:-}" != *KDE* ]]; then
  echo "Não está no KDE, saindo..."
  exit 0
fi

# Backup das configurações
echo "📁 Criando backup das configurações..."
mkdir -p ~/.config/ezdora-backups/$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/.config/ezdora-backups/$(date +%Y%m%d-%H%M%S)"

# Backup mimeapps.list
if [ -f ~/.config/mimeapps.list ]; then
  cp ~/.config/mimeapps.list "$BACKUP_DIR/mimeapps.list.bak"
fi

# Backup kdeglobals
if [ -f ~/.config/kdeglobals ]; then
  cp ~/.config/kdeglobals "$BACKUP_DIR/kdeglobals.bak"
fi

echo "Backup salvo em: $BACKUP_DIR"
echo ""

# Verificar e instalar qtpaths se necessário (para xdg-settings funcionar corretamente no KDE)
if ! command -v qtpaths >/dev/null 2>&1; then
    echo "📦 Instalando qt6-qttools para suporte completo ao xdg-settings..."
    sudo dnf install -y qt6-qttools 2>/dev/null || sudo dnf install -y qt5-qttools 2>/dev/null || true
fi

echo "🔧 Configurando aplicativos padrão..."

# Web Browser: Google Chrome
if command -v google-chrome >/dev/null 2>&1; then
    echo "🌐 Configurando Google Chrome como navegador padrão..."
    
    # Try xdg-settings first (suppress qtpaths errors)
    if xdg-settings set default-web-browser google-chrome.desktop 2>/dev/null; then
        echo "   ✓ Configurado via xdg-settings"
    else
        echo "   ⚠ xdg-settings falhou, usando método manual"
    fi
    
    # Configurar via mimeapps.list também
    mkdir -p ~/.config
    if [ ! -f ~/.config/mimeapps.list ]; then
        touch ~/.config/mimeapps.list
    fi
    
    # Remover configurações antigas para web browser
    sed -i '/^text\/html=/d' ~/.config/mimeapps.list
    sed -i '/^application\/xhtml+xml=/d' ~/.config/mimeapps.list
    sed -i '/^x-scheme-handler\/http=/d' ~/.config/mimeapps.list
    sed -i '/^x-scheme-handler\/https=/d' ~/.config/mimeapps.list
    
    # Adicionar seção [Default Applications] se não existir
    if ! grep -q "^\[Default Applications\]" ~/.config/mimeapps.list; then
        echo "" >> ~/.config/mimeapps.list
        echo "[Default Applications]" >> ~/.config/mimeapps.list
    fi
    
    # Adicionar Chrome como padrão
    echo "text/html=google-chrome.desktop" >> ~/.config/mimeapps.list
    echo "application/xhtml+xml=google-chrome.desktop" >> ~/.config/mimeapps.list
    echo "x-scheme-handler/http=google-chrome.desktop" >> ~/.config/mimeapps.list
    echo "x-scheme-handler/https=google-chrome.desktop" >> ~/.config/mimeapps.list
    
    echo "✅ Google Chrome configurado como navegador padrão"
else
    echo "⚠️  Google Chrome não encontrado. Para instalar: install/apps/google-chrome.sh"
fi

# Video Player: VLC
if command -v vlc >/dev/null 2>&1; then
    echo "🎬 Configurando VLC como player de vídeo padrão..."
    
    # Configurar VLC para vídeos
    video_types=(
        "video/mp4"
        "video/x-msvideo"
        "video/quicktime"
        "video/x-matroska"
        "video/webm"
        "video/x-flv"
        "video/x-ms-wmv"
        "video/mpeg"
        "video/3gpp"
        "application/vnd.rn-realmedia"
    )
    
    for video_type in "${video_types[@]}"; do
        # Remover configuração antiga
        sed -i "/^${video_type//\//\\/}=/d" ~/.config/mimeapps.list
        # Adicionar VLC
        echo "${video_type}=vlc.desktop" >> ~/.config/mimeapps.list
    done
    
    echo "✅ VLC configurado como player de vídeo padrão"
else
    echo "⚠️  VLC não encontrado. Para instalar: install/apps/vlc.sh"
fi

# Text Editor: pode configurar aqui se quiser
if command -v code >/dev/null 2>&1; then
    echo "📝 Configurando Visual Studio Code como editor padrão..."
    
    text_types=(
        "text/plain"
        "text/x-python"
        "text/x-shellscript"
        "application/json"
        "text/markdown"
    )
    
    for text_type in "${text_types[@]}"; do
        sed -i "/^${text_type//\//\\/}=/d" ~/.config/mimeapps.list
        echo "${text_type}=code.desktop" >> ~/.config/mimeapps.list
    done
    
    echo "✅ VS Code configurado como editor padrão para arquivos de desenvolvimento"
fi

# Aplicar configurações
echo ""
echo "🔄 Aplicando configurações..."

# Atualizar banco de dados de aplicações
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
update-desktop-database /usr/share/applications/ 2>/dev/null || update-desktop-database /usr/local/share/applications/ 2>/dev/null || true

# Recarregar configurações do KDE
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
    kbuildsycoca5 --noincremental >/dev/null 2>&1 || true
fi

echo "✨ Aplicativos padrão configurados!"
echo ""
echo "🧪 Para testar:"
echo "  • Abra um link no terminal ou arquivos → deve abrir no Chrome"
echo "  • Clique duplo em um vídeo → deve abrir no VLC"
echo "  • Vá em Sistema → Aplicativos Padrão para verificar"
echo ""
echo "💡 Aplicativos configurados:"

if command -v google-chrome >/dev/null 2>&1; then
    echo "  🌐 Navegador: Google Chrome"
fi

if command -v vlc >/dev/null 2>&1; then
    echo "  🎬 Vídeo: VLC Media Player"
fi

if command -v code >/dev/null 2>&1; then
    echo "  📝 Editor: Visual Studio Code (arquivos de desenvolvimento)"
fi

echo ""
echo "[ezdora][kde-defaults] Configuração concluída!"