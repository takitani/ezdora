#!/usr/bin/env bash
set -euo pipefail

# Only apply on KDE/Plasma sessions
if [[ "${XDG_CURRENT_DESKTOP:-}" != *KDE* && "${XDG_CURRENT_DESKTOP:-}" != *PLASMA* && "${XDG_SESSION_DESKTOP:-}" != *plasma* ]]; then
  echo "[ezdora][kde] Não é uma sessão KDE/Plasma. Pulando configuração."
  exit 0
fi

# Ensure Ghostty is installed
if ! command -v ghostty >/dev/null 2>&1 && ! rpm -q ghostty >/dev/null 2>&1; then
  echo "[ezdora][kde] Ghostty não instalado ainda; adiando configuração do terminal padrão."
  exit 0
fi

# Find kwriteconfig tool
KW=""
for tool in kwriteconfig6 kwriteconfig5; do
  if command -v "$tool" >/dev/null 2>&1; then
    KW="$tool"
    break
  fi
done

if [ -z "$KW" ]; then
  echo "[ezdora][kde] kwriteconfig não encontrado; não foi possível definir terminal padrão."
  exit 1
fi

echo "[ezdora][kde] Configurando atalho Ctrl+Alt+T para Ghostty..."

# Verifica se já existe a configuração para evitar duplicação
CURRENT_VALUE=$(kreadconfig6 --file kglobalshortcutsrc --group "services][com.mitchellh.ghostty.desktop" --key "_launch" 2>/dev/null || echo "")

if [ "$CURRENT_VALUE" = "Ctrl+Alt+T" ]; then
  echo "[ezdora][kde] Atalho Ctrl+Alt+T já configurado para Ghostty"
else
  # Configura o atalho no arquivo kglobalshortcutsrc
  $KW --file kglobalshortcutsrc --group "services][com.mitchellh.ghostty.desktop" --key "_launch" "Ctrl+Alt+T"
  echo "[ezdora][kde] Atalho Ctrl+Alt+T configurado para Ghostty"
  
  # Recarrega os atalhos globais
  if command -v kquitapp6 >/dev/null 2>&1; then
    kquitapp6 kglobalaccel 2>/dev/null || true
    sleep 1
  elif command -v kquitapp5 >/dev/null 2>&1; then
    kquitapp5 kglobalaccel 2>/dev/null || true
    sleep 1
  fi
fi