#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][kbd-test] Teste do layout de teclado KDE"
echo "================================================="
echo ""

echo "Layout atual:"
if command -v setxkbmap >/dev/null 2>&1; then
  setxkbmap -query 2>/dev/null || echo "Erro ao consultar layout"
else
  echo "setxkbmap não disponível"
fi
echo ""

echo "🧪 TESTE: Trocar temporariamente para US puro"
echo ""
if command -v gum >/dev/null 2>&1; then
  if gum confirm "Testar com layout US puro (sem International)?"; then
    echo "Mudando para US puro..."
    setxkbmap us 2>/dev/null || echo "Erro ao mudar layout"
    echo ""
    echo "✅ Layout alterado para US puro"
    echo "Agora teste Home/End no Ghostty"
    echo ""
    
    if gum confirm "Restaurar layout US International?"; then
      setxkbmap us intl 2>/dev/null || echo "Erro ao restaurar layout"
      echo "Layout restaurado para US International"
    fi
  fi
else
  read -r -p "Testar com layout US puro? [y/N] " test_layout
  if [[ ${test_layout:-} =~ ^[Yy]$ ]]; then
    echo "Mudando para US puro..."
    setxkbmap us 2>/dev/null || echo "Erro ao mudar layout"
    echo ""
    echo "✅ Layout alterado para US puro"
    echo "Agora teste Home/End no Ghostty"
    echo ""
    
    read -r -p "Restaurar layout US International? [Y/n] " restore_layout
    if [[ ${restore_layout:-Y} =~ ^[Yy]$ ]]; then
      setxkbmap us intl 2>/dev/null || echo "Erro ao restaurar layout"
      echo "Layout restaurado para US International"
    fi
  fi
fi