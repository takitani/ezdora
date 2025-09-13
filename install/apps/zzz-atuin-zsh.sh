#!/usr/bin/env bash
set -euo pipefail

# Configure Atuin integration with Zsh

echo "[ezdora][atuin-zsh] Configurando integração Atuin + Zsh..."

# Check if Atuin is installed
if ! command -v atuin >/dev/null 2>&1; then
    echo "[ezdora][atuin-zsh] ERRO: Atuin não está instalado"
    echo "[ezdora][atuin-zsh] Execute primeiro: install/apps/atuin.sh"
    exit 1
fi

# Check if Zsh is installed
if ! command -v zsh >/dev/null 2>&1; then
    echo "[ezdora][atuin-zsh] ERRO: Zsh não está instalado"
    echo "[ezdora][atuin-zsh] Execute primeiro: install/apps/zsh.sh"
    exit 1
fi

# Initialize Atuin for zsh if not already done
if ! grep -q "# Atuin configuration" ~/.zshrc 2>/dev/null; then
    echo "[ezdora][atuin-zsh] Configurando Atuin no ~/.zshrc..."
    
    # Backup existing .zshrc
    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.backup-atuin-$(date +%Y%m%d-%H%M%S)
        echo "[ezdora][atuin-zsh] Backup do .zshrc criado"
    fi
    
    # Add Atuin initialization to .zshrc
    cat >> ~/.zshrc << 'EOF'

# Atuin configuration - magical shell history
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
fi
EOF
    
    echo "[ezdora][atuin-zsh] ✅ Configuração adicionada ao ~/.zshrc"
else
    echo "[ezdora][atuin-zsh] Atuin já está configurado no ~/.zshrc"
fi

# Initialize Atuin database if needed
if [ ! -f "$HOME/.local/share/atuin/history.db" ]; then
    echo "[ezdora][atuin-zsh] Inicializando banco de dados Atuin..."
    # This will be created automatically on first run
    echo "[ezdora][atuin-zsh] Banco será criado automaticamente no primeiro uso"
fi

# Check if there's shell history to import
HISTORY_IMPORTED=false
if [ -f ~/.zsh_history ] && [ -s ~/.zsh_history ]; then
    echo "[ezdora][atuin-zsh] Histórico Zsh existente detectado"
    echo "[ezdora][atuin-zsh] Para importar, execute: atuin import auto"
    HISTORY_IMPORTED=true
fi

if [ -f ~/.bash_history ] && [ -s ~/.bash_history ]; then
    echo "[ezdora][atuin-zsh] Histórico Bash existente detectado"
    echo "[ezdora][atuin-zsh] Para importar, execute: atuin import auto"  
    HISTORY_IMPORTED=true
fi

echo "[ezdora][atuin-zsh] ✨ Integração Atuin + Zsh configurada!"
echo "[ezdora][atuin-zsh] "
echo "[ezdora][atuin-zsh] 🚀 Para ativar:"
echo "[ezdora][atuin-zsh] 1. Reinicie o terminal ou execute: exec zsh"
echo "[ezdora][atuin-zsh] 2. Use Ctrl+R para busca inteligente no histórico"
echo "[ezdora][atuin-zsh] "

if [ "$HISTORY_IMPORTED" = false ]; then
    echo "[ezdora][atuin-zsh] 💡 Dicas opcionais:"
    echo "[ezdora][atuin-zsh] • Importe histórico existente: atuin import auto"
    echo "[ezdora][atuin-zsh] • Registre conta para sync: atuin register -u <user> -e <email>"
    echo "[ezdora][atuin-zsh] • Configure sync: atuin sync"
else
    echo "[ezdora][atuin-zsh] 📦 Para importar histórico existente:"
    echo "[ezdora][atuin-zsh]   atuin import auto"
    echo "[ezdora][atuin-zsh] "
    echo "[ezdora][atuin-zsh] 🔄 Para sync entre máquinas:"
    echo "[ezdora][atuin-zsh]   atuin register -u <username> -e <email>"
    echo "[ezdora][atuin-zsh]   atuin sync"
fi

echo "[ezdora][atuin-zsh] "
echo "[ezdora][atuin-zsh] 🎯 Recursos do Atuin:"
echo "[ezdora][atuin-zsh] • Histórico criptografado e sincronizado"
echo "[ezdora][atuin-zsh] • Busca por comando, diretório, tempo"
echo "[ezdora][atuin-zsh] • Estatísticas de uso de comandos"
echo "[ezdora][atuin-zsh] • Backup automático do histórico"