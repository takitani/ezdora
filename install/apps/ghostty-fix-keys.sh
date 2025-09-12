#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][ghostty-keys] Corrigindo teclas Home/End no Ghostty..."

# Verificar se Ghostty está instalado
if ! command -v ghostty >/dev/null 2>&1 && ! rpm -q ghostty >/dev/null 2>&1; then
  echo "[ezdora][ghostty-keys] Ghostty não instalado. Pulando configuração."
  exit 0
fi

# Criar diretório de configuração do Ghostty
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
GHOSTTY_CONFIG_FILE="$GHOSTTY_CONFIG_DIR/config"

mkdir -p "$GHOSTTY_CONFIG_DIR"

# Criar ou atualizar configuração do Ghostty
if [ -f "$GHOSTTY_CONFIG_FILE" ]; then
  echo "[ezdora][ghostty-keys] Atualizando configuração existente..."
  
  # Remove configurações antigas de keybind se existirem
  sed -i '/^keybind = home=/d' "$GHOSTTY_CONFIG_FILE" 2>/dev/null || true
  sed -i '/^keybind = end=/d' "$GHOSTTY_CONFIG_FILE" 2>/dev/null || true
  sed -i '/^keybind = shift\+home=/d' "$GHOSTTY_CONFIG_FILE" 2>/dev/null || true
  sed -i '/^keybind = shift\+end=/d' "$GHOSTTY_CONFIG_FILE" 2>/dev/null || true
else
  echo "[ezdora][ghostty-keys] Criando nova configuração..."
fi

# Adicionar configurações de teclado ao final do arquivo
cat >> "$GHOSTTY_CONFIG_FILE" << 'EOF'

# Correção para teclas Home/End - sequências corretas para aplicações
keybind = home=text:\x1bOH
keybind = end=text:\x1bOF
keybind = shift+home=text:\x1b[1;2H
keybind = shift+end=text:\x1b[1;2F
keybind = ctrl+home=text:\x1b[1;5H
keybind = ctrl+end=text:\x1b[1;5F

# Alternativas para diferentes aplicações
keybind = alt+home=text:\x1b[H
keybind = alt+end=text:\x1b[F

# Page navigation
keybind = page_up=text:\x1b[5~
keybind = page_down=text:\x1b[6~
keybind = shift+page_up=text:\x1b[5;2~
keybind = shift+page_down=text:\x1b[6;2~

# Fallback para aplicações específicas
keybind = ctrl+shift+home=text:\x1b[1~
keybind = ctrl+shift+end=text:\x1b[4~
EOF

echo "[ezdora][ghostty-keys] Configuração salva em: $GHOSTTY_CONFIG_FILE"

# Verificar se há instâncias do Ghostty rodando
if pgrep -x ghostty >/dev/null 2>&1; then
  echo "[ezdora][ghostty-keys] ⚠️  Ghostty está rodando. As mudanças serão aplicadas ao reiniciar o terminal."
  
  if command -v gum >/dev/null 2>&1; then
    if gum confirm "Deseja fechar todas as instâncias do Ghostty para aplicar as mudanças agora?"; then
      pkill ghostty 2>/dev/null || true
      sleep 1
      echo "[ezdora][ghostty-keys] Ghostty fechado. As mudanças serão aplicadas na próxima abertura."
    fi
  else
    read -r -p "Fechar todas as instâncias do Ghostty para aplicar as mudanças? [y/N] " close_ghostty
    if [[ ${close_ghostty:-} =~ ^[Yy]$ ]]; then
      pkill ghostty 2>/dev/null || true
      sleep 1
      echo "[ezdora][ghostty-keys] Ghostty fechado. As mudanças serão aplicadas na próxima abertura."
    fi
  fi
fi

if command -v gum >/dev/null 2>&1; then
  gum style \
    --foreground 46 \
    --border-foreground 46 \
    --border rounded \
    --padding "1 2" \
    --margin "1" \
    "✅ Configuração aplicada!" \
    "" \
    "🔧 Teclas corrigidas:" \
    "• Home/End - navegação início/fim da linha" \
    "• Shift+Home/End - seleção" \
    "• Ctrl+Home/End - início/fim do buffer" \
    "• Page Up/Down - navegação de página" \
    "" \
    "📝 Reinicie o Ghostty para aplicar as mudanças"
else
  echo ""
  echo "✅ Configuração aplicada!"
  echo ""
  echo "🔧 Teclas corrigidas:"
  echo "• Home/End - navegação início/fim da linha"
  echo "• Shift+Home/End - seleção"
  echo "• Ctrl+Home/End - início/fim do buffer"
  echo "• Page Up/Down - navegação de página"
  echo ""
  echo "📝 Reinicie o Ghostty para aplicar as mudanças"
fi

echo "[ezdora][ghostty-keys] Configuração concluída!"