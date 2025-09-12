#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][antigen] Instalando Antigen para gerenciar plugins do ZSH..."

# Install Antigen
ANTIGEN_DIR="$HOME/.config/antigen"
mkdir -p "$ANTIGEN_DIR"

if [ ! -f "$ANTIGEN_DIR/antigen.zsh" ]; then
  echo "[ezdora][antigen] Baixando Antigen..."
  curl -L git.io/antigen > "$ANTIGEN_DIR/antigen.zsh"
fi

# Backup current .zshrc
cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

# Create new .zshrc with Antigen configuration
ZSHRC="$HOME/.zshrc"
cat > "$ZSHRC" <<'EOF'
# EzDora ZSH Configuration with Antigen

# Basic PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# Load Antigen
source ~/.config/antigen/antigen.zsh

# Load oh-my-zsh library
antigen use oh-my-zsh

# Load bundles from the default repo (oh-my-zsh)
antigen bundle git
antigen bundle command-not-found
antigen bundle docker

# Load bundles from external repos
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-history-substring-search

# Tell Antigen that you're done
antigen apply

# History configuration
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Key bindings for history search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# Fix Delete key
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char
bindkey '\e[3~' delete-char

# Starship prompt (mantendo seu tema atual)
eval "$(starship init zsh)"

# Mise activation
eval "$(mise activate zsh)"

# Zoxide integration
eval "$(zoxide init zsh --cmd z)"
alias cd=z

# Aliases
alias ld=lazydocker

# Autosuggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
EOF

echo "[ezdora][antigen] Antigen configurado com plugins!"
echo "[ezdora][antigen] Backup do .zshrc anterior salvo com timestamp"
echo "[ezdora][antigen] Reinicie o terminal ou execute: source ~/.zshrc"
echo ""
echo "Plugins instalados:"
echo "  - git (aliases e completions)"
echo "  - command-not-found (sugere pacotes para comandos não encontrados)"
echo "  - docker (completions para docker)"
echo "  - zsh-completions (completions extras)"
echo "  - zsh-autosuggestions (sugestões baseadas no histórico)"
echo "  - zsh-syntax-highlighting (destaque de sintaxe)"
echo "  - zsh-history-substring-search (busca no histórico com prefixo)"