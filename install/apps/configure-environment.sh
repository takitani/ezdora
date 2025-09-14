#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][environment] Configurando variáveis de ambiente permanentes..."

# Desabilita telemetria do .NET
if ! grep -q "DOTNET_CLI_TELEMETRY_OPTOUT" /etc/environment 2>/dev/null; then
    echo "[ezdora][environment] Desabilitando telemetria do .NET..."
    echo 'DOTNET_CLI_TELEMETRY_OPTOUT=1' | sudo tee -a /etc/environment >/dev/null
    echo "[ezdora][environment] Telemetria do .NET desabilitada permanentemente"
else
    echo "[ezdora][environment] Telemetria do .NET já está desabilitada"
fi

# Exporta para a sessão atual também
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Adiciona ao perfil do usuário para garantir que funcione em todas as shells
for profile_file in ~/.bashrc ~/.zshrc ~/.profile; do
    if [ -f "$profile_file" ]; then
        if ! grep -q "DOTNET_CLI_TELEMETRY_OPTOUT" "$profile_file" 2>/dev/null; then
            echo 'export DOTNET_CLI_TELEMETRY_OPTOUT=1' >> "$profile_file"
            echo "[ezdora][environment] Adicionado ao $profile_file"
        fi
    fi
done

echo "[ezdora][environment] Configuração de ambiente concluída"