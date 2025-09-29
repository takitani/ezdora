#!/usr/bin/env bash
set -euo pipefail

# Instala wkhtmltopdf com Qt patcheado (versão 0.12.6.1)
# A versão dos repositórios do Fedora não tem Qt patcheado e não suporta vários switches importantes

if rpm -q wkhtmltox >/dev/null 2>&1; then
  echo "[wkhtmltopdf] Versão patcheada já instalada"
  exit 0
fi

echo "[wkhtmltopdf] Baixando versão patcheada com Qt (0.12.6.1)..."

# Remove versão antiga se existir
if rpm -q wkhtmltopdf >/dev/null 2>&1; then
  echo "[wkhtmltopdf] Removendo versão não-patcheada do repositório..."
  sudo dnf remove -y wkhtmltopdf
fi

# Download da versão patcheada (AlmaLinux 9 é compatível com Fedora)
WKHTML_URL="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox-0.12.6.1-3.almalinux9.x86_64.rpm"
WKHTML_RPM="/tmp/wkhtmltox-patched.rpm"

if [ ! -f "$WKHTML_RPM" ]; then
  wget -q -O "$WKHTML_RPM" "$WKHTML_URL" || {
    echo "[wkhtmltopdf] Erro ao baixar. Verifique sua conexão."
    exit 1
  }
fi

# Instala a versão patcheada
echo "[wkhtmltopdf] Instalando versão patcheada..."
sudo dnf install -y "$WKHTML_RPM" || {
  echo "[wkhtmltopdf] Erro na instalação. Verificando dependências..."
  sudo dnf install -y "$WKHTML_RPM" --setopt=strict=0
}

# Limpa arquivo temporário
rm -f "$WKHTML_RPM"

echo "[wkhtmltopdf] Versão patcheada instalada com sucesso!"