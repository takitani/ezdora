#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][ghostty-test] Teste de teclas Home/End no Ghostty"
echo ""
echo "Este script mostra o que suas teclas estão enviando."
echo "Pressione as teclas e veja se as sequências estão corretas:"
echo ""
echo "Teclas esperadas:"
echo "  Home: \\x1bOH ou \\x1b[H"
echo "  End:  \\x1bOF ou \\x1b[F"
echo ""
echo "Digite algo e teste Home/End para ir ao início/fim da linha:"

read -r -p "Digite texto aqui: " test_input
echo "Você digitou: $test_input"
echo ""
echo "Agora teste as teclas Home/End com este comando:"
echo "  cat > /dev/null"
echo "Pressione Home/End e veja se move o cursor, depois Ctrl+C para sair"