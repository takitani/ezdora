#!/usr/bin/env bash
set -euo pipefail

echo "[ezdora][dnf-codecs] Configurando codecs multimídia (RPM Fusion)…"

# Garante RPM Fusion habilitado (idempotente)
FEDORA_VER=$(rpm -E %fedora)
sudo dnf install -y \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm" || true

# Troca ffmpeg-free -> ffmpeg completo (nonfree)
if rpm -q ffmpeg-free >/dev/null 2>&1; then
  echo "[ezdora][dnf-codecs] Trocando ffmpeg-free por ffmpeg (nonfree)…"
  sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing || true
fi

# Grupo multimedia recomendado pela RPM Fusion (sem weak deps)
if ! rpm -qa | grep -q "gstreamer1-plugins"; then
  echo "[ezdora][dnf-codecs] Atualizando grupo @multimedia…"
  sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin || true
fi

# Extras comuns de codecs (idempotente)
if ! rpm -q x264 >/dev/null 2>&1; then
  echo "[ezdora][dnf-codecs] Instalando pacotes de codecs adicionais…"
  sudo dnf install -y amrnb amrwb faad2 flac gpac-libs lame libde265 libfc14audiodecoder mencoder x264 x265 || true
fi

echo "[ezdora][dnf-codecs] Concluído."

