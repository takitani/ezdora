#!/usr/bin/env bash
set -euo pipefail

# Install Atuin - magical shell history with sync and encryption

echo "[ezdora][atuin] Instalando Atuin (histórico de comandos inteligente)..."

# Check if already installed
if command -v atuin >/dev/null 2>&1; then
    echo "[ezdora][atuin] Atuin já está instalado"
    echo "[ezdora][atuin] Versão: $(atuin --version)"
    exit 0
fi

# Ensure ~/.local/bin and ~/.cargo/bin are in PATH
mkdir -p "$HOME/.local/bin" "$HOME/.cargo/bin"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# Try DNF only if sudo NOPASSWD is available
if sudo -n true 2>/dev/null; then
    echo "[ezdora][atuin] Tentando instalar via DNF..."
    if sudo dnf install -y atuin 2>/dev/null; then
        echo "[ezdora][atuin] ✅ Atuin instalado via DNF"
    fi
fi

# If not installed yet, use official installer (no sudo needed)
if ! command -v atuin >/dev/null 2>&1; then
    echo "[ezdora][atuin] Instalando via instalador oficial..."
    if curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh; then
        echo "[ezdora][atuin] ✅ Atuin instalado via instalador oficial"
    else
        echo "[ezdora][atuin] ❌ ERRO: Falha ao instalar Atuin"
        exit 1
    fi
fi

# Verify installation
if command -v atuin >/dev/null 2>&1; then
    echo "[ezdora][atuin] ✨ Instalação verificada!"
    echo "[ezdora][atuin] Versão: $(atuin --version)"
else
    echo "[ezdora][atuin] ❌ ERRO: Atuin não encontrado no PATH após instalação"
    echo "[ezdora][atuin] Tente reiniciar o terminal ou executar: source ~/.bashrc"
    exit 1
fi

echo "[ezdora][atuin] 📚 Atuin instalado com sucesso!"
echo "[ezdora][atuin] "
echo "[ezdora][atuin] 🚀 Próximos passos:"
echo "[ezdora][atuin] 1. Configure a integração com seu shell:"
echo "[ezdora][atuin]    Para Zsh: execute install/apps/atuin-zsh.sh"
echo "[ezdora][atuin] 2. Opcionalmente, registre uma conta para sync:"
echo "[ezdora][atuin]    atuin register -u <username> -e <email>"
echo "[ezdora][atuin] 3. Importe histórico existente:"
echo "[ezdora][atuin]    atuin import auto"
echo "[ezdora][atuin] "
echo "[ezdora][atuin] 💡 Use Ctrl+R para o novo histórico inteligente!"