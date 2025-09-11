#!/usr/bin/env bash
set -euo pipefail

if command -v nvim >/dev/null 2>&1; then
  echo "[ezdora][neovim] Já instalado. Pulando DNF."
else
  echo "[ezdora][neovim] Instalando Neovim e bindings Python..."
  sudo dnf install -y neovim python3-neovim || {
    echo "[ezdora][neovim] Falha no DNF para neovim/python3-neovim" >&2
    exit 1
  }
fi

# Extras úteis (sem falhar se indisponível)
sudo dnf install -y luarocks || true

# tree-sitter-cli ajuda no :checkhealth do LazyVim. Tenta DNF, senão npm.
if ! command -v tree-sitter >/dev/null 2>&1; then
  sudo dnf install -y tree-sitter-cli tree-sitter || true
  if ! command -v tree-sitter >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    # Configure npm to use user directory for global packages (idempotent)
    NPM_PREFIX="$HOME/.npm-global"
    CURRENT_PREFIX=$(npm config get prefix 2>/dev/null || echo "")
    
    if [ "$CURRENT_PREFIX" != "$NPM_PREFIX" ]; then
      echo "[ezdora][neovim] Configurando npm para usar diretório do usuário..."
      mkdir -p "$NPM_PREFIX"
      npm config set prefix "$NPM_PREFIX"
      
      # Add to PATH in current shell
      export PATH="$NPM_PREFIX/bin:$PATH"
      
      # Add to shell configs if not present
      for RC_FILE in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$RC_FILE" ]; then
          if ! grep -q "export PATH=.*\.npm-global/bin" "$RC_FILE"; then
            echo "" >> "$RC_FILE"
            echo "# npm global packages" >> "$RC_FILE"
            echo "export PATH=\"\$HOME/.npm-global/bin:\$PATH\"" >> "$RC_FILE"
          fi
        fi
      done
    fi
    
    npm install -g tree-sitter-cli || true
  fi
fi

