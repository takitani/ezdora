#!/usr/bin/env bash
set -euo pipefail

# Install JetBrains Toolbox using official tarball (best for Fedora; auto-updates itself).
# Provides wrapper at ~/.local/bin/jetbrains-toolbox, .desktop, and autostart.

# Skip if JetBrains Toolbox is already installed and running
TOOLBOX_BINARY="$HOME/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox"
TOOLBOX_BINARY_OLD="$HOME/.local/share/JetBrains/Toolbox/jetbrains-toolbox"
TOOLBOX_WRAPPER="$HOME/.local/bin/jetbrains-toolbox"

# Check both possible binary locations (new: bin/jetbrains-toolbox, old: jetbrains-toolbox)
if [ -x "$TOOLBOX_BINARY" ] || [ -x "$TOOLBOX_BINARY_OLD" ]; then
  if [ -x "$TOOLBOX_BINARY" ]; then
    EXISTING_BIN="$TOOLBOX_BINARY"
  else
    EXISTING_BIN="$TOOLBOX_BINARY_OLD"
  fi

  # Check if wrapper exists and works
  if [ -f "$TOOLBOX_WRAPPER" ] && [ -x "$TOOLBOX_WRAPPER" ]; then
    echo "[ezdora][toolbox] JetBrains Toolbox já está instalado. Pulando."
    exit 0
  fi

  # If binary exists but wrapper is broken, just recreate wrapper
  echo "[ezdora][toolbox] Reparando wrapper do JetBrains Toolbox..."
  mkdir -p "$HOME/.local/bin"
  cat > "$TOOLBOX_WRAPPER" <<EOF
#!/usr/bin/env bash
exec "$EXISTING_BIN" "\$@"
EOF
  chmod +x "$TOOLBOX_WRAPPER"
  echo "[ezdora][toolbox] Wrapper reparado. JetBrains Toolbox está pronto."
  exit 0
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

# Discover latest download URL from JetBrains releases API (with aggressive timeout)
URL=""
API_URL="https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"

echo "[ezdora][toolbox] Verificando última versão (timeout: 10s)..."
if command -v python3 >/dev/null 2>&1; then
  URL=$(timeout 10 python3 - <<'PY'
import json,urllib.request,socket
socket.setdefaulttimeout(8)
u='https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release'
data=json.load(urllib.request.urlopen(u))
print(data['TBA'][0]['downloads']['linux']['link'])
PY
  2>/dev/null || true)
fi

if [ -z "${URL:-}" ]; then
  echo "[ezdora][toolbox] Python falhou, tentando curl..."
  URL=$(timeout 10 curl -fsSL --connect-timeout 8 --max-time 10 "$API_URL" \
    | timeout 5 grep -oE 'https:[^"]+jetbrains-toolbox-[^"]+\.tar\.gz' \
    | head -n1 2>/dev/null || true)
fi

if [ -z "${URL:-}" ]; then
  echo "[ezdora][toolbox] API indisponível. Usando URL de fallback..."
  # Fallback para URL conhecida (pode ser versão mais antiga)
  URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.2.35332.tar.gz"
fi

echo "[ezdora][toolbox] Baixando de: $URL"
curl -fL --connect-timeout 15 --max-time 120 --retry 2 --retry-all-errors -H 'User-Agent: Mozilla/5.0' -o toolbox.tar.gz "$URL"
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
mkdir -p "$DEST"

# Remove only the binary files, preserve user data (cache, config, logs)
rm -f "$DEST/jetbrains-toolbox" 2>/dev/null || true
rm -rf "$DEST/bin" 2>/dev/null || true
rm -f "$DEST"/*.so* 2>/dev/null || true
rm -f "$DEST"/*.svg 2>/dev/null || true

# Copy new files
cp -a "$DIR"/* "$DEST"/
chmod +x "$DEST/jetbrains-toolbox" 2>/dev/null || true
chmod +x "$DEST/bin/jetbrains-toolbox" 2>/dev/null || true

# Determine actual binary path (check bin/ subdirectory first, then root)
if [ -x "$DEST/bin/jetbrains-toolbox" ]; then
  TARGET_BIN="$DEST/bin/jetbrains-toolbox"
elif [ -x "$DEST/jetbrains-toolbox" ]; then
  TARGET_BIN="$DEST/jetbrains-toolbox"
else
  # Fallback: search for it
  ALT=$(find "$DEST" -maxdepth 3 -type f -name 'jetbrains-toolbox' -perm -111 2>/dev/null | head -n1)
  if [ -n "$ALT" ]; then
    TARGET_BIN="$ALT"
  else
    echo "[ezdora][toolbox] Binário jetbrains-toolbox não encontrado após extração." >&2
    exit 1
  fi
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
