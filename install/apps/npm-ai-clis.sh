#!/usr/bin/env bash
set -euo pipefail

# Install AI CLIs (via npm) after Node is available through mise
# Packages:
# - @openai/codex (bin: codex)
# - @anthropic-ai/claude-code (bin: claude)
# - @google/gemini-cli (bin: gemini)

need_npm() {
  if ! command -v npm >/dev/null 2>&1; then
    echo "[ezdora][ai-cli] npm não encontrado. Garanta Node via mise (bash install/apps/mise-setup.sh) e reabra o shell." >&2
    exit 0
  fi
}

need_npm

PKGS=("@openai/codex" "@anthropic-ai/claude-code" "@google/gemini-cli")

echo "[ezdora][ai-cli] Instalando CLIs de IA globalmente com npm..."
npm install -g "${PKGS[@]}" || {
  echo "[ezdora][ai-cli] Falha na instalação via npm. Verifique conexão/permissões." >&2
  exit 1
}

echo "[ezdora][ai-cli] Concluído. Bins esperados: 'codex', 'claude', 'gemini'.\nConfigure suas chaves: OPENAI_API_KEY, ANTHROPIC_API_KEY, GOOGLE_API_KEY."

