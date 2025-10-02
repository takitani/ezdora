#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][kde-fix] Corrigindo atalho Ctrl+Alt+T quebrado do Ghostty..."

# Only apply on KDE/Plasma sessions
if [[ "${XDG_CURRENT_DESKTOP:-}" != *KDE* && "${XDG_CURRENT_DESKTOP:-}" != *PLASMA* && "${XDG_SESSION_DESKTOP:-}" != *plasma* ]]; then
  echo "[ezdora][kde-fix] Não é uma sessão KDE/Plasma. Pulando correção."
  exit 0
fi

SHORTCUTS_FILE="$HOME/.config/kglobalshortcutsrc"

if [ ! -f "$SHORTCUTS_FILE" ]; then
  echo "[ezdora][kde-fix] Arquivo de atalhos não encontrado: $SHORTCUTS_FILE"
  exit 1
fi

echo "[ezdora][kde-fix] Backup do arquivo original..."
cp "$SHORTCUTS_FILE" "$SHORTCUTS_FILE.fix-backup-$(date +%s)"

echo "[ezdora][kde-fix] Limpando entradas quebradas do Ghostty..."

# Remove all broken Ghostty entries
sed -i '/\[services\]\[ghostty\.desktop\]/,/^$/d' "$SHORTCUTS_FILE" 2>/dev/null || true
sed -i '/\[ghostty\.desktop\]/,/^$/d' "$SHORTCUTS_FILE" 2>/dev/null || true

# Ensure Konsole is disabled  
if grep -q "org.kde.konsole" "$SHORTCUTS_FILE" 2>/dev/null; then
  sed -i '/\[services\]\[org\.kde\.konsole\.desktop\]/,/^$/s/_launch=.*/_launch=none/' "$SHORTCUTS_FILE" 2>/dev/null || true
  sed -i '/\[org\.kde\.konsole\.desktop\]/,/^$/s/_launch=.*/_launch=none,none,Konsole/' "$SHORTCUTS_FILE" 2>/dev/null || true
fi

# Add clean Ghostty shortcut
echo "" >> "$SHORTCUTS_FILE"
cat >> "$SHORTCUTS_FILE" << 'EOF'
[ghostty.desktop]
_k_friendly_name=Ghostty
_launch=Ctrl+Alt+T,none,Launch Ghostty Terminal
EOF

echo "[ezdora][kde-fix] Reiniciando kglobalaccel..."
killall kglobalaccel5 2>/dev/null || killall kglobalaccel 2>/dev/null || true
sleep 2

if command -v kglobalaccel5 >/dev/null 2>&1; then
  kglobalaccel5 &
  disown
elif command -v kglobalaccel >/dev/null 2>&1; then
  kglobalaccel &
  disown
fi

echo "[ezdora][kde-fix] ✅ Atalho Ctrl+Alt+T corrigido!"
echo "[ezdora][kde-fix] Teste pressionando Ctrl+Alt+T"