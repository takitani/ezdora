#!/usr/bin/env bash
set -euo pipefail

# Replace Fedora menu icon with custom logo
# This script replaces the default "F" icon in KDE's application menu

echo "[ezdora][fedora-menu] Substituindo ícone do menu iniciar do Fedora..."

# Find the ezdora repository root directory
SCRIPT_DIR=""
for possible_dir in \
  "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" \
  "$HOME/Devel/ezdora" \
  "$HOME/.local/share/ezdora" \
  "/opt/ezdora" \
  "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.."; do
  if [ -d "$possible_dir/assets/icons/fedora-menu" ]; then
    SCRIPT_DIR="$possible_dir"
    break
  fi
done

if [ -z "$SCRIPT_DIR" ]; then
  echo "[ezdora][fedora-menu] ERRO: Não foi possível encontrar o diretório do repositório ezdora"
  exit 1
fi

echo "[ezdora][fedora-menu] SCRIPT_DIR: $SCRIPT_DIR"

# Create hicolor icon theme directories
HICOLOR_DIR="$HOME/.local/share/icons/hicolor"

# Icon name for Fedora menu (this is the standard name used by KDE)
ICON_NAME="start-here"

echo "[ezdora][fedora-menu] Instalando ícones personalizados do menu iniciar..."

# Create directory structure and install icons
for size in 16x16 32x32 48x48 64x64 128x128 256x256; do
  TARGET_DIR="$HICOLOR_DIR/${size}/places"
  mkdir -p "$TARGET_DIR"
  
  ICON_FILE="$TARGET_DIR/${ICON_NAME}.png"
  BASE64_FILE="$SCRIPT_DIR/assets/icons/fedora-menu/${size}.base64"
  
  echo "[ezdora][fedora-menu] Processando ícone ${size}..."
  
  if [ ! -f "$ICON_FILE" ]; then
    if [ -f "$BASE64_FILE" ]; then
      echo "[ezdora][fedora-menu] Decodificando ícone ${size}..."
      if base64 -d "$BASE64_FILE" > "$ICON_FILE" 2>/dev/null; then
        if [ -f "$ICON_FILE" ] && [ -s "$ICON_FILE" ]; then
          echo "[ezdora][fedora-menu] Ícone ${size} criado com sucesso ($(stat -c%s "$ICON_FILE") bytes)"
        else
          echo "[ezdora][fedora-menu] Erro: Arquivo de ícone criado mas está vazio"
          rm -f "$ICON_FILE"
        fi
      else
        echo "[ezdora][fedora-menu] Erro ao decodificar ícone ${size}"
        rm -f "$ICON_FILE"
      fi
    else
      echo "[ezdora][fedora-menu] ERRO: Arquivo base64 não encontrado: $BASE64_FILE"
    fi
  else
    echo "[ezdora][fedora-menu] Ícone ${size} já existe"
  fi
done

# Update icon cache (GTK and KDE)
echo "[ezdora][fedora-menu] Atualizando cache de ícones..."

# Update GTK icon cache for user's hicolor theme
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  if gtk-update-icon-cache -f "$HICOLOR_DIR" >/dev/null 2>&1; then
    echo "[ezdora][fedora-menu] Cache GTK atualizado com sucesso"
  else
    echo "[ezdora][fedora-menu] Aviso: Falha ao atualizar cache GTK"
  fi
else
  echo "[ezdora][fedora-menu] Aviso: gtk-update-icon-cache não encontrado"
fi

# Update KDE icon cache (specific for KDE environments)
if command -v kbuildsycoca5 >/dev/null 2>&1; then
  echo "[ezdora][fedora-menu] Atualizando cache KDE (kbuildsycoca5)..."
  kbuildsycoca5 --noincremental >/dev/null 2>&1 || true
elif command -v kbuildsycoca6 >/dev/null 2>&1; then
  echo "[ezdora][fedora-menu] Atualizando cache KDE (kbuildsycoca6)..."
  kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi

echo "[ezdora][fedora-menu] Ícones do menu iniciar instalados em $HICOLOR_DIR"
echo "[ezdora][fedora-menu] Para verificar se os ícones estão funcionando:"
echo "[ezdora][fedora-menu] 1. Abra o menu de aplicações do KDE"
echo "[ezdora][fedora-menu] 2. Verifique se o ícone do menu iniciar mudou"
echo "[ezdora][fedora-menu] 3. Se não mudou, reinicie o KDE ou execute:"
echo "[ezdora][fedora-menu]    kbuildsycoca6 --noincremental"
echo "[ezdora][fedora-menu]    # Ou reinicie o plasmashell:"
echo "[ezdora][fedora-menu]    kquitapp6 plasmashell && kstart6 plasmashell"
