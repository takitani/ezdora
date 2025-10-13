#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora/inotify] Configurando limites do inotify..."

# Verifica limites atuais
CURRENT_INSTANCES=$(cat /proc/sys/fs/inotify/max_user_instances)
CURRENT_WATCHES=$(cat /proc/sys/fs/inotify/max_user_watches)

echo "[ezdora/inotify] Limites atuais:"
echo "  max_user_instances: $CURRENT_INSTANCES"
echo "  max_user_watches: $CURRENT_WATCHES"

# Define novos limites (adequados para desenvolvimento com IDEs, Docker, etc)
NEW_INSTANCES=512
NEW_WATCHES=524288

# Cria arquivo de configuração sysctl
echo "[ezdora/inotify] Criando /etc/sysctl.d/99-inotify.conf..."
sudo tee /etc/sysctl.d/99-inotify.conf > /dev/null << EOF
# Aumenta limites do inotify para desenvolvimento
# Necessário para IDEs, Docker, editores e ferramentas de build
fs.inotify.max_user_instances=$NEW_INSTANCES
fs.inotify.max_user_watches=$NEW_WATCHES
EOF

# Aplica as mudanças imediatamente
echo "[ezdora/inotify] Aplicando configuração..."
sudo sysctl -p /etc/sysctl.d/99-inotify.conf > /dev/null

# Verifica novos limites
NEW_INSTANCES_VALUE=$(cat /proc/sys/fs/inotify/max_user_instances)
NEW_WATCHES_VALUE=$(cat /proc/sys/fs/inotify/max_user_watches)

echo "[ezdora/inotify] Novos limites aplicados:"
echo "  max_user_instances: $NEW_INSTANCES_VALUE"
echo "  max_user_watches: $NEW_WATCHES_VALUE"
echo "[ezdora/inotify] ✓ Configuração concluída!"
