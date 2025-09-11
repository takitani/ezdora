#!/usr/bin/env bash
set -euo pipefail

# Define Ghostty como terminal padrão e configura Ctrl+Alt+T no GNOME

# Só aplica em sessões GNOME
if [[ "${XDG_CURRENT_DESKTOP:-}" != *GNOME* && "${DESKTOP_SESSION:-}" != *gnome* ]]; then
  echo "[ezdora][gnome] Não é uma sessão GNOME. Pulando configuração."
  exit 0
fi

# Verifica se Ghostty está instalado
if ! command -v ghostty >/dev/null 2>&1 && ! rpm -q ghostty >/dev/null 2>&1; then
  echo "[ezdora][gnome] Ghostty não instalado ainda; adiando configuração do terminal padrão."
  exit 0
fi

echo "[ezdora][gnome] Definindo Ghostty como terminal padrão do GNOME..."
# Define o terminal padrão (usado por algumas integrações do GNOME)
gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty' 2>/dev/null || true
# Mantém compatibilidade com exec de comandos
gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e' 2>/dev/null || true

# Opcional: limpa binding legado do 'terminal' se existir (evita conflito)
gsettings reset org.gnome.settings-daemon.plugins.media-keys terminal 2>/dev/null || true

echo "[ezdora][gnome] Configurando atalho Ctrl+Alt+T para abrir Ghostty..."

# Caminho do atalho customizado
BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ezdora-ghostty/"

# Garante que a lista contenha apenas uma entrada para nosso atalho (idempotente)
CURRENT_LIST=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null || echo "[]")
if [[ "$CURRENT_LIST" != *"$BASE"* ]]; then
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$BASE']" 2>/dev/null || true
fi

# Define nome, binding e comando do atalho
SCHEMA_PATH="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$BASE"
gsettings set "$SCHEMA_PATH" name 'Ghostty Terminal' 2>/dev/null || true
gsettings set "$SCHEMA_PATH" binding '<Primary><Alt>t' 2>/dev/null || true
gsettings set "$SCHEMA_PATH" command 'ghostty' 2>/dev/null || true

echo "[ezdora][gnome] Terminal padrão definido e atalho configurado."

