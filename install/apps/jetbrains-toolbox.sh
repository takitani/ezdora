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

echo "[ezdora][toolbox] Instalado. Inicie com 'jetbrains-toolbox' (criará ícones e atualizações)."

