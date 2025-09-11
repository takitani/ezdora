#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][zoxide] Instalando zoxide via DNF e integrando no zsh..."

sudo dnf install -y zoxide || {
  echo "[ezdora][zoxide] Falha ao instalar via DNF." >&2
  exit 1
}

# Add zoxide init to zshrc (with command alias 'j')
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"
if ! grep -q "zoxide init zsh" "$ZSHRC" 2>/dev/null; then
  {
    echo ''
    echo '# EzDora: zoxide (jump) integration'
    echo 'eval "$(zoxide init zsh --cmd j)"'
  } >> "$ZSHRC"
  echo "[ezdora][zoxide] zoxide ativado no zsh com comando 'j'."
fi

echo "[ezdora][zoxide] Concluído. Reabra o shell e use: j <pasta>"

