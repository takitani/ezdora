#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][docker] Instalando Docker Engine (Fedora)..."

# Remove versões antigas (não falhar se não existirem)
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine || true

# Pré-requisito
sudo dnf install -y dnf-plugins-core || true

# Adicionar repositório oficial
if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
  if command -v dnf5 >/dev/null 2>&1; then
    sudo dnf5 config-manager addrepo https://download.docker.com/linux/fedora/docker-ce.repo || true
  else
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo || true
  fi
fi

# Fallback: criar arquivo de repositório se ainda não existir
if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
  echo "[ezdora][docker] Escrevendo /etc/yum.repos.d/docker-ce.repo (fallback)"
  sudo tee /etc/yum.repos.d/docker-ce.repo >/dev/null <<'EOF'
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/fedora/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF
fi

# Instalação do Docker Engine e plugins
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Habilita e inicia serviço
sudo systemctl enable --now docker

# Permite uso sem sudo
if getent group docker >/dev/null 2>&1; then
  sudo usermod -aG docker "$USER" || true
fi

echo "[ezdora][docker] Docker instalado com sucesso!"

# Verificar se precisa aplicar permissões
if ! docker ps >/dev/null 2>&1; then
  echo ""
  echo "[ezdora][docker] ⚠️  Você foi adicionado ao grupo 'docker' mas as permissões ainda não estão ativas."
  
  # For automated setup - don't prompt or exec, just inform
  if [[ "${EZDORA_AUTOMATED:-}" == "true" ]]; then
    echo "[ezdora][docker] 🤖 Modo automatizado: permissões serão aplicadas no final da instalação"
    echo "[ezdora][docker] 💡 Docker estará disponível após logout/login ou reinício"
  elif command -v gum >/dev/null 2>&1; then
    echo ""
    ACTION=$(gum choose \
      --header "Como deseja proceder?" \
      "Aplicar temporariamente (só neste terminal)" \
      "Instruções para aplicar permanentemente" \
      "Pular por enquanto")
    
    case "$ACTION" in
      "Aplicar temporariamente"*)
        echo "[ezdora][docker] Aplicando permissões temporariamente..."
        echo "[ezdora][docker] ⚠️  AVISO: Isso abrirá nova sessão bash. Use 'exit' para voltar."
        # Remove exec - use subshell instead to not terminate installer
        sg docker -c "PATH=\"$PATH\" bash --rcfile <(echo 'PS1=\"[docker-temp] \$PS1\"'; cat ~/.bashrc 2>/dev/null || cat ~/.zshrc 2>/dev/null || true)"
        echo "[ezdora][docker] Voltou da sessão temporária."
        ;;
      "Instruções"*)
        gum style \
          --border double \
          --border-foreground 39 \
          --padding "1 2" \
          --margin "1" \
          "Para aplicar permanentemente:" \
          "" \
          "1. Salve seu trabalho" \
          "2. Faça logout (ou reinicie)" \
          "3. Faça login novamente" \
          "4. Execute: docker ps (para testar)"
        ;;
      *)
        echo "[ezdora][docker] Ok! Lembre-se de fazer logout/login para usar Docker sem sudo."
        ;;
    esac
  else
    echo "[ezdora][docker] Para usar Docker sem sudo, você PRECISA:"
    echo "[ezdora][docker]   1. Fazer logout e login novamente (ou reiniciar)"
    echo "[ezdora][docker]   2. Depois execute: docker ps (para testar)"
    echo ""
    echo "[ezdora][docker] Alternativa temporária: sg docker -c bash"
  fi
else
  echo "[ezdora][docker] ✅ Docker já está funcionando corretamente!"
fi

