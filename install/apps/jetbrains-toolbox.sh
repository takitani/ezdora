#!/usr/bin/env bash
set -euo pipefail

# Install JetBrains Toolbox using official tarball (best for Fedora; auto-updates itself).
# Creates a symlink at ~/.local/bin/jetbrains-toolbox.

# Skip if already installed
if command -v jetbrains-toolbox >/dev/null 2>&1 || [ -x "$HOME/.local/share/JetBrains/Toolbox/jetbrains-toolbox" ]; then
  echo "[ezdora][toolbox] Já instalado. Pulando."
  exit 0
fi

echo "[ezdora][toolbox] Instalando JetBrains Toolbox..."

mkdir -p "$HOME/.local/share/JetBrains" "$HOME/.local/bin"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
cd "$tmpdir"

# Discover latest download URL from JetBrains releases API
URL=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" \
  | grep -oE 'https:[^"]+jetbrains-toolbox-[^\"]+\.tar\.gz' \
  | head -n1 || true)

if [ -z "${URL:-}" ]; then
  echo "[ezdora][toolbox] Não foi possível detectar a URL da versão mais recente." >&2
  exit 1
fi

curl -fsSLo toolbox.tar.gz "$URL"
tar -xzf toolbox.tar.gz

# Find extracted directory (matches jetbrains-toolbox-*/)
DIR=$(find . -maxdepth 1 -type d -name 'jetbrains-toolbox-*' | head -n1)
if [ -z "${DIR:-}" ]; then
  echo "[ezdora][toolbox] Arquivo extraído, mas diretório não encontrado." >&2
  exit 1
fi

# Move to ~/.local/share/JetBrains/Toolbox
DEST="$HOME/.local/share/JetBrains/Toolbox"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -a "$DIR"/* "$DEST"/

# Symlink into ~/.local/bin
ln -sf "$DEST/jetbrains-toolbox" "$HOME/.local/bin/jetbrains-toolbox"

# Ensure ~/.local/bin is on PATH for CLI shells (zsh/bash)
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  touch "$rc"
  if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$rc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
  fi
done

# First run in background to initialize and create desktop entries
nohup "$DEST/jetbrains-toolbox" --minimize >/dev/null 2>&1 & disown || true

echo "[ezdora][toolbox] Instalado. Comando disponível: 'jetbrains-toolbox'. Primeira execução iniciada em segundo plano."
