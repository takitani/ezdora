#!/usr/bin/env bash
set -euo pipefail

# Creates ~/.zshenv with essential PATH configuration
# This ensures PATH is set for ALL shell types (login, interactive, scripts)

ZSHENV="$HOME/.zshenv"

echo "[ezdora] Configuring ~/.zshenv for PATH..."

# Check if zshenv already has our PATH config
if [ -f "$ZSHENV" ] && grep -q "# EzDora PATH" "$ZSHENV" 2>/dev/null; then
    echo "[ezdora] ~/.zshenv already configured, skipping."
    exit 0
fi

# Create or append to zshenv
cat >> "$ZSHENV" << 'EOF'
# EzDora PATH configuration
# This file is read by ALL zsh instances (login, interactive, scripts)
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
EOF

echo "[ezdora] ~/.zshenv configured successfully."
