#!/usr/bin/env bash
set -euo pipefail

# ChatGPT Web App para KDE

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
WEBAPP_UTILS="$SCRIPT_DIR/../lib/webapp-utils.sh"

# Verifica se o Edge está instalado
if ! command -v microsoft-edge >/dev/null 2>&1; then
    echo "[ezdora][webapp-chatgpt] Microsoft Edge não encontrado. Instalando..."
    # Usa o script existente do Edge
    bash "$SCRIPT_DIR/dnf-edge.sh"
fi

# Carrega as funções utilitárias
if [ -f "$WEBAPP_UTILS" ]; then
    source "$WEBAPP_UTILS"
else
    echo "[ezdora][webapp-chatgpt] Erro: arquivo de utilitários não encontrado em $WEBAPP_UTILS"
    exit 1
fi

# Baixa ícone do ChatGPT (usando o favicon oficial)
ICON_URL="https://cdn.oaistatic.com/_next/static/media/apple-touch-icon.82af6fe1.png"
ICON_PATH=$(download_webapp_icon "ChatGPT" "$ICON_URL")

echo "[ezdora][webapp-chatgpt] Criando aplicação ChatGPT no menu..."

# Cria a aplicação web em modo kiosk (sem bordas, maximizado)
create_webapp_kiosk \
    "ChatGPT" \
    "OpenAI ChatGPT - AI Assistant" \
    "https://chatgpt.com/" \
    "microsoft-edge" \
    "$ICON_PATH"

echo "[ezdora][webapp-chatgpt] ChatGPT adicionado ao menu de aplicações!"
echo "[ezdora][webapp-chatgpt] Você pode encontrá-lo no menu de aplicações do KDE em 'Internet' ou pesquisando por 'ChatGPT'"