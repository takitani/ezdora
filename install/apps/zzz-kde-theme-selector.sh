#!/usr/bin/env bash
set -euo pipefail

# KDE Theme Selector - Choose between Breeze Dark and Fedora theme
# Uses gum if available for interactive selection
# This script runs last (zzz prefix) to offer theme selection at the end

# Skip if not running from main installer
if [ "${EZDORA_SKIP_THEME:-0}" = "1" ]; then
  exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[ezdora][kde-theme] Configuração de tema do KDE Plasma"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if we're in KDE
if [ "${XDG_SESSION_DESKTOP:-}" != "plasma" ] && [ "${XDG_CURRENT_DESKTOP:-}" != "KDE" ]; then
  echo "[ezdora][kde-theme] Não está no KDE Plasma, pulando configuração de tema."
  exit 0
fi

# Function to apply Breeze Dark theme
apply_breeze_dark() {
  echo "[ezdora][kde-theme] Aplicando tema Breeze Dark..."
  
  # Global theme
  plasma-apply-lookandfeel --apply org.kde.breezedark.desktop 2>/dev/null || {
    # Fallback method using kwriteconfig5
    kwriteconfig5 --file kdeglobals --group KDE --key LookAndFeelPackage "org.kde.breezedark.desktop"
  }
  
  # Window decorations
  kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key theme "Breeze"
  
  # Color scheme
  plasma-apply-colorscheme BreezeDark 2>/dev/null || {
    kwriteconfig5 --file kdeglobals --group General --key ColorScheme "BreezeDark"
  }
  
  # Widget style
  kwriteconfig5 --file kdeglobals --group KDE --key widgetStyle "Breeze"
  
  # Icons (keep Breeze)
  kwriteconfig5 --file kdeglobals --group Icons --key Theme "breeze-dark"
  
  # Plasma style
  kwriteconfig5 --file plasmarc --group Theme --key name "breeze-dark"
  
  # Cursors
  plasma-apply-cursortheme breeze_cursors 2>/dev/null || {
    kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme "breeze_cursors"
  }
  
  # Apply GTK theme for consistency
  kwriteconfig5 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-theme-name "Breeze-Dark"
  kwriteconfig5 --file ~/.config/gtk-4.0/settings.ini --group Settings --key gtk-theme-name "Breeze-Dark"
  
  echo "[ezdora][kde-theme] Tema Breeze Dark aplicado!"
}

# Function to keep Fedora theme
keep_fedora() {
  echo "[ezdora][kde-theme] Mantendo tema Fedora."
  
  # Just ensure the Fedora theme is properly set
  plasma-apply-lookandfeel --apply org.fedoraproject.fedora.desktop 2>/dev/null || true
  
  echo "[ezdora][kde-theme] Tema Fedora mantido!"
}

# Prompt user for choice
if command -v gum >/dev/null 2>&1; then
  echo ""
  THEME_CHOICE=$(gum choose \
    --header "Qual tema você prefere para o KDE Plasma?" \
    --selected "Breeze Dark (tema escuro)" \
    "Breeze Dark (tema escuro)" \
    "Fedora (tema atual)" \
    "Pular configuração")
  
  case "$THEME_CHOICE" in
    "Breeze Dark"*)
      apply_breeze_dark
      ;;
    "Fedora"*)
      keep_fedora
      ;;
    *)
      echo "[ezdora][kde-theme] Configuração de tema pulada."
      exit 0
      ;;
  esac
else
  # Fallback to simple prompt
  echo ""
  echo "Qual tema você prefere?"
  echo "1) Breeze Dark (tema escuro)"
  echo "2) Fedora (manter atual)"
  echo "3) Pular"
  echo ""
  read -r -p "Escolha [1-3]: " choice
  
  case "$choice" in
    1)
      apply_breeze_dark
      ;;
    2)
      keep_fedora
      ;;
    *)
      echo "[ezdora][kde-theme] Configuração de tema pulada."
      exit 0
      ;;
  esac
fi

# Restart plasmashell to apply changes immediately (optional)
if command -v gum >/dev/null 2>&1; then
  if gum confirm "Deseja reiniciar o Plasma Shell para aplicar as mudanças agora?"; then
    echo "[ezdora][kde-theme] Reiniciando Plasma Shell..."
    kquitapp5 plasmashell 2>/dev/null || killall plasmashell 2>/dev/null || true
    sleep 2
    nohup plasmashell --replace &>/dev/null &
    sleep 3
    echo "[ezdora][kde-theme] Plasma Shell reiniciado! Tema aplicado."
  else
    echo "[ezdora][kde-theme] As mudanças serão aplicadas completamente no próximo login."
  fi
else
  read -r -p "Reiniciar Plasma Shell para aplicar agora? [y/N] " restart
  if [[ ${restart:-} =~ ^[Yy]$ ]]; then
    echo "[ezdora][kde-theme] Reiniciando Plasma Shell..."
    kquitapp5 plasmashell 2>/dev/null || killall plasmashell 2>/dev/null || true
    sleep 2
    nohup plasmashell --replace &>/dev/null &
    sleep 3
    echo "[ezdora][kde-theme] Plasma Shell reiniciado! Tema aplicado."
  else
    echo "[ezdora][kde-theme] As mudanças serão aplicadas completamente no próximo login."
  fi
fi

echo "[ezdora][kde-theme] Configuração de tema concluída!"