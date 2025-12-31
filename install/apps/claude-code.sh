#!/usr/bin/env bash
set -euo pipefail

# Ensure npm global bin is in PATH
export PATH="$HOME/.npm-global/bin:$PATH"

if command -v claude >/dev/null 2>&1; then
  echo "[ezdora][claude-code] Already installed. Skipping."
  exit 0
fi

echo "[ezdora][claude-code] Installing Claude Code via npm..."

# Ensure npm global directory exists and is configured
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global" 2>/dev/null || true

# Install Claude Code globally
npm install -g @anthropic-ai/claude-code

# Verify installation
if command -v claude >/dev/null 2>&1; then
  CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
  echo "[ezdora][claude-code] Installed successfully: $CLAUDE_VERSION"
else
  echo "[ezdora][claude-code] ERROR: Installation failed"
  exit 1
fi

# Create basic ~/.claude structure if it doesn't exist
if [ ! -d "$HOME/.claude" ]; then
  echo "[ezdora][claude-code] Creating ~/.claude directory structure..."
  mkdir -p "$HOME/.claude"
  mkdir -p "$HOME/.claude/plugins"
  mkdir -p "$HOME/.claude/projects"

  # Copy settings template if available
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  TEMPLATES_DIR="$SCRIPT_DIR/../templates/claude"

  if [ -f "$TEMPLATES_DIR/settings.json.template" ]; then
    cp "$TEMPLATES_DIR/settings.json.template" "$HOME/.claude/settings.json"
    echo "[ezdora][claude-code] Copied default settings.json"
  fi
fi

echo "[ezdora][claude-code] Done."
echo "[ezdora][claude-code] Run 'claude' to start, or 'claude auth' to authenticate."
echo "[ezdora][claude-code] TIP: Add ~/.npm-global/bin to your PATH in .zshrc"
