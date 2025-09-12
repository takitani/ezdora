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
# EzDora ZSH Configuration with Antigen + Starship

# Basic PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# Load Antigen
source ~/.config/antigen/antigen.zsh

# Plugins essenciais que o Starship não fornece
antigen bundle zsh-users/zsh-completions        # Completions extras
antigen bundle zsh-users/zsh-autosuggestions    # Sugestões em cinza
antigen bundle zsh-users/zsh-syntax-highlighting # Sintaxe colorida
antigen bundle zsh-users/zsh-history-substring-search # Busca com prefixo

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

echo "[ezdora][antigen] Antigen + Starship configurados!"
echo "[ezdora][antigen] Backup do .zshrc anterior salvo com timestamp"
echo ""
echo "Funcionalidades do Starship (já configurado):"
echo "  ✓ Git status e branch"
echo "  ✓ Docker context"
echo "  ✓ Tempo de execução de comandos"
echo "  ✓ Status de erro"
echo "  ✓ Informações de linguagens (Node, Python, Rust, etc)"
echo ""
echo "Plugins ZSH adicionados via Antigen:"
echo "  ✓ zsh-completions (completions extras)"
echo "  ✓ zsh-autosuggestions (texto cinza com sugestões)"
echo "  ✓ zsh-syntax-highlighting (comandos coloridos)"
echo "  ✓ zsh-history-substring-search (↑↓ com prefixo)"
echo ""
echo "Reinicie o terminal ou execute: source ~/.zshrc"