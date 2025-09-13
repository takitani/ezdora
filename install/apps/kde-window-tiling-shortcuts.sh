#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][kde-tiling] Configurando atalhos de tiling de janelas no KDE"
echo "============================================================="
echo ""

# Verificar se estamos no KDE
if [[ "${XDG_CURRENT_DESKTOP:-}" != *KDE* ]]; then
  echo "Não está no KDE, saindo..."
  exit 0
fi

echo "Configurando atalhos:"
echo "  Ctrl+Super+Left  → Quick Tile Window to the Left"
echo "  Ctrl+Super+Right → Quick Tile Window to the Right"
echo ""

# Backup das configurações
echo "📁 Criando backup das configurações..."
mkdir -p ~/.config/ezdora-backups/$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/.config/ezdora-backups/$(date +%Y%m%d-%H%M%S)"

# Backup kglobalshortcutsrc
if [ -f ~/.config/kglobalshortcutsrc ]; then
  cp ~/.config/kglobalshortcutsrc "$BACKUP_DIR/kglobalshortcutsrc.bak"
fi

echo "Backup salvo em: $BACKUP_DIR"
echo ""

# Configurar atalhos de tiling usando kwriteconfig6
echo "🔧 Configurando atalhos de tiling de janelas..."

# Configurar Quick Tile Window to the Left = Ctrl+Super+Left
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Quick Tile Window to the Left" "Ctrl+Super+Left,Meta+Left,Quick Tile Window to the Left"

# Configurar Quick Tile Window to the Right = Ctrl+Super+Right  
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Quick Tile Window to the Right" "Ctrl+Super+Right,Meta+Right,Quick Tile Window to the Right"

echo "✅ Atalhos configurados:"
echo "   Ctrl+Super+Left  = Tile janela à esquerda"
echo "   Ctrl+Super+Right = Tile janela à direita"
echo ""

# Aplicar configurações
echo "🔄 Aplicando configurações..."

# Recarregar configurações do KWin
if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
elif command -v qdbus >/dev/null 2>&1; then
    qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
fi

# Recarregar cache de atalhos globais
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
elif command -v kbuildsycoca5 >/dev/null 2>&1; then
    kbuildsycoca5 --noincremental >/dev/null 2>&1 || true
fi

echo "✨ Configuração aplicada com sucesso!"
echo ""
echo "🧪 Teste os novos atalhos:"
echo "  1. Abra uma janela qualquer"
echo "  2. Pressione Ctrl+Super+Left para tiling à esquerda"
echo "  3. Pressione Ctrl+Super+Right para tiling à direita"
echo ""
echo "💡 Outros atalhos úteis do KDE:"
echo "  Super+Up    = Maximizar janela"
echo "  Super+Down  = Minimizar janela"
echo "  Meta+Left/Right = Tiling padrão do KDE"
echo ""

echo "[ezdora][kde-tiling] Atalhos de tiling configurados!"