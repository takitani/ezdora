#!/usr/bin/env bash
set -euo pipefail

# Only apply on Wayland sessions
if [[ "${XDG_SESSION_TYPE:-}" != "wayland" ]]; then
  echo "[ezdora][kitty] Não é uma sessão Wayland. Pulando configuração de clipboard."
  exit 0
fi

# Ensure Kitty is installed
if ! command -v kitty >/dev/null 2>&1; then
  echo "[ezdora][kitty] Kitty não instalado; pulando configuração de clipboard."
  exit 0
fi

# Ensure wl-clipboard is installed
if ! command -v wl-paste >/dev/null 2>&1; then
  echo "[ezdora][kitty] Instalando wl-clipboard..."
  sudo dnf install -y wl-clipboard || true
fi

# Create ~/.local/bin if it doesn't exist
mkdir -p "$HOME/.local/bin"

# Create clip2path script
CLIP2PATH="$HOME/.local/bin/clip2path"

# Check if script already exists with correct content
if [ -f "$CLIP2PATH" ] && grep -q "kitty @ send-text" "$CLIP2PATH" 2>/dev/null; then
  echo "[ezdora][kitty] Script clip2path já existe e está configurado."
  exit 0
fi

echo "[ezdora][kitty] Criando script clip2path para suporte a paste de imagem..."

cat > "$CLIP2PATH" << 'EOF'
#!/usr/bin/env bash
set -e

types=$(wl-paste --list-types)

if grep -q '^text/' <<< "$types"; then
  wl-paste --no-newline | kitty @ send-text --stdin
elif grep -q '^image/' <<< "$types"; then
  ext=$(grep -m1 '^image/' <<< "$types" | cut -d/ -f2 | cut -d';' -f1)
  file="/tmp/clip_$(date +%s).${ext}"
  wl-paste > "$file"
  printf '%q' "$file" | kitty @ send-text --stdin
else
  wl-paste --no-newline | kitty @ send-text --stdin
fi
EOF

chmod +x "$CLIP2PATH"

echo "[ezdora][kitty] Script clip2path criado em $CLIP2PATH"

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo "[ezdora][kitty] Nota: Adicione ~/.local/bin ao PATH se necessário"
fi
