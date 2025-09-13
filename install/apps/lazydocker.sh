#!/usr/bin/env bash
set -euo pipefail

# Ensure ~/.local/bin is in PATH for current session
export PATH="$HOME/.local/bin:$PATH"

if command -v lazydocker >/dev/null 2>&1; then
  echo "[ezdora][lazydocker] Já instalado. Pulando."
  exit 0
fi

echo "[ezdora][lazydocker] Instalando..."

# Tenta via DNF primeiro
if ! sudo dnf install -y lazydocker 2>/dev/null; then
  echo "[ezdora][lazydocker] Não encontrado no DNF. Usando instalação manual."

  # Ensure target directory exists
  mkdir -p "$HOME/.local/bin"

  # Try official script first with retry
  echo "[ezdora][lazydocker] Tentando baixar do GitHub..."
  for attempt in 1 2 3; do
    if curl -fsSL --connect-timeout 10 --retry 3 \
      https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash 2>/dev/null; then
      break
    else
      echo "[ezdora][lazydocker] Tentativa $attempt falhou. Aguardando 5s..."
      sleep 5
    fi
  done

  # If script failed, try direct download
  if [ ! -f "$HOME/.local/bin/lazydocker" ]; then
    echo "[ezdora][lazydocker] Script oficial falhou. Tentando download direto..."

    # Detect architecture
    ARCH=$(uname -m)
    case "$ARCH" in
      x86_64) ARCH="x86_64" ;;
      aarch64|arm64) ARCH="arm64" ;;
      armv7l) ARCH="armv6" ;;
      *) echo "[ezdora][lazydocker] ❌ Arquitetura não suportada: $ARCH"; exit 1 ;;
    esac

    # Get latest version
    VERSION=$(curl -s --connect-timeout 10 https://api.github.com/repos/jesseduffield/lazydocker/releases/latest 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/' || echo "0.23.3")

    # Download binary directly
    URL="https://github.com/jesseduffield/lazydocker/releases/download/v${VERSION}/lazydocker_${VERSION}_Linux_${ARCH}.tar.gz"
    echo "[ezdora][lazydocker] Baixando versão ${VERSION} para ${ARCH}..."

    if curl -fsSL --connect-timeout 10 --retry 3 -o /tmp/lazydocker.tar.gz "$URL" 2>/dev/null; then
      tar -xzf /tmp/lazydocker.tar.gz -C /tmp/ lazydocker 2>/dev/null || true
      if [ -f /tmp/lazydocker ]; then
        mv /tmp/lazydocker "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/lazydocker"
        rm -f /tmp/lazydocker.tar.gz
        echo "[ezdora][lazydocker] ✅ Instalado manualmente em ~/.local/bin/lazydocker"
      else
        echo "[ezdora][lazydocker] ❌ ERRO: Falha ao extrair arquivo"
        exit 1
      fi
    else
      echo "[ezdora][lazydocker] ❌ ERRO: Não foi possível baixar o lazydocker"
      echo "[ezdora][lazydocker] 💡 Verifique sua conexão com a internet"
      exit 1
    fi
  else
    echo "[ezdora][lazydocker] ✅ Instalado em ~/.local/bin/lazydocker"
  fi
fi

# Final verification
if command -v lazydocker >/dev/null 2>&1; then
  echo "[ezdora][lazydocker] ✅ Concluído. Executar com 'lazydocker'"
  echo "[ezdora][lazydocker] 💡 Para usar imediatamente: export PATH=\"\$HOME/.local/bin:\$PATH\""
else
  echo "[ezdora][lazydocker] ⚠️  Instalado mas não encontrado no PATH atual"
  echo "[ezdora][lazydocker] 🔄 Reinicie o terminal ou execute: source ~/.zshrc"
fi

