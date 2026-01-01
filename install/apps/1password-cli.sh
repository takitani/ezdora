#!/usr/bin/env bash
set -euo pipefail

# 1Password CLI - Command line interface for 1Password
# https://developer.1password.com/docs/cli/

export PATH="$HOME/.local/bin:$PATH"

if command -v op >/dev/null 2>&1; then
  echo "[ezdora][1password-cli] Already installed. Skipping."
  exit 0
fi

echo "[ezdora][1password-cli] Installing 1Password CLI..."

# Ensure target directory exists
mkdir -p "$HOME/.local/bin"

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) OP_ARCH="amd64" ;;
  aarch64) OP_ARCH="arm64" ;;
  *) echo "[ezdora][1password-cli] Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Check for unzip dependency
if ! command -v unzip >/dev/null 2>&1; then
  echo "[ezdora][1password-cli] Installing unzip dependency..."
  sudo dnf install -y unzip
fi

# Download latest release from 1Password
echo "[ezdora][1password-cli] Downloading from 1Password..."
DOWNLOAD_URL="https://cache.agilebits.com/dist/1P/op2/pkg/v2.30.0/op_linux_${OP_ARCH}_v2.30.0.zip"

# Download and extract
cd /tmp
curl -Lso op.zip "$DOWNLOAD_URL"
unzip -o op.zip op
mv op "$HOME/.local/bin/op"
chmod +x "$HOME/.local/bin/op"
rm -f op.zip op.sig

# Verify installation
if command -v op >/dev/null 2>&1; then
  OP_VERSION=$(op --version 2>/dev/null || echo "unknown")
  echo "[ezdora][1password-cli] Installed successfully: $OP_VERSION"
else
  echo "[ezdora][1password-cli] ERROR: Installation failed"
  exit 1
fi

echo "[ezdora][1password-cli] Done."
echo "[ezdora][1password-cli] Usage:"
echo "  op account add    # Add your 1Password account"
echo "  op signin         # Sign in to your account"
echo "  op item get <id>  # Get an item"
