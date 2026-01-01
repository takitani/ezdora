#!/usr/bin/env bash
set -euo pipefail

# EzDora Zshrc Setup
# Generates ~/.zshrc from template with user customizations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../templates/zshrc.template"
TARGET="$HOME/.zshrc"
CONFIG_FILE="$HOME/.ezdora-config"

echo "[ezdora][zshrc-setup] Setting up .zshrc..."

# Check if template exists
if [ ! -f "$TEMPLATE" ]; then
  echo "[ezdora][zshrc-setup] ERROR: Template not found at $TEMPLATE"
  exit 1
fi

# Backup existing .zshrc if it exists
if [ -f "$TARGET" ]; then
  BACKUP="$TARGET.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$TARGET" "$BACKUP"
  echo "[ezdora][zshrc-setup] Backed up existing .zshrc to $BACKUP"
fi

# Copy template
cp "$TEMPLATE" "$TARGET"

# Load config file if exists (for non-interactive setup)
if [ -f "$CONFIG_FILE" ]; then
  echo "[ezdora][zshrc-setup] Loading configuration from $CONFIG_FILE..."
  source "$CONFIG_FILE"
fi

# Function to replace placeholder
replace_placeholder() {
  local placeholder="$1"
  local value="$2"
  if [ -n "$value" ]; then
    sed -i "s|{{${placeholder}}}|${value}|g" "$TARGET"
  fi
}

# Interactive mode check
if [ "${EZDORA_AUTOMATED:-}" != "true" ] && [ -z "${CLAUDE_UUID_TEAM_MAX:-}" ]; then
  echo ""
  echo "=== Optional Configuration ==="
  echo "Leave blank to skip (you can edit ~/.zshrc later)"
  echo ""

  if command -v gum >/dev/null 2>&1; then
    # 1Password account (for CLI integration)
    echo "1Password account name (e.g., 'myteam' from myteam.1password.com):"
    OP_ACCOUNT=$(gum input --placeholder "1Password account (optional)" 2>/dev/null || echo "")

    # Claude UUIDs (optional)
    echo ""
    echo "Claude organization UUIDs (from console.anthropic.com/settings/organization):"
    CLAUDE_UUID_TEAM_MAX=$(gum input --placeholder "Team Max UUID (optional)" 2>/dev/null || echo "")
    CLAUDE_UUID_TEAM=$(gum input --placeholder "Team UUID (optional)" 2>/dev/null || echo "")
    CLAUDE_UUID_PERSONAL=$(gum input --placeholder "Personal UUID (optional)" 2>/dev/null || echo "")
    CLAUDE_UUID_PROTON=$(gum input --placeholder "Additional UUID (optional)" 2>/dev/null || echo "")
  else
    read -p "1Password account (optional, e.g., 'myteam'): " OP_ACCOUNT
    read -p "Claude Team Max UUID (optional): " CLAUDE_UUID_TEAM_MAX
    read -p "Claude Team UUID (optional): " CLAUDE_UUID_TEAM
    read -p "Claude Personal UUID (optional): " CLAUDE_UUID_PERSONAL
    read -p "Additional UUID (optional): " CLAUDE_UUID_PROTON
  fi
fi

# Replace placeholders with configured values
replace_placeholder "CLAUDE_UUID_TEAM_MAX" "${CLAUDE_UUID_TEAM_MAX:-}"
replace_placeholder "CLAUDE_UUID_TEAM" "${CLAUDE_UUID_TEAM:-}"
replace_placeholder "CLAUDE_UUID_PERSONAL" "${CLAUDE_UUID_PERSONAL:-}"
replace_placeholder "CLAUDE_UUID_PROTON" "${CLAUDE_UUID_PROTON:-}"
replace_placeholder "GOOGLE_API_KEY" "${GOOGLE_API_KEY:-}"
replace_placeholder "GEMINI_API_KEY" "${GEMINI_API_KEY:-}"
replace_placeholder "OP_ACCOUNT" "${OP_ACCOUNT:-}"
replace_placeholder "JETBRAINS_TOOLBOX_PATH" "${JETBRAINS_TOOLBOX_PATH:-\$HOME/.local/share/JetBrains/Toolbox/scripts}"

# Set default shell to zsh if not already
if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
  echo "[ezdora][zshrc-setup] Setting zsh as default shell..."
  chsh -s /usr/bin/zsh 2>/dev/null || {
    echo "[ezdora][zshrc-setup] Note: Could not change default shell. Run: chsh -s /usr/bin/zsh"
  }
fi

echo "[ezdora][zshrc-setup] Done."
echo "[ezdora][zshrc-setup] .zshrc created at: $TARGET"
echo "[ezdora][zshrc-setup] TIP: Create ~/.zshrc.local for custom aliases (auto-loaded)"
echo "[ezdora][zshrc-setup] Restart terminal or run: source ~/.zshrc"
