#!/usr/bin/env bash
set -euo pipefail

# Install and configure Zsh shell

echo "[ezdora][zsh] Instalando Zsh shell..."

# Check if already installed
if rpm -q zsh >/dev/null 2>&1; then
    echo "[ezdora][zsh] Zsh já está instalado"
else
    echo "[ezdora][zsh] Instalando Zsh via DNF..."
    sudo dnf install -y zsh
    echo "[ezdora][zsh] ✅ Zsh instalado com sucesso"
fi

# Get current shell
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
ZSH_PATH=$(which zsh)

# Check if Zsh is already the default shell
if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
    echo "[ezdora][zsh] Zsh já é o shell padrão"
else
    echo "[ezdora][zsh] Shell atual: $CURRENT_SHELL"
    echo "[ezdora][zsh] Deseja configurar Zsh como shell padrão? (recomendado)"
    
    if command -v gum >/dev/null 2>&1; then
        if gum confirm "Configurar Zsh como shell padrão?"; then
            chsh -s "$ZSH_PATH"
            echo "[ezdora][zsh] ✅ Zsh configurado como shell padrão"
            echo "[ezdora][zsh] Faça logout/login para aplicar a mudança"
        fi
    else
        read -r -p "Configurar Zsh como shell padrão? [Y/n] " change_shell
        if [[ ${change_shell:-Y} =~ ^[Yy]$ ]]; then
            chsh -s "$ZSH_PATH"
            echo "[ezdora][zsh] ✅ Zsh configurado como shell padrão"
            echo "[ezdora][zsh] Faça logout/login para aplicar a mudança"
        fi
    fi
fi

# Create basic .zshrc if it doesn't exist
if [ ! -f ~/.zshrc ]; then
    echo "[ezdora][zsh] Criando ~/.zshrc básico..."
    cat > ~/.zshrc << 'EOF'
# Basic Zsh configuration
autoload -Uz compinit
compinit

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt incappendhistory

# Basic prompt
PS1='%n@%m:%~$ '

# Enable colors
autoload -U colors && colors

# Basic aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
EOF
    echo "[ezdora][zsh] ✅ ~/.zshrc básico criado"
else
    echo "[ezdora][zsh] ~/.zshrc já existe"
fi

echo "[ezdora][zsh] 🚀 Zsh instalado e configurado!"
echo "[ezdora][zsh] "
echo "[ezdora][zsh] 💡 Próximos passos recomendados:"
echo "[ezdora][zsh] • Instale Starship: install/apps/configure-zsh-starship.sh"
echo "[ezdora][zsh] • Configure Atuin: install/apps/atuin.sh && install/apps/atuin-zsh.sh"
echo "[ezdora][zsh] • Adicione plugins: install/apps/zsh-antigen.sh"