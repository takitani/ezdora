# KDE Terminal Troubleshooting Scripts

Este diretório contém scripts para diagnóstico e correção manual de problemas específicos com terminais no KDE, especialmente relacionados às teclas Home/End no Ghostty.

## Scripts Disponíveis

### Diagnóstico
- **`ghostty-diagnose.sh`** - Diagnóstico completo do Ghostty e configurações
- **`ghostty-deep-test.sh`** - Testes profundos de captura de teclas
- **`ghostty-test-keys.sh`** - Teste simples de teclas Home/End
- **`kde-test-terminal-input.sh`** - Teste de captura de teclas no terminal
- **`kde-test-keyboard.sh`** - Teste de layout de teclado

### Correções Manuais
- **`ghostty-clean-config.sh`** - Remove configurações problemáticas do Ghostty
- **`ghostty-fix-keys.sh`** - Aplica correções manuais para teclas Home/End

## Como Usar

1. **Para diagnóstico**: Execute os scripts de teste para identificar o problema
2. **Para correção**: Use os scripts de fix apenas se os automáticos falharam

## Nota Importante

⚠️ **Estes scripts NÃO fazem parte da instalação automatizada**

A instalação principal usa `kde-fix-terminal-keys.sh` que está em `install/apps/` e funciona automaticamente. Use estes scripts apenas para troubleshooting manual quando necessário.