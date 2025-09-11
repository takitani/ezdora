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
chmod +x "$DEST/jetbrains-toolbox" 2>/dev/null || true

# Symlink into ~/.local/bin
# Create/repair symlink into ~/.local/bin. If the main binary isn't where
# expected (future changes), locate it within Toolbox dir.
TARGET_BIN="$DEST/jetbrains-toolbox"
if [ ! -x "$TARGET_BIN" ]; then
  ALT=$(find "$DEST" -maxdepth 2 -type f -name 'jetbrains-toolbox' -perm -111 2>/dev/null | head -n1)
  if [ -n "$ALT" ]; then TARGET_BIN="$ALT"; fi
fi
ln -sf "$TARGET_BIN" "$HOME/.local/bin/jetbrains-toolbox"

# Sanity check: warn if symlink target missing
if [ ! -x "$HOME/.local/bin/jetbrains-toolbox" ]; then
  echo "[ezdora][toolbox] Aviso: symlink não resolvido. Verifique $TARGET_BIN"
fi

# Ensure ~/.local/bin is on PATH for CLI shells (zsh/bash)
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  touch "$rc"
  if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$rc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
  fi
done

# Create desktop entry (menu launcher)
APP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR"
cat > "$APP_DIR/jetbrains-toolbox.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=JetBrains Toolbox
Comment=Manage and update JetBrains IDEs
Exec=$HOME/.local/bin/jetbrains-toolbox
Icon=$DEST/jetbrains-toolbox.svg
Terminal=false
Categories=Development;Utility;
StartupNotify=false
EOF

# Autostart minimized on login
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
cat > "$AUTOSTART_DIR/jetbrains-toolbox.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=JetBrains Toolbox
Comment=Start JetBrains Toolbox on login
Exec=$DEST/jetbrains-toolbox --minimize
Terminal=false
X-GNOME-Autostart-enabled=true
OnlyShowIn=KDE;GNOME;XFCE;Unity;
EOF

update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true

# First run in background to initialize and create desktop entries
nohup "$DEST/jetbrains-toolbox" --minimize >/dev/null 2>&1 & disown || true

echo "[ezdora][toolbox] Instalado. Comando disponível: 'jetbrains-toolbox'. Primeira execução iniciada em segundo plano."
