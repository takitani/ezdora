#!/usr/bin/env bash
set -euo pipefail

# Install AI CLIs (via npm) after Node is available through mise
# Packages:
# - @openai/codex (bin: codex)
# - @anthropic-ai/claude-code (bin: claude)
# - @google/gemini-cli (bin: gemini)

if ! command -v npm >/dev/null 2>&1; then
  echo "[ezdora][ai-cli] npm não encontrado. Garanta Node via mise (bash install/apps/mise-setup.sh) e reabra o shell." >&2
  exit 0
fi

# Map packages to expected bin names for idempotency checks
PKGS=("@openai/codex" "@anthropic-ai/claude-code" "@google/gemini-cli")
BINS=("codex" "claude" "gemini")

MISSING_PKGS=()
for i in "${!PKGS[@]}"; do
  bin="${BINS[$i]}"
  if ! command -v "$bin" >/dev/null 2>&1; then
    MISSING_PKGS+=("${PKGS[$i]}")
  fi
done

if [ ${#MISSING_PKGS[@]} -eq 0 ]; then
  echo "[ezdora][ai-cli] CLIs já instaladas (codex/claude/gemini). Pulando."
  exit 0
fi

echo "[ezdora][ai-cli] Instalando via npm: ${MISSING_PKGS[*]}"
npm install -g "${MISSING_PKGS[@]}" || {
  echo "[ezdora][ai-cli] Falha na instalação via npm. Verifique conexão/permissões." >&2
  exit 1
}

echo "[ezdora][ai-cli] Concluído. Configure variáveis: OPENAI_API_KEY, ANTHROPIC_API_KEY, GOOGLE_API_KEY."
