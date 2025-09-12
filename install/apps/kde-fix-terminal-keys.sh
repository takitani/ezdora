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

# Check if fixes are already applied
echo "🔍 Verificando se as correções já foram aplicadas..."

# Check if shell fixes exist
FIXES_APPLIED=false
if [ -f ~/.zshrc ] && grep -q "KDE Terminal fixes for Home/End keys" ~/.zshrc 2>/dev/null; then
  FIXES_APPLIED=true
fi

if [ -f ~/.bashrc ] && grep -q "KDE Terminal fixes for Home/End keys" ~/.bashrc 2>/dev/null; then
  FIXES_APPLIED=true
fi

if [ "$FIXES_APPLIED" = true ]; then
  echo "✅ Correções já aplicadas anteriormente. Saindo..."
  exit 0
fi

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
if [ -f ~/.zshrc ]; then
  # Only add if not already present
  if ! grep -q "KDE Terminal fixes for Home/End keys" ~/.zshrc 2>/dev/null; then
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
    echo "Adicionadas correções ao ~/.zshrc"
  else
    echo "Correções já existem no ~/.zshrc"
  fi
else
  echo "~/.zshrc não existe, pulando correções do ZSH"
fi

# Also try bash if it exists
if [ -f ~/.bashrc ]; then
  if ! grep -q "KDE Terminal fixes for Home/End keys" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'EOF'

# KDE Terminal fixes for Home/End keys  
if [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
    # Fix Home/End keys in bash
    bind '"\e[H": beginning-of-line'  # Home
    bind '"\e[F": end-of-line'        # End
    bind '"\e[1~": beginning-of-line' # Alternative Home
    bind '"\e[4~": end-of-line'       # Alternative End
fi
EOF
    echo "Adicionadas correções ao ~/.bashrc"
  else
    echo "Correções já existem no ~/.bashrc"
  fi
fi

# Function to restart KDE session with fallbacks
restart_kde_session() {
  echo "🔄 Tentando reiniciar sessão KDE..."
  
  # Method 1: qdbus6 (Plasma 6)
  if command -v qdbus6 >/dev/null 2>&1; then
    echo "Usando qdbus6..."
    qdbus6 org.kde.ksmserver /KSMServer logout 1 3 3 2>/dev/null && return
  fi
  
  # Method 2: qdbus (Plasma 5)  
  if command -v qdbus >/dev/null 2>&1; then
    echo "Usando qdbus..."
    qdbus org.kde.ksmserver /KSMServer logout 1 3 3 2>/dev/null && return
  fi
  
  # Method 3: loginctl
  if command -v loginctl >/dev/null 2>&1 && [[ -n "${XDG_SESSION_ID:-}" ]]; then
    echo "Usando loginctl..."
    loginctl terminate-session "$XDG_SESSION_ID" 2>/dev/null && return
  fi
  
  # Method 4: systemd
  if command -v systemctl >/dev/null 2>&1; then
    echo "Usando systemctl..."
    systemctl --user exit 2>/dev/null && return
  fi
  
  # Fallback
  echo "⚠️  Não foi possível reiniciar automaticamente."
  echo "   Execute manualmente: logout ou reinicie o sistema"
}

echo ""
echo "✅ Correções aplicadas!"
echo ""
echo "🔄 Para aplicar completamente é necessário reiniciar a sessão KDE"
echo "   Execute: logout/login ou reinicie o sistema"
echo ""

# For automated setup - no interactive prompts
if [[ "${EZDORA_AUTOMATED:-}" == "true" ]]; then
  echo "🤖 Modo automatizado: sessão será reiniciada ao final da instalação"
  exit 0
fi

# Interactive mode for manual execution
if command -v gum >/dev/null 2>&1; then
  if gum confirm "Reiniciar sessão KDE agora?"; then
    restart_kde_session
  fi
else
  read -r -p "Reiniciar sessão KDE agora? [y/N] " restart_kde
  if [[ ${restart_kde:-} =~ ^[Yy]$ ]]; then
    restart_kde_session
  fi
fi

echo ""
echo "[ezdora][kde-terminal-fix] Script concluído!"
echo "As correções foram aplicadas. Faça logout/login para testar."