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

# Limpa atalhos conflitantes do Konsole primeiro
$KW --file kglobalshortcutsrc --group "org.kde.konsole.desktop" --key "_launch" "none,none,Konsole"

# Configura o atalho para o Ghostty de forma mais completa
# Formato: "shortcut,default,description"
$KW --file kglobalshortcutsrc --group "com.mitchellh.ghostty.desktop" --key "_launch" "Ctrl+Alt+T,Ctrl+Alt+T,Launch Ghostty"
$KW --file kglobalshortcutsrc --group "com.mitchellh.ghostty.desktop" --key "_k_friendly_name" "Ghostty"

# Também adiciona na seção services (alguns KDE usam isso)
$KW --file kglobalshortcutsrc --group "services][com.mitchellh.ghostty.desktop" --key "_launch" "Ctrl+Alt+T"

echo "[ezdora][kde] Atalho Ctrl+Alt+T configurado para Ghostty"

# Recarrega os atalhos globais
if command -v qdbus6 >/dev/null 2>&1; then
  qdbus6 org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel.reloadConfig 2>/dev/null || true
elif command -v qdbus >/dev/null 2>&1; then
  qdbus org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel.reloadConfig 2>/dev/null || true
fi