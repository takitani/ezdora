#!/usr/bin/env bash
set -euo pipefail

# Only apply on KDE/Plasma sessions
if [[ "${XDG_CURRENT_DESKTOP:-}" != *KDE* && "${XDG_CURRENT_DESKTOP:-}" != *PLASMA* && "${XDG_SESSION_DESKTOP:-}" != *plasma* ]]; then
  exit 0
fi

# Ensure Ghostty is installed
if ! command -v ghostty >/dev/null 2>&1 && ! rpm -q ghostty >/dev/null 2>&1; then
  echo "[ezdora][kde] Ghostty não instalado ainda; adiando configuração do terminal padrão."
  exit 0
fi

APP_ID="dev.kdrag0n.Ghostty.desktop"
KW=kwriteconfig6
if ! command -v kwriteconfig6 >/dev/null 2>&1; then
  if command -v kwriteconfig5 >/dev/null 2>&1; then
    KW=kwriteconfig5
  else
    echo "[ezdora][kde] kwriteconfig não encontrado; não foi possível definir terminal padrão."
    exit 0
  fi
fi

echo "[ezdora][kde] Definindo Ghostty como terminal padrão no KDE..."
$KW --file kdeglobals --group General --key TerminalApplication ghostty
$KW --file kdeglobals --group General --key TerminalService "$APP_ID"

echo "[ezdora][kde] Terminal padrão definido para Ghostty. Pode ser necessário reabrir a sessão."

