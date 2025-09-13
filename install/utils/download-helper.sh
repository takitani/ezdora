#!/usr/bin/env bash

# Função para download com retry interativo
# Uso: download_with_retry "URL" "descrição" "arquivo_destino"
download_with_retry() {
  local url="$1"
  local description="$2"
  local output_file="$3"
  local max_attempts=3
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    echo "[ezdora][download] Tentativa $attempt/$max_attempts: $description"

    if curl -fsSL --connect-timeout 10 --retry 2 -o "$output_file" "$url" 2>/dev/null; then
      echo "[ezdora][download] ✅ Download concluído com sucesso"
      return 0
    else
      echo "[ezdora][download] ❌ Falha no download (tentativa $attempt/$max_attempts)"

      if [ $attempt -lt $max_attempts ]; then
        echo -n "[ezdora][download] Deseja tentar novamente? (s/n): "
        read -r retry_choice
        if [[ ! "$retry_choice" =~ ^[Ss]$ ]]; then
          echo "[ezdora][download] ⚠️  Download cancelado pelo usuário"
          return 1
        fi
      else
        echo "[ezdora][download] ⚠️  Todas as tentativas falharam"
        echo -n "[ezdora][download] Deseja tentar mais uma vez? (s/n): "
        read -r retry_choice
        if [[ "$retry_choice" =~ ^[Ss]$ ]]; then
          max_attempts=$((max_attempts + 1))
        else
          return 1
        fi
      fi
    fi

    attempt=$((attempt + 1))
    [ $attempt -le $max_attempts ] && sleep 2
  done

  return 1
}

# Função para executar comando com retry interativo
# Uso: command_with_retry "comando" "descrição"
command_with_retry() {
  local command="$1"
  local description="$2"
  local max_attempts=3
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    echo "[ezdora][exec] Tentativa $attempt/$max_attempts: $description"

    if eval "$command"; then
      echo "[ezdora][exec] ✅ Comando executado com sucesso"
      return 0
    else
      echo "[ezdora][exec] ❌ Falha na execução (tentativa $attempt/$max_attempts)"

      if [ $attempt -lt $max_attempts ]; then
        echo -n "[ezdora][exec] Deseja tentar novamente? (s/n): "
        read -r retry_choice
        if [[ ! "$retry_choice" =~ ^[Ss]$ ]]; then
          echo "[ezdora][exec] ⚠️  Execução cancelada pelo usuário"
          return 1
        fi
      else
        echo "[ezdora][exec] ⚠️  Todas as tentativas falharam"
        echo -n "[ezdora][exec] Deseja tentar mais uma vez? (s/n): "
        read -r retry_choice
        if [[ "$retry_choice" =~ ^[Ss]$ ]]; then
          max_attempts=$((max_attempts + 1))
        else
          return 1
        fi
      fi
    fi

    attempt=$((attempt + 1))
    [ $attempt -le $max_attempts ] && sleep 2
  done

  return 1
}

# Função para instalação opcional com falha não-crítica
# Uso: optional_install "nome" "comando_instalacao"
optional_install() {
  local app_name="$1"
  local install_command="$2"

  echo "[ezdora][$app_name] Iniciando instalação..."

  if eval "$install_command"; then
    echo "[ezdora][$app_name] ✅ Instalado com sucesso!"
    return 0
  else
    echo "[ezdora][$app_name] ⚠️  Instalação falhou (não crítico)"
    echo -n "[ezdora][$app_name] Deseja tentar instalar manualmente mais tarde? (s/n): "
    read -r manual_choice
    if [[ "$manual_choice" =~ ^[Ss]$ ]]; then
      echo "[ezdora][$app_name] 💡 Para instalar manualmente mais tarde, execute:"
      echo "  $install_command"
    fi
    # Retorna 0 para não interromper o fluxo principal
    return 0
  fi
}

# Exporta as funções para uso em outros scripts
export -f download_with_retry
export -f command_with_retry
export -f optional_install