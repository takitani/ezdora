#!/usr/bin/env bash

echo "🧪 TESTE RÁPIDO: Captura de teclas no terminal"
echo "============================================="
echo ""
echo "Execute este comando e pressione Home, depois End:"
echo ""
echo "sed -n l"
echo ""
echo "Depois pressione Ctrl+C para sair"
echo ""
echo "Se não aparecer nada ao pressionar Home/End,"
echo "o KDE está interceptando essas teclas para terminais."
echo ""
echo "Sequências esperadas:"
echo "  Home: ^[[H ou ^[[1~ ou ^[OH"  
echo "  End:  ^[[F ou ^[[4~ ou ^[OF"
echo ""

read -r -p "Pressione Enter para executar o teste..."
echo ""
echo "Pressione Home, depois End, depois Ctrl+C:"
sed -n l