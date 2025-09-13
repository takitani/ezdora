#!/usr/bin/env bash

# Source helper functions
source "$(dirname "$0")/../utils/download-helper.sh" 2>/dev/null || {
  echo "[ezdora][fonts] ⚠️  Helper não encontrado, usando modo básico"
}

echo "[ezdora][fonts] Verificando Nerd Fonts (Cascadia, JetBrains, iA Writer)..."

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

has_font() {
  local name="$1"
  if fc-list : family 2>/dev/null | grep -Fqx "$name"; then return 0; fi
  ls "$FONT_DIR"/*"${name%% *}"* 1>/dev/null 2>&1 && return 0 || return 1
}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
cd "$tmpdir"

CHANGED=0

# Cascadia Mono Nerd Font (CaskaydiaMono Nerd Font)
if ! has_font "CaskaydiaMono Nerd Font"; then
  echo "[ezdora][fonts] Baixando CaskaydiaMono Nerd Font..."

  if command -v download_with_retry >/dev/null 2>&1; then
    if download_with_retry \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip" \
      "CaskaydiaMono Nerd Font" \
      "CascadiaMono.zip"; then
      unzip -q CascadiaMono.zip -d CascadiaFont 2>/dev/null || true
      cp -f CascadiaFont/*.ttf "$FONT_DIR" 2>/dev/null || true
      CHANGED=1
    else
      echo "[ezdora][fonts] ⚠️  Download de CaskaydiaMono cancelado"
    fi
  else
    curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip 2>/dev/null || true
    if [ -f CascadiaMono.zip ]; then
      unzip -q CascadiaMono.zip -d CascadiaFont || true
      cp -f CascadiaFont/*.ttf "$FONT_DIR" 2>/dev/null || true
      CHANGED=1
    fi
  fi
else
  echo "[ezdora][fonts] CaskaydiaMono Nerd Font já presente. Pulando."
fi

# JetBrains Mono Nerd Font
if ! has_font "JetBrainsMono Nerd Font"; then
  echo "[ezdora][fonts] Baixando JetBrainsMono Nerd Font..."

  if command -v download_with_retry >/dev/null 2>&1; then
    if download_with_retry \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
      "JetBrainsMono Nerd Font" \
      "JetBrainsMono.zip"; then
      unzip -q JetBrainsMono.zip -d JetBrainsFont 2>/dev/null || true
      cp -f JetBrainsFont/*.ttf "$FONT_DIR" 2>/dev/null || true
      CHANGED=1
    else
      echo "[ezdora][fonts] ⚠️  Download de JetBrainsMono cancelado"
    fi
  else
    curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip 2>/dev/null || true
    if [ -f JetBrainsMono.zip ]; then
      unzip -q JetBrainsMono.zip -d JetBrainsFont || true
      cp -f JetBrainsFont/*.ttf "$FONT_DIR" 2>/dev/null || true
      CHANGED=1
    fi
  fi
else
  echo "[ezdora][fonts] JetBrainsMono Nerd Font já presente. Pulando."
fi

# iA Writer Mono S
if ! has_font "iA Writer Mono S"; then
  echo "[ezdora][fonts] Baixando iA Writer Mono S..."

  if command -v download_with_retry >/dev/null 2>&1; then
    if download_with_retry \
      "https://github.com/iaolo/iA-Fonts/archive/refs/heads/master.zip" \
      "iA Writer Mono S Font" \
      "iafonts.zip"; then
      unzip -q iafonts.zip -d iaFonts 2>/dev/null || true
      cp -f iaFonts/iA-Fonts-master/iA\ Writer\ Mono/Static/iAWriterMonoS-*.ttf "$FONT_DIR" 2>/dev/null || true
      CHANGED=1
    else
      echo "[ezdora][fonts] ⚠️  Download de iA Writer cancelado"
    fi
  else
    curl -fsSLo iafonts.zip https://github.com/iaolo/iA-Fonts/archive/refs/heads/master.zip 2>/dev/null || true
    if [ -f iafonts.zip ]; then
      unzip -q iafonts.zip -d iaFonts || true
      cp -f iaFonts/iA-Fonts-master/iA\ Writer\ Mono/Static/iAWriterMonoS-*.ttf "$FONT_DIR" 2>/dev/null || true
      CHANGED=1
    fi
  fi
else
  echo "[ezdora][fonts] iA Writer Mono S já presente. Pulando."
fi

if [ "$CHANGED" = 1 ]; then
  fc-cache -f || true
  echo "[ezdora][fonts] Fontes atualizadas em $FONT_DIR"
else
  echo "[ezdora][fonts] Fontes já instaladas."
fi
