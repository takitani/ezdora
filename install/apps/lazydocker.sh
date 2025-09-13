#!/usr/bin/env bash
set -euo pipefail

# Ensure ~/.local/bin is in PATH for current session
export PATH="$HOME/.local/bin:$PATH"

if command -v lazydocker >/dev/null 2>&1; then
  echo "[ezdora][lazydocker] Já instalado. Pulando."
  exit 0
fi

echo "[ezdora][lazydocker] Instalando..."

# Tenta via DNF primeiro
if ! sudo dnf install -y lazydocker 2>/dev/null; then
  echo "[ezdora][lazydocker] Não encontrado no DNF. Usando script oficial."
  
  # Ensure target directory exists
  mkdir -p "$HOME/.local/bin"
  
  # Install via official script (installs to ~/.local/bin by default)
  curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
  
  # Verify installation
  if [ -f "$HOME/.local/bin/lazydocker" ]; then
    echo "[ezdora][lazydocker] ✅ Instalado em ~/.local/bin/lazydocker"
  else
    echo "[ezdora][lazydocker] ❌ ERRO: Instalação falhou"
    exit 1
  fi
fi

# Final verification
if command -v lazydocker >/dev/null 2>&1; then
  echo "[ezdora][lazydocker] ✅ Concluído. Executar com 'lazydocker'"
  echo "[ezdora][lazydocker] 💡 Para usar imediatamente: export PATH=\"\$HOME/.local/bin:\$PATH\""
else
  echo "[ezdora][lazydocker] ⚠️  Instalado mas não encontrado no PATH atual"
  echo "[ezdora][lazydocker] 🔄 Reinicie o terminal ou execute: source ~/.zshrc"
fi

