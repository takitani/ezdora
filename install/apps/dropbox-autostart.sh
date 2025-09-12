#!/usr/bin/env bash
set -euo pipefail

# SCRIPT COMENTADO - Autostart do Dropbox desabilitado por padrão
# Usuário pode iniciar manualmente quando desejar
echo "[ezdora][dropbox-autostart] Script desabilitado - autostart não será configurado"
echo "[ezdora][dropbox-autostart] Para habilitar autostart manualmente, descomente este script"
exit 0

# CÓDIGO ORIGINAL COMENTADO:
# 
# AUTOSTART_DIR="$HOME/.config/autostart"
# mkdir -p "$AUTOSTART_DIR"
# 
# cat > "$AUTOSTART_DIR/dropbox.desktop" <<'EOF'
# [Desktop Entry]
# Type=Application
# Version=1.0
# Name=Dropbox
# GenericName=File Synchronizer
# Comment=Start Dropbox at login
# TryExec=dropbox
# Exec=dropbox start -i
# Terminal=false
# OnlyShowIn=KDE;
# X-KDE-autostart-after=panel
# EOF
# 
# echo "[ezdora][dropbox] Autostart criado em $AUTOSTART_DIR/dropbox.desktop"
