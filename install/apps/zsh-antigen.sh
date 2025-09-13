#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][antigen] Configurando Antigen para gerenciar plugins do ZSH..."

# Check if Antigen is already configured
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ] && grep -q "antigen.zsh" "$ZSHRC" 2>/dev/null; then
    echo "[ezdora][antigen] Antigen já está configurado no .zshrc"
    exit 0
fi

# Install Antigen
ANTIGEN_DIR="$HOME/.config/antigen"
mkdir -p "$ANTIGEN_DIR"

if [ ! -f "$ANTIGEN_DIR/antigen.zsh" ]; then
  echo "[ezdora][antigen] Baixando Antigen..."
  curl -L git.io/antigen > "$ANTIGEN_DIR/antigen.zsh"
fi

# Backup current .zshrc if it exists
if [ -f "$ZSHRC" ]; then
    cp "$ZSHRC" "$ZSHRC.backup.$(date +%Y%m%d_%H%M%S)"
    echo "[ezdora][antigen] Backup do .zshrc salvo"
fi

# Create or ensure .zshrc exists
touch "$ZSHRC"

# Add Antigen configuration to .zshrc (preserving existing content)
echo "[ezdora][antigen] Adicionando configuração do Antigen ao .zshrc..."

cat >> "$ZSHRC" <<'EOF'

# =====================================
# EzDora: Antigen Plugin Manager
# =====================================

# Load Antigen
source ~/.config/antigen/antigen.zsh

# Essential plugins that Starship doesn't provide
antigen bundle zsh-users/zsh-completions        # Extra completions
antigen bundle zsh-users/zsh-autosuggestions    # Gray suggestions
antigen bundle zsh-users/zsh-syntax-highlighting # Colored syntax
antigen bundle zsh-users/zsh-history-substring-search # Prefix search

# Tell Antigen that you're done
antigen apply

# =====================================
# EzDora: Enhanced ZSH Configuration
# =====================================

# History configuration (conditional - Atuin vs traditional Zsh)
if command -v atuin >/dev/null 2>&1; then
    # Atuin is available - use minimal config, let Atuin handle history
    export HISTFILE="$HOME/.zsh_history"
    export HISTSIZE=1000        # Small buffer for compatibility
    export SAVEHIST=1000        # Atuin manages the real history
    setopt HIST_IGNORE_ALL_DUPS # Avoid immediate duplicates
    
    # Initialize Atuin (replaces traditional history system)
    eval "$(atuin init zsh)"
    
    echo "🎯 Using Atuin for intelligent shell history management"
else
    # Atuin not available - use enhanced traditional Zsh history
    export HISTFILE="$HOME/.zsh_history"
    export HISTSIZE=50000
    export SAVEHIST=50000
    setopt APPEND_HISTORY
    setopt INC_APPEND_HISTORY
    setopt SHARE_HISTORY
    setopt HIST_IGNORE_ALL_DUPS
    
    # Key bindings for history search with plugins (only if no Atuin)
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^[OA' history-substring-search-up
    bindkey '^[OB' history-substring-search-down
    
    echo "📚 Using enhanced Zsh history (install Atuin for better experience)"
fi

# Essential key fixes (preserve system defaults, only fix what's broken)
bindkey '^?' backward-delete-char      # Backspace
bindkey '^H' backward-delete-char      # Backspace alt
bindkey '\e[3~' delete-char           # Delete key

# Autosuggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# =====================================
# EzDora: Tool Integrations
# =====================================

# Add essential paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# Starship prompt (if available)
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Mise activation (if available)
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

# Zoxide integration (if available)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd z)"
    alias cd=z
fi

# Useful aliases
if command -v lazydocker >/dev/null 2>&1; then
    alias ld=lazydocker
fi

EOF

echo "[ezdora][antigen] ✅ Antigen configurado com sucesso!"
echo ""
echo "🎯 Configurações adicionadas (preservando existentes):"
echo "  ✓ Antigen plugin manager"
echo "  ✓ zsh-completions (completions extras)"
echo "  ✓ zsh-autosuggestions (texto cinza com sugestões)"
echo "  ✓ zsh-syntax-highlighting (comandos coloridos)"
echo "  ✓ zsh-history-substring-search (↑↓ com prefixo)"
echo "  ✓ Configurações de histórico aprimoradas"
echo "  ✓ Correções mínimas de teclas (preservando padrões do sistema)"
echo ""
echo "🔄 Para ativar: reinicie o terminal ou execute: source ~/.zshrc"
echo "📝 Configurações existentes foram preservadas"