#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR"

# Create LazyDocker icons in hicolor theme structure
echo "[ezdora][lazydocker] Criando ícones oficiais em todos os tamanhos..."

# Create hicolor icon theme directories
HICOLOR_DIR="$HOME/.local/share/icons/hicolor"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[ezdora][lazydocker] Adicionando ícones ao tema hicolor existente..."

# Create directory structure and install icons
echo "[ezdora][lazydocker] SCRIPT_DIR: $SCRIPT_DIR"
echo "[ezdora][lazydocker] Verificando arquivos base64..."

for size in 16x16 32x32 48x48 64x64; do
  TARGET_DIR="$HICOLOR_DIR/${size}/apps"
  mkdir -p "$TARGET_DIR"
  
  ICON_FILE="$TARGET_DIR/lazydocker.png"
  BASE64_FILE="$SCRIPT_DIR/assets/icons/lazydocker/${size}.base64"
  
  echo "[ezdora][lazydocker] Processando ícone ${size}..."
  echo "[ezdora][lazydocker] Arquivo base64: $BASE64_FILE"
  
  if [ ! -f "$ICON_FILE" ]; then
    if [ -f "$BASE64_FILE" ]; then
      echo "[ezdora][lazydocker] Arquivo base64 encontrado, decodificando..."
      if base64 -d "$BASE64_FILE" > "$ICON_FILE" 2>/dev/null; then
        if [ -f "$ICON_FILE" ] && [ -s "$ICON_FILE" ]; then
          echo "[ezdora][lazydocker] Ícone ${size} criado com sucesso ($(stat -c%s "$ICON_FILE") bytes)"
        else
          echo "[ezdora][lazydocker] Erro: Arquivo de ícone criado mas está vazio"
          rm -f "$ICON_FILE"
        fi
      else
        echo "[ezdora][lazydocker] Erro ao decodificar ícone ${size}"
        rm -f "$ICON_FILE"
      fi
    else
      echo "[ezdora][lazydocker] ERRO: Arquivo base64 não encontrado: $BASE64_FILE"
      echo "[ezdora][lazydocker] Listando conteúdo do diretório:"
      ls -la "$SCRIPT_DIR/assets/icons/lazydocker/" 2>/dev/null || echo "Diretório não existe!"
    fi
  else
    echo "[ezdora][lazydocker] Ícone ${size} já existe"
  fi
done

# Update icon cache (GTK and KDE)
echo "[ezdora][lazydocker] Atualizando cache de ícones..."

# Update GTK icon cache for user's hicolor theme
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  if gtk-update-icon-cache -f "$HICOLOR_DIR" >/dev/null 2>&1; then
    echo "[ezdora][lazydocker] Cache GTK atualizado com sucesso"
  else
    echo "[ezdora][lazydocker] Aviso: Falha ao atualizar cache GTK"
  fi
else
  echo "[ezdora][lazydocker] Aviso: gtk-update-icon-cache não encontrado"
fi

# Update KDE icon cache (specific for KDE environments)
if command -v kbuildsycoca5 >/dev/null 2>&1; then
  echo "[ezdora][lazydocker] Atualizando cache KDE (kbuildsycoca5)..."
  kbuildsycoca5 --noincremental >/dev/null 2>&1 || true
elif command -v kbuildsycoca6 >/dev/null 2>&1; then
  echo "[ezdora][lazydocker] Atualizando cache KDE (kbuildsycoca6)..."
  kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi

# Find lazydocker installation path
LAZYDOCKER_PATH="$(which lazydocker 2>/dev/null || echo "")"
if [ -z "$LAZYDOCKER_PATH" ]; then
  echo "[ezdora][lazydocker] Erro: lazydocker não encontrado no PATH"
  exit 1
fi

# Choose terminal: prefer Ghostty, fallback to Konsole
EXEC_CMD="$LAZYDOCKER_PATH"
if command -v ghostty >/dev/null 2>&1; then
  EXEC_CMD="ghostty --class=LazyDocker --title=LazyDocker -e $LAZYDOCKER_PATH"
elif command -v konsole >/dev/null 2>&1; then
  EXEC_CMD="konsole -e $LAZYDOCKER_PATH"
fi

cat > "$APP_DIR/lazydocker.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=LazyDocker
Comment=Simple TUI for docker and docker-compose
Exec=$EXEC_CMD
TryExec=$LAZYDOCKER_PATH
Terminal=false
Categories=System;Utility;Development;
StartupNotify=false
Icon=lazydocker
EOF

update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true

echo "[ezdora][lazydocker] Desktop entry criado em $APP_DIR/lazydocker.desktop"
echo "[ezdora][lazydocker] Ícones instalados em $HICOLOR_DIR"
echo "[ezdora][lazydocker] Para verificar se os ícones estão funcionando:"
echo "[ezdora][lazydocker] 1. Abra o menu de aplicações do KDE"
echo "[ezdora][lazydocker] 2. Procure por 'LazyDocker'"
echo "[ezdora][lazydocker] 3. Se o ícone não aparecer, reinicie o KDE ou execute:"
echo "[ezdora][lazydocker]    kbuildsycoca6 --noincremental"