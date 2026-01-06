#!/usr/bin/env bash
set -euo pipefail

# Configure Atuin integration with Zsh

echo "[ezdora][atuin-zsh] Configurando integração Atuin + Zsh..."

# Check if Atuin is installed (optional - skip if not available)
if ! command -v atuin >/dev/null 2>&1; then
    echo "[ezdora][atuin-zsh] Atuin não está instalado, pulando configuração"
    echo "[ezdora][atuin-zsh] Para instalar depois: install/apps/zzz-atuin.sh"
    exit 0
fi

# Check if Zsh is installed
if ! command -v zsh >/dev/null 2>&1; then
    echo "[ezdora][atuin-zsh] ERRO: Zsh não está instalado"
    echo "[ezdora][atuin-zsh] Execute primeiro: install/apps/zsh.sh"
    exit 1
fi

# Check if Atuin integration is already configured
if grep -q "atuin init zsh" ~/.zshrc 2>/dev/null; then
    echo "[ezdora][atuin-zsh] ✅ Atuin já está configurado no .zshrc (via zsh-antigen.sh)"
else
    echo "[ezdora][atuin-zsh] ⚠️  Atuin não detectado no .zshrc"
    echo "[ezdora][atuin-zsh] NOTA: O script zsh-antigen.sh configura Atuin automaticamente"
    echo "[ezdora][atuin-zsh] Se você não usa Antigen, execute manualmente:"
    echo "[ezdora][atuin-zsh]   echo 'eval \"\$(atuin init zsh)\"' >> ~/.zshrc"
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