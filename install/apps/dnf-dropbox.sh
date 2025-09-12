#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][dropbox] Instalando Dropbox com múltiplos métodos de fallback..."

# Verificar se já está instalado
if command -v dropbox >/dev/null 2>&1 || rpm -q dropbox >/dev/null 2>&1 || rpm -q nautilus-dropbox >/dev/null 2>&1 || flatpak list --app | grep -q "com.dropbox.Client"; then
  echo "[ezdora][dropbox] Dropbox já está instalado."
  exit 0
fi

# Método 1: Repositório oficial (mais atualizado)
echo "[ezdora][dropbox] Método 1: Tentando repositório oficial..."
if [ ! -f /etc/yum.repos.d/dropbox.repo ]; then
  echo "[ezdora][dropbox] Adicionando repositório oficial..."
  if command -v dnf5 >/dev/null 2>&1; then
    sudo dnf5 config-manager addrepo --from-repofile=https://linux.dropbox.com/fedora/dropbox.repo 2>/dev/null || {
      echo "[ezdora][dropbox] Repositório oficial indisponível"
    }
  else
    sudo dnf config-manager --add-repo https://linux.dropbox.com/fedora/dropbox.repo 2>/dev/null || {
      echo "[ezdora][dropbox] Repositório oficial indisponível"
    }
  fi
fi

if sudo dnf install -y dropbox 2>/dev/null; then
  echo "[ezdora][dropbox] ✅ Instalado com sucesso via repositório oficial."
  INSTALL_SUCCESS=true
else
  INSTALL_SUCCESS=false
fi

# Método 2: Flatpak (fallback mais confiável)
if [ "$INSTALL_SUCCESS" != true ]; then
  echo "[ezdora][dropbox] Método 2: Tentando via Flatpak..."
  if command -v flatpak >/dev/null 2>&1; then
    if flatpak install -y flathub com.dropbox.Client 2>/dev/null; then
      echo "[ezdora][dropbox] ✅ Instalado com sucesso via Flatpak."
      echo "[ezdora][dropbox] Para executar: flatpak run com.dropbox.Client"
      INSTALL_SUCCESS=true
    else
      echo "[ezdora][dropbox] Falha na instalação via Flatpak"
    fi
  else
    echo "[ezdora][dropbox] Flatpak não disponível"
  fi
fi

# Método 3: RPM direto (último recurso)
if [ "$INSTALL_SUCCESS" != true ]; then
  echo "[ezdora][dropbox] Método 3: Tentando via download direto do RPM..."
  TEMP_RPM="/tmp/nautilus-dropbox.rpm"

  # Try to download the latest nautilus-dropbox RPM
  echo "[ezdora][dropbox] Baixando nautilus-dropbox RPM..."
  if wget -O "$TEMP_RPM" "https://www.dropbox.com/download?dl=packages/fedora/nautilus-dropbox-2025.05.20-1.fc42.x86_64.rpm" 2>/dev/null; then
    if sudo dnf install -y "$TEMP_RPM" 2>/dev/null; then
      rm -f "$TEMP_RPM"
      echo "[ezdora][dropbox] ✅ Instalado com sucesso via RPM direto."
      INSTALL_SUCCESS=true
    fi
  fi

  # Fallback to alternative RPM version
  if [ "$INSTALL_SUCCESS" != true ]; then
    echo "[ezdora][dropbox] Tentando versão alternativa do RPM..."
    if wget -O "$TEMP_RPM" "https://www.dropbox.com/download?dl=packages/fedora/nautilus-dropbox-2024.04.17-1.fedora.x86_64.rpm" 2>/dev/null; then
      if sudo dnf install -y "$TEMP_RPM" 2>/dev/null; then
        rm -f "$TEMP_RPM"
        echo "[ezdora][dropbox] ✅ Instalado com sucesso via RPM alternativo."
        INSTALL_SUCCESS=true
      fi
    fi
  fi

  rm -f "$TEMP_RPM" 2>/dev/null || true
fi

# Resultado final
if [ "$INSTALL_SUCCESS" = true ]; then
  echo ""
  echo "[ezdora][dropbox] 📋 Próximos passos:"
  echo "  • Inicie o Dropbox manualmente quando quiser usar"
  echo "  • Autostart foi DESABILITADO propositalmente"
  echo "  • Para habilitar autostart: descomente install/apps/dropbox-autostart.sh"
  echo ""
  echo "[ezdora][dropbox] Dropbox instalado com sucesso! 🎉"
else
  echo "[ezdora][dropbox] ❌ Falha em todos os métodos de instalação." >&2
  echo "[ezdora][dropbox] Tente instalar manualmente:" >&2
  echo "[ezdora][dropbox]   - Via Flatpak: flatpak install flathub com.dropbox.Client" >&2
  echo "[ezdora][dropbox]   - Ou baixe do site oficial: https://www.dropbox.com/install-linux" >&2
  exit 1
fi

