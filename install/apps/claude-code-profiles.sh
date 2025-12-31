#!/usr/bin/env bash
set -euo pipefail

# Claude Code Profiles Setup
# Creates ~/.claude-profiles/ structure for multi-account management

PROFILES_DIR="$HOME/.claude-profiles"

if [ -d "$PROFILES_DIR" ] && [ "$(ls -A "$PROFILES_DIR" 2>/dev/null)" ]; then
  echo "[ezdora][claude-profiles] Profiles already exist. Skipping."
  exit 0
fi

echo "[ezdora][claude-profiles] Creating profile directories..."

# Create profile directories
mkdir -p "$PROFILES_DIR/team-max"
mkdir -p "$PROFILES_DIR/team"
mkdir -p "$PROFILES_DIR/personal-max"
mkdir -p "$PROFILES_DIR/proton-max"

# Get templates directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates/claude/profiles"

# Copy profile templates if they exist
if [ -d "$TEMPLATES_DIR" ]; then
  for profile in team-max team personal-max proton-max; do
    if [ -f "$TEMPLATES_DIR/${profile}.json" ]; then
      cp "$TEMPLATES_DIR/${profile}.json" "$PROFILES_DIR/${profile}/settings.json"
      echo "[ezdora][claude-profiles] Created profile: $profile"
    fi
  done
fi

# Create sync-plugin-versions.sh helper script
cat > "$HOME/.claude/sync-plugin-versions.sh" << 'SYNCEOF'
#!/usr/bin/env bash
# Sync Claude plugin versions across all profiles

INSTALLED_PLUGINS="$HOME/.claude/plugins/installed_plugins.json"

if [[ ! -f "$INSTALLED_PLUGINS" ]]; then
    echo "No installed plugins found"
    exit 0
fi

# Get installed claude-mem version
INSTALLED_VER=$(jq -r '.plugins["claude-mem@thedotmack"][0].version // empty' "$INSTALLED_PLUGINS" 2>/dev/null)

if [[ -z "$INSTALLED_VER" ]]; then
    echo "claude-mem not installed"
    exit 0
fi

echo "Syncing claude-mem version: $INSTALLED_VER"

# Update main settings.local.json
if [[ -f "$HOME/.claude/settings.local.json" ]]; then
    sed -i "s|claude-mem/[0-9.]*|claude-mem/${INSTALLED_VER}|g" "$HOME/.claude/settings.local.json"
fi

# Update all profiles
for profile_file in "$HOME/.claude-profiles"/*/settings.local.json; do
    if [[ -f "$profile_file" ]]; then
        sed -i "s|claude-mem/[0-9.]*|claude-mem/${INSTALLED_VER}|g" "$profile_file"
        echo "Updated: $profile_file"
    fi
done

echo "Done!"
SYNCEOF

chmod +x "$HOME/.claude/sync-plugin-versions.sh"

echo "[ezdora][claude-profiles] Done."
echo "[ezdora][claude-profiles] Profiles created at: $PROFILES_DIR"
echo "[ezdora][claude-profiles] IMPORTANT: Edit each profile's settings.json to add your organization UUIDs"
echo "[ezdora][claude-profiles] Find your org UUID at: https://console.anthropic.com/settings/organization"
