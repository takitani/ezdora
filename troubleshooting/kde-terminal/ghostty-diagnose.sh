#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][ghostty-diag] Diagnóstico do ambiente terminal"
echo "=================================================="
echo ""

echo "🖥️  AMBIENTE:"
echo "Desktop: ${XDG_CURRENT_DESKTOP:-unknown}"
echo "Session: ${XDG_SESSION_DESKTOP:-unknown}"
echo "TERM: ${TERM:-unknown}"
echo "TERMINFO: ${TERMINFO:-not set}"
echo "SHELL: ${SHELL:-unknown}"
echo ""

echo "⌨️  TECLADO:"
echo "Layout atual:"
if command -v setxkbmap >/dev/null 2>&1; then
  setxkbmap -print | grep -E "(layout|variant)" || echo "Não detectado"
else
  echo "setxkbmap não disponível"
fi
echo ""

if [ -f ~/.config/kxkbrc ]; then
  echo "Configuração KDE (kxkbrc):"
  grep -E "(LayoutList|VariantList)" ~/.config/kxkbrc 2>/dev/null || echo "Não encontrado"
else
  echo "Arquivo kxkbrc não existe"
fi
echo ""

echo "🔧 GHOSTTY:"
if command -v ghostty >/dev/null 2>&1; then
  echo "Versão: $(ghostty --version 2>/dev/null || echo 'não detectada')"
  if [ -f ~/.config/ghostty/config ]; then
    echo "Config existe: ~/.config/ghostty/config"
    echo "Keybinds configurados:"
    grep -E "keybind.*home|keybind.*end" ~/.config/ghostty/config 2>/dev/null || echo "Nenhum keybind Home/End"
  else
    echo "Config não existe"
  fi
else
  echo "Ghostty não instalado"
fi
echo ""

echo "🧪 TESTE SIMPLES:"
echo "Digite uma linha longa e teste Home/End:"
echo "(Se não funcionar, o problema NÃO é configuração do Ghostty)"
echo ""
echo "Teste: digite 'abcdefghijklmnopqrstuvwxyz' e pressione Home/End"