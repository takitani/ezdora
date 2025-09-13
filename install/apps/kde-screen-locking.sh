#!/usr/bin/env bash
set -euo pipefail

# Configure KDE screen locking settings
# - Auto lock after 30 minutes
# - Require password immediately (no delay)

echo "[ezdora][kde-screen-locking] Configurando bloqueio de tela do KDE..."

# Check if we're in a KDE environment
if [ -z "${XDG_CURRENT_DESKTOP:-}" ] || [[ ! "$XDG_CURRENT_DESKTOP" =~ KDE ]]; then
  echo "[ezdora][kde-screen-locking] Aviso: Não detectado ambiente KDE. Pulando configuração."
  exit 0
fi

# KDE screen locking configuration file
KSCREENLOCKER_CONFIG="$HOME/.config/kscreenlockerrc"

# Create config directory if it doesn't exist
mkdir -p "$(dirname "$KSCREENLOCKER_CONFIG")"

# Configure screen locking settings
echo "[ezdora][kde-screen-locking] Aplicando configurações de bloqueio de tela..."

# Auto lock after 30 minutes
kwriteconfig5 --file "$KSCREENLOCKER_CONFIG" --group "Daemon" --key "Autolock" "true"
kwriteconfig5 --file "$KSCREENLOCKER_CONFIG" --group "Daemon" --key "Timeout" "30"

# Require password immediately (no delay)
kwriteconfig5 --file "$KSCREENLOCKER_CONFIG" --group "Daemon" --key "LockGrace" "0"

# Lock after waking from sleep
kwriteconfig5 --file "$KSCREENLOCKER_CONFIG" --group "Daemon" --key "LockOnResume" "true"

# Set keyboard shortcut to Meta+L (if not already set)
kwriteconfig5 --file "$KSCREENLOCKER_CONFIG" --group "Daemon" --key "LockCommand" "loginctl lock-session"

echo "[ezdora][kde-screen-locking] Configurações aplicadas:"
echo "[ezdora][kde-screen-locking]   - Bloqueio automático: 30 minutos"
echo "[ezdora][kde-screen-locking]   - Senha requerida: Imediatamente"
echo "[ezdora][kde-screen-locking]   - Bloquear ao acordar: Sim"
echo "[ezdora][kde-screen-locking]   - Atalho: Meta+L"

# Restart the screen locker daemon to apply changes
if command -v kscreenlocker_greet >/dev/null 2>&1; then
  echo "[ezdora][kde-screen-locking] Reiniciando daemon de bloqueio de tela..."
  # Kill existing screen locker processes
  pkill -f kscreenlocker_greet >/dev/null 2>&1 || true
  pkill -f kscreenlocker >/dev/null 2>&1 || true
  
  # Start new screen locker daemon
  kscreenlocker_greet --daemon >/dev/null 2>&1 &
  echo "[ezdora][kde-screen-locking] Daemon reiniciado com sucesso"
else
  echo "[ezdora][kde-screen-locking] Aviso: kscreenlocker_greet não encontrado"
fi

echo "[ezdora][kde-screen-locking] Configuração concluída!"
echo "[ezdora][kde-screen-locking] As configurações serão aplicadas na próxima sessão ou reinicialização do KDE."
