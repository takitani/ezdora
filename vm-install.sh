#!/usr/bin/env bash
set -euo pipefail

# VM connection settings
VM_HOST="${VM_HOST:-localhost}"
VM_PORT="${VM_PORT:-2222}"
VM_USER="${VM_USER:-opik}"

SSH_OPTS="-p $VM_PORT -o StrictHostKeyChecking=accept-new"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[ezdora] Syncing to $VM_USER@$VM_HOST:$VM_PORT..."

# Sync ezdora to VM (exclude .git for speed)
rsync -avz --delete \
  --exclude '.git' \
  --exclude '*.log' \
  -e "ssh $SSH_OPTS" \
  "$SCRIPT_DIR/" "$VM_USER@$VM_HOST:~/ezdora/"

echo "[ezdora] Running install.sh on VM..."

# Run install on VM
ssh $SSH_OPTS "$VM_USER@$VM_HOST" "cd ~/ezdora && ./install.sh"

echo "[ezdora] Done!"
