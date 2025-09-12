#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][keyboard] Configurando layouts de teclado..."

# Verifica se está no KDE
if [[ "$XDG_CURRENT_DESKTOP" != "KDE" ]] && [[ "$DESKTOP_SESSION" != *"plasma"* ]]; then
  echo "[ezdora][keyboard] Não está rodando KDE, pulando configuração de teclado"
  exit 0
fi

# Verifica layouts atuais do KDE
current_layouts=$(kreadconfig6 --file kxkbrc --group Layout --key LayoutList 2>/dev/null || echo "")
echo "[ezdora][keyboard] Layouts atuais: '$current_layouts'"

# Se só tem 'us' ou está vazio, configura para ter us,us(intl) com intl como padrão
if [[ -z "$current_layouts" ]] || [[ "$current_layouts" == "us" ]]; then
  echo "[ezdora][keyboard] Detectado apenas teclado EN US padrão ou nenhum configurado"
  echo "[ezdora][keyboard] Configurando: EN US International (padrão) + EN US (secundário)"
  
  # Configura os layouts: us(intl) como primeiro (padrão), us como segundo
  kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "us,us"
  kwriteconfig6 --file kxkbrc --group Layout --key VariantList "intl,"
  kwriteconfig6 --file kxkbrc --group Layout --key DisplayNames "US,US"
  
  # Habilita troca de teclado
  kwriteconfig6 --file kxkbrc --group Layout --key Use true
  kwriteconfig6 --file kxkbrc --group Layout --key SwitchMode Global
  
  # Define atalho para trocar (Alt+Shift é padrão comum)
  kwriteconfig6 --file kxkbrc --group Layout --key Options "grp:alt_shift_toggle"
  
  # Aplica as mudanças reiniciando o serviço de teclado do KDE
  if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.keyboard /Layouts setLayout 0 2>/dev/null || true
  elif command -v qdbus >/dev/null 2>&1; then
    qdbus org.kde.keyboard /Layouts setLayout 0 2>/dev/null || true
  fi
  
  echo "[ezdora][keyboard] Configuração aplicada:"
  echo "  - Layout padrão: EN US International (para acentos com dead keys)"
  echo "  - Layout secundário: EN US (padrão americano)"
  echo "  - Atalho para trocar: Alt+Shift"
  echo "[ezdora][keyboard] Reinicie a sessão ou faça logout/login para aplicar completamente"
  
elif [[ "$current_layouts" == *"us"* ]] && [[ "$current_layouts" != *"intl"* ]]; then
  echo "[ezdora][keyboard] Detectado EN US mas sem International, adicionando..."
  
  # Se já tem layouts mas não tem intl, adiciona o intl como primeiro
  kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "us,$current_layouts"
  
  # Pega variants atuais e adiciona intl no início
  current_variants=$(kreadconfig6 --file kxkbrc --group Layout --key VariantList 2>/dev/null || echo "")
  kwriteconfig6 --file kxkbrc --group Layout --key VariantList "intl,$current_variants"
  
  # Atualiza display names
  current_displays=$(kreadconfig6 --file kxkbrc --group Layout --key DisplayNames 2>/dev/null || echo "")
  kwriteconfig6 --file kxkbrc --group Layout --key DisplayNames "US,$current_displays"
  
  # Habilita e configura troca
  kwriteconfig6 --file kxkbrc --group Layout --key Use true
  kwriteconfig6 --file kxkbrc --group Layout --key SwitchMode Global
  kwriteconfig6 --file kxkbrc --group Layout --key Options "grp:alt_shift_toggle"
  
  echo "[ezdora][keyboard] EN US International adicionado como layout padrão"
  echo "  - Atalho para trocar: Alt+Shift"
  
else
  echo "[ezdora][keyboard] Já possui layouts configurados incluindo variantes, mantendo configuração atual"
fi

echo "[ezdora][keyboard] Configuração de teclado concluída"