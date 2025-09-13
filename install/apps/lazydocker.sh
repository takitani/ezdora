#!/usr/bin/env bash

# Source helper functions
source "$(dirname "$0")/../utils/download-helper.sh" 2>/dev/null || {
  echo "[ezdora][lazydocker] ⚠️  Helper não encontrado, usando modo básico"
}

# Ensure ~/.local/bin is in PATH for current session
export PATH="$HOME/.local/bin:$PATH"

if command -v lazydocker >/dev/null 2>&1; then
  echo "[ezdora][lazydocker] Já instalado. Pulando."
  exit 0
fi

install_lazydocker() {
  echo "[ezdora][lazydocker] Instalando..."

  # Tenta via DNF primeiro
  if ! sudo dnf install -y lazydocker 2>/dev/null; then
    echo "[ezdora][lazydocker] Não encontrado no DNF. Usando instalação manual."

    # Ensure target directory exists
    mkdir -p "$HOME/.local/bin"

    # Try official script first
    echo "[ezdora][lazydocker] Tentando script de instalação oficial..."
    if command -v command_with_retry >/dev/null 2>&1; then
      command_with_retry \
        "curl -fsSL --connect-timeout 10 https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash" \
        "Baixando e executando script oficial"
    else
      curl -fsSL --connect-timeout 10 https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash 2>/dev/null || true
    fi

    # If script failed, try direct download
    if [ ! -f "$HOME/.local/bin/lazydocker" ]; then
      echo "[ezdora][lazydocker] Script oficial falhou. Tentando download direto..."

      # Detect architecture
      ARCH=$(uname -m)
      case "$ARCH" in
        x86_64) ARCH="x86_64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        armv7l) ARCH="armv6" ;;
        *)
          echo "[ezdora][lazydocker] ⚠️  Arquitetura não suportada: $ARCH"
          return 1
          ;;
      esac

      # Get latest version
      VERSION=$(curl -s --connect-timeout 10 https://api.github.com/repos/jesseduffield/lazydocker/releases/latest 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/' || echo "0.23.3")

      # Download binary directly
      URL="https://github.com/jesseduffield/lazydocker/releases/download/v${VERSION}/lazydocker_${VERSION}_Linux_${ARCH}.tar.gz"
      echo "[ezdora][lazydocker] Baixando versão ${VERSION} para ${ARCH}..."

      if command -v download_with_retry >/dev/null 2>&1; then
        if download_with_retry "$URL" "lazydocker v${VERSION}" "/tmp/lazydocker.tar.gz"; then
          tar -xzf /tmp/lazydocker.tar.gz -C /tmp/ lazydocker 2>/dev/null || true
          if [ -f /tmp/lazydocker ]; then
            mv /tmp/lazydocker "$HOME/.local/bin/"
            chmod +x "$HOME/.local/bin/lazydocker"
            rm -f /tmp/lazydocker.tar.gz
            echo "[ezdora][lazydocker] ✅ Instalado manualmente em ~/.local/bin/lazydocker"
          else
            echo "[ezdora][lazydocker] ⚠️  Falha ao extrair arquivo"
            return 1
          fi
        else
          echo "[ezdora][lazydocker] ⚠️  Download cancelado ou falhou"
          return 1
        fi
      else
        # Fallback sem helper
        if curl -fsSL --connect-timeout 10 -o /tmp/lazydocker.tar.gz "$URL" 2>/dev/null; then
          tar -xzf /tmp/lazydocker.tar.gz -C /tmp/ lazydocker 2>/dev/null || true
          if [ -f /tmp/lazydocker ]; then
            mv /tmp/lazydocker "$HOME/.local/bin/"
            chmod +x "$HOME/.local/bin/lazydocker"
            rm -f /tmp/lazydocker.tar.gz
            echo "[ezdora][lazydocker] ✅ Instalado em ~/.local/bin/lazydocker"
          fi
        else
          echo "[ezdora][lazydocker] ⚠️  Não foi possível baixar o lazydocker"
          return 1
        fi
      fi
    else
      echo "[ezdora][lazydocker] ✅ Instalado via script oficial"
    fi
  fi
}

# Execute instalação como app opcional
if command -v optional_install >/dev/null 2>&1; then
  optional_install "lazydocker" "install_lazydocker"
else
  install_lazydocker || {
    echo "[ezdora][lazydocker] ⚠️  Instalação falhou, mas continuando com outras instalações..."
    echo "[ezdora][lazydocker] 💡 Para tentar novamente: bash $(dirname "$0")/lazydocker.sh"
  }
fi

# Final verification
if command -v lazydocker >/dev/null 2>&1; then
  echo "[ezdora][lazydocker] ✅ Concluído. Executar com 'lazydocker'"
  echo "[ezdora][lazydocker] 💡 Para usar imediatamente: export PATH=\"\$HOME/.local/bin:\$PATH\""
else
  echo "[ezdora][lazydocker] ⚠️  Instalado mas não encontrado no PATH atual"
  echo "[ezdora][lazydocker] 🔄 Reinicie o terminal ou execute: source ~/.zshrc"
fi

