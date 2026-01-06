#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][keyboard] Configurando layouts de teclado..."

# Verifica se está no KDE
if [[ "${XDG_CURRENT_DESKTOP:-}" != "KDE" ]] && [[ "${DESKTOP_SESSION:-}" != *"plasma"* ]]; then
  echo "[ezdora][keyboard] Não está rodando KDE, pulando configuração de teclado"
  exit 0
fi

# Verifica layouts e variantes atuais do KDE
current_layouts=$(kreadconfig6 --file kxkbrc --group Layout --key LayoutList 2>/dev/null || echo "")
current_variants=$(kreadconfig6 --file kxkbrc --group Layout --key VariantList 2>/dev/null || echo "")
echo "[ezdora][keyboard] Layouts atuais: '$current_layouts'"
echo "[ezdora][keyboard] Variantes atuais: '$current_variants'"

# Verifica se já está configurado corretamente (us,us com intl,)
if [[ "$current_layouts" == "us,us" ]] && [[ "$current_variants" == "intl," ]]; then
  echo "[ezdora][keyboard] Configuração já está correta (US International + US), nada a fazer"
  exit 0
fi

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
  echo "[ezdora][keyboard] Detectado EN US mas sem International, configurando..."
  
  # Configura us(intl) como primeiro e us como segundo, sem duplicar
  kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "us,us"
  kwriteconfig6 --file kxkbrc --group Layout --key VariantList "intl,"
  kwriteconfig6 --file kxkbrc --group Layout --key DisplayNames "US,US"
  
  # Habilita e configura troca
  kwriteconfig6 --file kxkbrc --group Layout --key Use true
  kwriteconfig6 --file kxkbrc --group Layout --key SwitchMode Global
  kwriteconfig6 --file kxkbrc --group Layout --key Options "grp:alt_shift_toggle"
  
  echo "[ezdora][keyboard] EN US International configurado como layout padrão"
  echo "  - Layout padrão: EN US International" 
  echo "  - Layout secundário: EN US"
  echo "  - Atalho para trocar: Alt+Shift"
  
else
  echo "[ezdora][keyboard] Já possui layouts configurados incluindo variantes, mantendo configuração atual"
fi

# Desabilita o atalho Ctrl+F12 (Show Desktop) que conflita com IDEs como Rider
echo "[ezdora][keyboard] Desabilitando atalho Ctrl+F12 (Show Desktop) para evitar conflitos com IDEs..."
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Show Desktop" "none,Meta+D\tCtrl+F12,Peek at Desktop"
echo "[ezdora][keyboard] Atalho Ctrl+F12 desabilitado (mantido apenas Meta+D para Show Desktop)"

# Recarrega os atalhos globais
if command -v qdbus6 >/dev/null 2>&1; then
  qdbus6 org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel.reloadConfig 2>/dev/null || true
elif command -v qdbus >/dev/null 2>&1; then
  qdbus org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel.reloadConfig 2>/dev/null || true
fi

echo "[ezdora][keyboard] Configuração de teclado concluída"