#!/usr/bin/env bash
set -euo pipefail

# Ensure ~/.local/bin is in PATH for current session
export PATH="$HOME/.local/bin:$PATH"

if command -v mise >/dev/null 2>&1; then
  echo "[ezdora][mise] Já instalado. Pulando."
  exit 0
fi

echo "[ezdora][mise] Instalando mise via script oficial..."

# Ensure target directory exists
mkdir -p "$HOME/.local/bin"

# Install mise
curl -fsSL https://mise.jdx.dev/install.sh | sh

# Verify installation
if [ -f "$HOME/.local/bin/mise" ]; then
  echo "[ezdora][mise] ✅ Instalado em ~/.local/bin/mise"
elif command -v mise >/dev/null 2>&1; then
  echo "[ezdora][mise] ✅ Instalado e disponível no PATH"
else
  echo "[ezdora][mise] ❌ ERRO: Instalação falhou"
  exit 1
fi

# Final verification with updated PATH
if command -v mise >/dev/null 2>&1; then
  echo "[ezdora][mise] ✅ Concluído. Executar com 'mise'"
  echo "[ezdora][mise] 💡 Para usar imediatamente: export PATH=\"\$HOME/.local/bin:\$PATH\""
else
  echo "[ezdora][mise] ⚠️  Instalado mas não encontrado no PATH atual"
  echo "[ezdora][mise] 🔄 Reinicie o terminal ou execute: source ~/.zshrc"
fi

