#!/usr/bin/env bash
set -euo pipefail

# Bitwarden CLI - Password manager command line interface
# https://bitwarden.com/help/cli/

export PATH="$HOME/.local/bin:$PATH"

if command -v bw >/dev/null 2>&1; then
  echo "[ezdora][bitwarden-cli] Already installed. Skipping."
  exit 0
fi

echo "[ezdora][bitwarden-cli] Installing Bitwarden CLI..."

# Ensure target directory exists
mkdir -p "$HOME/.local/bin"

# Download latest release
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) BW_ARCH="linux" ;;
  aarch64) BW_ARCH="linux" ;; # ARM support
  *) echo "[ezdora][bitwarden-cli] Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Get latest version URL from GitHub
echo "[ezdora][bitwarden-cli] Downloading from GitHub..."
DOWNLOAD_URL="https://vault.bitwarden.com/download/?app=cli&platform=linux"

# Download and extract
cd /tmp
curl -Lso bw.zip "$DOWNLOAD_URL"
unzip -o bw.zip
mv bw "$HOME/.local/bin/bw"
chmod +x "$HOME/.local/bin/bw"
rm -f bw.zip

# Verify installation
if command -v bw >/dev/null 2>&1; then
  BW_VERSION=$(bw --version 2>/dev/null || echo "unknown")
  echo "[ezdora][bitwarden-cli] Installed successfully: $BW_VERSION"
else
  echo "[ezdora][bitwarden-cli] ERROR: Installation failed"
  exit 1
fi

echo "[ezdora][bitwarden-cli] Done."
echo "[ezdora][bitwarden-cli] Usage:"
echo "  bw login           # First time login"
echo "  bw unlock          # Unlock vault (returns session key)"
echo "  bw get item <name> # Get an item"
