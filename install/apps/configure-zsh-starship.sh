#!/usr/bin/env bash
set -euo pipefail

# Ensure zsh installed
if ! command -v zsh >/dev/null 2>&1; then
  echo "[ezdora][zsh] zsh não instalado; instalando..."
  sudo dnf install -y zsh
fi

# Set zsh as default shell for current user
ZSH_PATH="$(command -v zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
  echo "[ezdora][zsh] Definindo zsh como shell padrão..."
  chsh -s "$ZSH_PATH" "$USER" || echo "[ezdora][zsh] Não foi possível alterar shell automaticamente (talvez por ambiente não login). Faça manualmente: chsh -s $(command -v zsh)"
fi

mkdir -p "$HOME/.config"
ZSHRC="$HOME/.zshrc"

# Ensure basic PATH and mise/Starship init
touch "$ZSHRC"
if ! rg -n "starship init zsh" "$ZSHRC" >/dev/null 2>&1; then
  {
    echo ''
    echo '# EzDora: Starship prompt'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    echo 'eval "$(starship init zsh)"'
  } >> "$ZSHRC"
fi

# Minimal Starship config if not present
mkdir -p "$HOME/.config"
STARCONF="$HOME/.config/starship.toml"
if [ ! -f "$STARCONF" ]; then
  cat > "$STARCONF" <<'EOF'
# EzDora minimal Starship config
add_newline = true
[character]
success_symbol = "[➜](bold green) "
error_symbol = "[➜](bold red) "
[package]
disabled = true
EOF
fi

echo "[ezdora][zsh] zsh configurado com Starship. Reinicie a sessão para aplicar."

