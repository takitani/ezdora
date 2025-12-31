#!/usr/bin/env bash
set -euo pipefail

# Claude Code MCP Servers Setup
# Installs common MCP servers for enhanced Claude Code functionality

echo "[ezdora][claude-mcp] Setting up MCP servers..."

# Ensure uv/uvx is available (required for serena)
if ! command -v uvx >/dev/null 2>&1; then
  echo "[ezdora][claude-mcp] uvx not found. Installing uv first..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# Verify uvx is now available
if ! command -v uvx >/dev/null 2>&1; then
  echo "[ezdora][claude-mcp] ERROR: uvx still not available after installation"
  exit 1
fi

echo "[ezdora][claude-mcp] uvx is available"

# Pre-download serena to cache it (optional, speeds up first run)
echo "[ezdora][claude-mcp] Pre-caching serena MCP server..."
uvx --from "git+https://github.com/oraios/serena" serena --version 2>/dev/null || true

# Install claude-mem plugin if claude is available
if command -v claude >/dev/null 2>&1; then
  echo "[ezdora][claude-mcp] Installing claude-mem plugin..."
  claude plugins install claude-mem@thedotmack 2>/dev/null || {
    echo "[ezdora][claude-mcp] Note: claude-mem installation skipped (may need auth first)"
  }
fi

# Create/update settings.local.json with MCP servers configuration
SETTINGS_LOCAL="$HOME/.claude/settings.local.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../templates/claude/settings.local.json.template"

if [ ! -f "$SETTINGS_LOCAL" ] && [ -f "$TEMPLATE" ]; then
  echo "[ezdora][claude-mcp] Creating settings.local.json from template..."
  mkdir -p "$HOME/.claude"
  cp "$TEMPLATE" "$SETTINGS_LOCAL"
  echo "[ezdora][claude-mcp] Created settings.local.json with MCP servers configured"
else
  echo "[ezdora][claude-mcp] settings.local.json already exists, preserving..."
fi

echo "[ezdora][claude-mcp] Done."
echo "[ezdora][claude-mcp] MCP servers configured:"
echo "  - serena: Semantic code navigation (via uvx)"
echo "  - claude-mem: Memory/context management (plugin)"
