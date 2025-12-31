#!/usr/bin/env bash
set -euo pipefail

# uv - Fast Python package manager from Astral
# https://astral.sh/uv

export PATH="$HOME/.local/bin:$PATH"

if command -v uv >/dev/null 2>&1; then
  echo "[ezdora][uv] Already installed. Skipping."
  exit 0
fi

echo "[ezdora][uv] Installing uv (fast Python package manager)..."

# Install uv via official installer
curl -LsSf https://astral.sh/uv/install.sh | sh

# Verify installation
export PATH="$HOME/.local/bin:$PATH"
if command -v uv >/dev/null 2>&1; then
  UV_VERSION=$(uv --version 2>/dev/null || echo "unknown")
  echo "[ezdora][uv] Installed successfully: $UV_VERSION"
else
  echo "[ezdora][uv] ERROR: Installation failed"
  exit 1
fi

echo "[ezdora][uv] Done."
echo "[ezdora][uv] Usage: uv pip install <package>"
echo "[ezdora][uv] uvx: Run tools without installing (e.g., uvx ruff check .)"
