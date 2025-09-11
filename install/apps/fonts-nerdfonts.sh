#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][fonts] Instalando Nerd Fonts (Cascadia Mono + JetBrains Mono + iA Writer Mono S)..."

mkdir -p "$HOME/.local/share/fonts"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
cd "$tmpdir"

# Cascadia Mono Nerd Font (mesmo usado no Omakub)
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip
unzip -q CascadiaMono.zip -d CascadiaFont || true
cp -f CascadiaFont/*.ttf "$HOME/.local/share/fonts" 2>/dev/null || true

# JetBrains Mono Nerd Font
curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -q JetBrainsMono.zip -d JetBrainsFont || true
cp -f JetBrainsFont/*.ttf "$HOME/.local/share/fonts" 2>/dev/null || true

# iA Writer Mono S (ótimo para terminal)
curl -fsSLo iafonts.zip https://github.com/iaolo/iA-Fonts/archive/refs/heads/master.zip
unzip -q iafonts.zip -d iaFonts || true
cp -f iaFonts/iA-Fonts-master/iA\ Writer\ Mono/Static/iAWriterMonoS-*.ttf "$HOME/.local/share/fonts" 2>/dev/null || true

fc-cache -f || true
echo "[ezdora][fonts] Nerd Fonts instaladas em ~/.local/share/fonts"
