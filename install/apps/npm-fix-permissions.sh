#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][npm] Configurando npm para evitar problemas de permissão..."

# Create npm global directory in user home
NPM_CONFIG_PREFIX="$HOME/.npm-global"
mkdir -p "$NPM_CONFIG_PREFIX"

# Configure npm to use the new directory
npm config set prefix "$NPM_CONFIG_PREFIX"

# Add to PATH if not already present
if ! grep -q "export PATH=\$HOME/.npm-global/bin:\$PATH" "$HOME/.bashrc"; then
  echo "" >> "$HOME/.bashrc"
  echo "# npm global packages" >> "$HOME/.bashrc"
  echo "export PATH=\$HOME/.npm-global/bin:\$PATH" >> "$HOME/.bashrc"
fi

if ! grep -q "export PATH=\$HOME/.npm-global/bin:\$PATH" "$HOME/.zshrc" 2>/dev/null; then
  if [ -f "$HOME/.zshrc" ]; then
    echo "" >> "$HOME/.zshrc"
    echo "# npm global packages" >> "$HOME/.zshrc"
    echo "export PATH=\$HOME/.npm-global/bin:\$PATH" >> "$HOME/.zshrc"
  fi
fi

# Export for current session
export PATH="$HOME/.npm-global/bin:$PATH"

echo "[ezdora][npm] Configuração concluída!"
echo "[ezdora][npm] Pacotes globais npm serão instalados em: $NPM_CONFIG_PREFIX"
echo "[ezdora][npm] Reinicie o terminal ou execute: source ~/.bashrc"

# Alternative: Fix permissions on existing directory (not recommended)
# echo "[ezdora][npm] Alternativa: Para corrigir permissões do diretório existente, execute:"
# echo "  sudo chown -R \$(whoami) /usr/local/lib/node_modules"
# echo "  sudo chown -R \$(whoami) /usr/local/bin"
# echo "  sudo chown -R \$(whoami) /usr/local/share"