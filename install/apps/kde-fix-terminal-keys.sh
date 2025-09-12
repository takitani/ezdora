#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][kde-terminal-fix] Corrigindo teclas Home/End em terminais KDE"
echo "=================================================================="
echo ""

# Verificar se estamos no KDE
if [[ "${XDG_CURRENT_DESKTOP:-}" != *KDE* ]]; then
  echo "Não está no KDE, saindo..."
  exit 0
fi

echo "Problema identificado: Home/End funcionam no KWrite mas não em terminais"
echo "Isso indica configuração específica de terminal no KDE."
echo ""

# Backup das configurações
echo "📁 Criando backups..."
mkdir -p ~/.config/ezdora-backups/$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/.config/ezdora-backups/$(date +%Y%m%d-%H%M%S)"

# Backup konsole config
if [ -f ~/.config/konsolerc ]; then
  cp ~/.config/konsolerc "$BACKUP_DIR/konsolerc.bak"
fi

if [ -d ~/.local/share/konsole ]; then
  cp -r ~/.local/share/konsole "$BACKUP_DIR/konsole-profiles.bak"
fi

# Backup input method configs
if [ -f ~/.config/kxkbrc ]; then
  cp ~/.config/kxkbrc "$BACKUP_DIR/kxkbrc.bak"
fi

if [ -f ~/.config/kcminputrc ]; then
  cp ~/.config/kcminputrc "$BACKUP_DIR/kcminputrc.bak"
fi

echo "Backups salvos em: $BACKUP_DIR"
echo ""

# Fix 1: Reset terminal input method
echo "🔧 Correção 1: Resetando método de entrada para terminais"
kwriteconfig6 --file kcminputrc --group Keyboard --key RepeatDelay 600
kwriteconfig6 --file kcminputrc --group Keyboard --key RepeatRate 25
kwriteconfig6 --file kcminputrc --group Keyboard --key NumLock 0

# Fix 2: Konsole specific keyboard settings
echo "🔧 Correção 2: Configurações específicas do Konsole"
kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile ""
kwriteconfig6 --file konsolerc --group General --key ConfigVersion 1

# Fix 3: Create or fix default Konsole profile
echo "🔧 Correção 3: Corrigindo perfil padrão do Konsole"
KONSOLE_DIR="$HOME/.local/share/konsole"
mkdir -p "$KONSOLE_DIR"

# Create a clean default profile
cat > "$KONSOLE_DIR/Default.profile" << 'EOF'
[Appearance]
ColorScheme=Breeze

[Cursor Options]
CursorShape=0

[General]
Name=Default
Parent=FALLBACK/

[Keyboard]
KeyBindings=default

[Scrolling]
ScrollBarPosition=1

[Terminal Features]
BlinkingCursorEnabled=true
EOF

# Fix 4: Reset keyboard shortcuts globally
echo "🔧 Correção 4: Resetando atalhos globais problemáticos"

# Create clean keyboard shortcuts config
SHORTCUTS_FILE="$HOME/.config/kglobalshortcutsrc"
if [ -f "$SHORTCUTS_FILE" ]; then
  # Remove any terminal-related keyboard interceptors
  sed -i '/\[kwin\]/,/^$/{ /Home=/d; /End=/d; }' "$SHORTCUTS_FILE" 2>/dev/null || true
  sed -i '/\[plasmashell\]/,/^$/{ /Home=/d; /End=/d; }' "$SHORTCUTS_FILE" 2>/dev/null || true
fi

# Fix 5: Test different terminal emulator settings
echo "🔧 Correção 5: Configurações de emulação de terminal"

# Set proper TERM variables for terminals
cat >> ~/.zshrc << 'EOF'

# KDE Terminal fixes for Home/End keys
if [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
    # Ensure proper terminal capabilities
    export TERM=${TERM:-xterm-256color}
    
    # Fix Home/End keys in various applications
    bindkey "^[[H" beginning-of-line    # Home
    bindkey "^[[F" end-of-line          # End
    bindkey "^[[1~" beginning-of-line   # Alternative Home
    bindkey "^[[4~" end-of-line         # Alternative End
fi
EOF

echo ""
echo "✅ Correções aplicadas!"
echo ""
echo "🔄 Para aplicar completamente:"
echo "1. Reinicie o KDE (logout/login)"
echo "2. Ou execute: kquitapp5 konsole; kquitapp5 plasmashell; plasmashell &"
echo ""
echo "🧪 Teste após reiniciar:"
echo "- Abra um novo terminal (Konsole ou Ghostty)"
echo "- Digite uma linha longa"
echo "- Teste Home/End"
echo ""

if command -v gum >/dev/null 2>&1; then
  if gum confirm "Reiniciar sessão KDE agora?"; then
    qdbus org.kde.ksmserver /KSMServer logout 1 3 3
  fi
else
  read -r -p "Reiniciar sessão KDE agora? [y/N] " restart_kde
  if [[ ${restart_kde:-} =~ ^[Yy]$ ]]; then
    qdbus org.kde.ksmserver /KSMServer logout 1 3 3
  fi
fi