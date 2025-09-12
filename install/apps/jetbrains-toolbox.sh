#!/usr/bin/env bash
set -euo pipefail

# Install JetBrains Toolbox using official tarball (best for Fedora; auto-updates itself).
# Provides wrapper at ~/.local/bin/jetbrains-toolbox, .desktop, and autostart.

# Skip if JetBrains Toolbox is already installed and running
TOOLBOX_BINARY="$HOME/.local/share/JetBrains/Toolbox/jetbrains-toolbox"
TOOLBOX_WRAPPER="$HOME/.local/bin/jetbrains-toolbox"

if [ -x "$TOOLBOX_BINARY" ] && [ -f "$TOOLBOX_WRAPPER" ]; then
  # Check if Toolbox is actually working (can show version)
  if "$TOOLBOX_BINARY" --version >/dev/null 2>&1 || pgrep -f "jetbrains-toolbox" >/dev/null 2>&1; then
    echo "[ezdora][toolbox] JetBrains Toolbox já está instalado e funcionando. Pulando."
    exit 0
  else
    echo "[ezdora][toolbox] JetBrains Toolbox encontrado mas não está funcionando, reinstalando..."
  fi
fi

# If an old symlink exists in ~/.local/bin, remove it so we always repair to a wrapper
if [ -L "$HOME/.local/bin/jetbrains-toolbox" ]; then
  echo "[ezdora][toolbox] Reparando symlink antigo em ~/.local/bin/jetbrains-toolbox"
  rm -f "$HOME/.local/bin/jetbrains-toolbox"
fi

echo "[ezdora][toolbox] Instalando JetBrains Toolbox..."

mkdir -p "$HOME/.local/share/JetBrains" "$HOME/.local/bin"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
cd "$tmpdir"

# Discover latest download URL from JetBrains releases API (robust)
URL=""
if command -v python3 >/dev/null 2>&1; then
  URL=$(python3 - <<'PY'
import json,urllib.request
u='https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release'
data=json.load(urllib.request.urlopen(u))
print(data['TBA'][0]['downloads']['linux']['link'])
PY
  2>/dev/null || true)
fi
if [ -z "${URL:-}" ]; then
  URL=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" \
    | grep -oE 'https:[^"]+jetbrains-toolbox-[^"]+\.tar\.gz' \
    | head -n1 || true)
fi

if [ -z "${URL:-}" ]; then
  echo "[ezdora][toolbox] Não foi possível detectar a URL da versão mais recente." >&2
  exit 1
fi

curl -fL --retry 3 --retry-all-errors -H 'User-Agent: Mozilla/5.0' -o toolbox.tar.gz "$URL"
if ! file toolbox.tar.gz | grep -qi 'gzip compressed data'; then
  echo "[ezdora][toolbox] Download inválido (não é tar.gz)." >&2
  exit 1
fi
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

# Determine actual binary path
TARGET_BIN="$DEST/jetbrains-toolbox"
if [ ! -x "$TARGET_BIN" ]; then
  ALT=$(find "$DEST" -maxdepth 3 -type f -name 'jetbrains-toolbox' -perm -111 2>/dev/null | head -n1)
  if [ -n "$ALT" ]; then TARGET_BIN="$ALT"; fi
fi

# Wrapper script into ~/.local/bin (more robust than symlink)
# Remove any previous symlink to avoid writing through it
rm -f "$HOME/.local/bin/jetbrains-toolbox"
cat > "$HOME/.local/bin/jetbrains-toolbox" <<EOF
#!/usr/bin/env bash
exec "$TARGET_BIN" "\$@"
EOF
chmod +x "$HOME/.local/bin/jetbrains-toolbox"

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
OnlyShowIn=KDE;
EOF

update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true

# First run in background to initialize and create desktop entries
nohup "$DEST/jetbrains-toolbox" --minimize >/dev/null 2>&1 & disown || true

echo "[ezdora][toolbox] Instalado. Comando disponível: 'jetbrains-toolbox'. Primeira execução iniciada em segundo plano."
