#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Solicita senha uma vez no início e mantém cache ativo
echo "[ezdora] Autenticação necessária para instalação de pacotes..."
sudo -v

# Mantém o cache de sudo ativo em background durante a execução
(while true; do sudo -n true; sleep 50; done 2>/dev/null) &
SUDO_REFRESH_PID=$!

# Função para limpar o processo de refresh ao sair
cleanup() {
    kill $SUDO_REFRESH_PID 2>/dev/null || true
}
trap cleanup EXIT

# Executa todos os scripts de app em ordem alfabética
for script in "$SCRIPT_DIR/apps"/*.sh; do
  [ -f "$script" ] || continue
  echo "[ezdora][app] Executando $(basename "$script")"
  bash "$script"
done


## Checagens pós-instalação e oferta de reinício
# Caso o usuário tenha sido adicionado ao grupo docker nesta sessão,
# a sessão atual ainda não refletirá o grupo. Oferecer reboot.
REBOOT_NEEDED=0

# Detecta se o usuário está listado no grupo docker, mas não tem grupo efetivo
if getent group docker >/dev/null 2>&1; then
  if getent group docker | grep -qE "(^|,)${USER}($|,)"; then
    if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
      REBOOT_NEEDED=1
      echo "[ezdora][post] Usuário adicionado ao grupo 'docker'. É recomendável reiniciar a sessão."
    fi
  fi
fi

if [ "$REBOOT_NEEDED" -eq 1 ]; then
  prompt() {
    local msg="$1"
    if command -v gum >/dev/null 2>&1; then
      gum confirm "$msg"
    else
      read -r -p "$msg [y/N] " ans
      [[ ${ans:-} =~ ^[Yy]$ ]]
    fi
  }

  if prompt "Reiniciar o sistema agora para aplicar totalmente as alterações?"; then
    echo "[ezdora][post] Reiniciando…"
    sudo systemctl reboot || sudo reboot || echo "[ezdora][post] Falha ao reiniciar automaticamente. Reinicie manualmente."
  else
    echo "[ezdora][post] Ok. Reinicie depois para aplicar as alterações de grupo."
  fi
fi
