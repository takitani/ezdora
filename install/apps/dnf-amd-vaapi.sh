#!/usr/bin/env bash
set -euo pipefail

# Habilita aceleração de vídeo por hardware (VA-API/VDPAU) para GPUs AMD
# Detecta AMD automaticamente; exporte FORCE_AMD_ACCEL=1 para forçar.

have() { command -v "$1" >/dev/null 2>&1; }

is_amd_gpu() {
  if [ "${FORCE_AMD_ACCEL:-0}" = "1" ]; then
    return 0
  fi
  if have lspci; then
    if lspci -nn | grep -Ei 'VGA|Display|3D' | grep -Ei 'AMD|Advanced Micro Devices' >/dev/null; then
      return 0
    fi
  fi
  return 1
}

echo "[ezdora][dnf-amd-vaapi] Aceleração AMD (VA-API/VDPAU)…"

if ! is_amd_gpu; then
  echo "[ezdora][dnf-amd-vaapi] Nenhuma GPU AMD detectada. Pulando (defina FORCE_AMD_ACCEL=1 para forçar)."
  exit 0
fi

# Garante RPM Fusion habilitado (idempotente)
FEDORA_VER=$(rpm -E %fedora)
sudo dnf install -y \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm" || true

# Troca drivers VA-API/VDPAU por variantes freeworld (ativam codecs proprietários)
if rpm -q mesa-va-drivers >/dev/null 2>&1; then
  sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld || true
else
  sudo dnf install -y mesa-va-drivers-freeworld || true
fi

if rpm -q mesa-vdpau-drivers >/dev/null 2>&1; then
  sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld || true
else
  sudo dnf install -y mesa-vdpau-drivers-freeworld || true
fi

# Multilib (somente se já houver base i686 instalada)
if rpm -qa | grep -qE '\.i686$'; then
  if rpm -q mesa-va-drivers.i686 >/dev/null 2>&1; then
    sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686 || true
  fi
  if rpm -q mesa-vdpau-drivers.i686 >/dev/null 2>&1; then
    sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686 || true
  fi
fi

# Ferramentas de verificação
sudo dnf install -y libva-utils vdpauinfo || true

echo "[ezdora][dnf-amd-vaapi] Concluído. Teste com: 'vainfo' e 'vdpauinfo'."

