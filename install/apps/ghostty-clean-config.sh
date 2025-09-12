#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][ghostty-clean] Limpando configurações problemáticas do Ghostty"

GHOSTTY_CONFIG_FILE="$HOME/.config/ghostty/config"

if [ ! -f "$GHOSTTY_CONFIG_FILE" ]; then
  echo "[ezdora][ghostty-clean] Arquivo de configuração não existe: $GHOSTTY_CONFIG_FILE"
  exit 0
fi

# Fazer backup
cp "$GHOSTTY_CONFIG_FILE" "$GHOSTTY_CONFIG_FILE.backup-$(date +%s)"
echo "[ezdora][ghostty-clean] Backup criado: $GHOSTTY_CONFIG_FILE.backup-$(date +%s)"

# Remover todas as configurações de keybind que foram adicionadas
echo "[ezdora][ghostty-clean] Removendo keybinds problemáticos..."

# Remove all keybind lines
sed -i '/^keybind = home=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = end=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = shift+home=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = shift+end=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = ctrl+home=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = ctrl+end=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = page_up=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = page_down=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = shift+page_up=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = shift+page_down=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = alt+home=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = alt+end=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = ctrl+a=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = ctrl+e=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = ctrl+shift+home=/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^keybind = ctrl+shift+end=/d' "$GHOSTTY_CONFIG_FILE"

# Remove comment blocks added by previous scripts
sed -i '/^# Correção para teclas Home\/End/,/^$/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^# Outras teclas úteis/,/^$/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^# Alternativas/,/^$/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^# Page navigation/,/^$/d' "$GHOSTTY_CONFIG_FILE"
sed -i '/^# Fallback/,/^$/d' "$GHOSTTY_CONFIG_FILE"

# Remove empty lines at the end
sed -i '$ { :a; /^\s*$/d; N; ba; }' "$GHOSTTY_CONFIG_FILE"

echo "[ezdora][ghostty-clean] Configuração limpa!"
echo ""
echo "Configuração atual:"
cat "$GHOSTTY_CONFIG_FILE"
echo ""

# Test if Ghostty is running
if pgrep -x ghostty >/dev/null 2>&1; then
  echo "[ezdora][ghostty-clean] ⚠️  Ghostty está rodando."
  echo "[ezdora][ghostty-clean] Feche e abra novamente para aplicar as mudanças."
  
  if command -v gum >/dev/null 2>&1; then
    if gum confirm "Fechar todas as instâncias do Ghostty agora?"; then
      pkill ghostty
      echo "[ezdora][ghostty-clean] Ghostty fechado. Abra novamente para testar."
    fi
  else
    read -r -p "Fechar todas as instâncias do Ghostty? [y/N] " close_ghostty
    if [[ ${close_ghostty:-} =~ ^[Yy]$ ]]; then
      pkill ghostty
      echo "[ezdora][ghostty-clean] Ghostty fechado. Abra novamente para testar."
    fi
  fi
fi

echo ""
echo "[ezdora][ghostty-clean] ✅ Limpeza concluída!"
echo "[ezdora][ghostty-clean] Agora teste Home/End - deveriam funcionar nativamente"