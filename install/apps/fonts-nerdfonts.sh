#!/usr/bin/env bash
set -euo pipefail

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
  curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip
  unzip -q CascadiaMono.zip -d CascadiaFont || true
  cp -f CascadiaFont/*.ttf "$FONT_DIR" 2>/dev/null || true
  CHANGED=1
else
  echo "[ezdora][fonts] CaskaydiaMono Nerd Font já presente. Pulando."
fi

# JetBrains Mono Nerd Font
if ! has_font "JetBrainsMono Nerd Font"; then
  echo "[ezdora][fonts] Baixando JetBrainsMono Nerd Font..."
  curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -q JetBrainsMono.zip -d JetBrainsFont || true
  cp -f JetBrainsFont/*.ttf "$FONT_DIR" 2>/dev/null || true
  CHANGED=1
else
  echo "[ezdora][fonts] JetBrainsMono Nerd Font já presente. Pulando."
fi

# iA Writer Mono S
if ! has_font "iA Writer Mono S"; then
  echo "[ezdora][fonts] Baixando iA Writer Mono S..."
  curl -fsSLo iafonts.zip https://github.com/iaolo/iA-Fonts/archive/refs/heads/master.zip
  unzip -q iafonts.zip -d iaFonts || true
  cp -f iaFonts/iA-Fonts-master/iA\ Writer\ Mono/Static/iAWriterMonoS-*.ttf "$FONT_DIR" 2>/dev/null || true
  CHANGED=1
else
  echo "[ezdora][fonts] iA Writer Mono S já presente. Pulando."
fi

if [ "$CHANGED" = 1 ]; then
  fc-cache -f || true
  echo "[ezdora][fonts] Fontes atualizadas em $FONT_DIR"
else
  echo "[ezdora][fonts] Fontes já instaladas."
fi
