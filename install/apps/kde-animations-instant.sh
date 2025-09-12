#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][kde-animations] Configurando animações do KDE para Instant (sem animações)..."

# Verifica se está no KDE
if [ "$XDG_CURRENT_DESKTOP" != "KDE" ]; then
  echo "[ezdora][kde-animations] Não está rodando KDE, pulando configuração de animações"
  exit 0
fi

# Configura velocidade global de animação para instant (0 = instant, 10 = mais lento)
kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor 0

# Desabilita animações específicas de janelas
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_fadeEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_scaleEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_squashEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_maximizeEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_morphingpopupsEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_translucencyEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key slidingpopupsEnabled false

# Configura animações de desktop para instant
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_desktopgridEnabled true
kwriteconfig6 --file kwinrc --group Effect-DesktopGrid --key Duration 0

# Configura troca de virtual desktop para instant
kwriteconfig6 --file kwinrc --group Plugins --key slideEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_fadedesktopEnabled false

# Desabilita animações de login/logout
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_loginEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key kwin4_effect_logoutEnabled false

# Configura Plasma animations para instant
kwriteconfig6 --file plasmarc --group PlasmaViews --key AnimationSpeed 0

# Aplica as mudanças reiniciando o kwin
if command -v qdbus6 >/dev/null 2>&1; then
  qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
elif command -v qdbus >/dev/null 2>&1; then
  qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
fi

# Reinicia plasmashell para aplicar mudanças do Plasma
kquitapp6 plasmashell 2>/dev/null || kquitapp5 plasmashell 2>/dev/null || true
sleep 1
kstart5 plasmashell 2>/dev/null &

echo "[ezdora][kde-animations] Animações configuradas para Instant (desabilitadas)"
echo "[ezdora][kde-animations] Pode ser necessário fazer logout/login para aplicar completamente"