#!/usr/bin/env bash
set -euo pipefail

# Setup OBS Virtual Camera on Fedora via v4l2loopback + OBS v4l2sink plugin

echo "[ezdora][obs-vcam] Configurando Virtual Camera do OBS (v4l2loopback)..."

# 1) Ensure RPM Fusion so packages are available
FEDORA_VER=$(rpm -E %fedora)
sudo dnf install -y \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm" || true

# 2) Install v4l2loopback kernel module (akmod/kmod variants) and OBS sink plugin
sudo dnf install -y v4l2loopback akmod-v4l2loopback kmod-v4l2loopback || true
sudo dnf install -y obs-v4l2sink || true

# 3) Autoload module on boot
sudo mkdir -p /etc/modules-load.d /etc/modprobe.d
echo 'v4l2loopback' | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null

# 4) Module options: single device, fixed number, friendly name, exclusive caps
sudo tee /etc/modprobe.d/v4l2loopback.conf >/dev/null <<'EOF'
options v4l2loopback devices=1 video_nr=10 card_label="OBS Virtual Camera (EzDora)" exclusive_caps=1
EOF

# 5) Build/prepare module if using akmods; then load
sudo akmods --force --kernels "$(uname -r)" || true
sudo depmod -a || true

if ! lsmod | grep -q '^v4l2loopback'; then
  sudo modprobe v4l2loopback || true
fi

# 6) Friendly symlink via udev (optional convenience)
sudo tee /etc/udev/rules.d/99-obs-virtual-camera.rules >/dev/null <<'EOF'
# Create a stable, friendly symlink for the OBS virtual camera
SUBSYSTEM=="video4linux", ATTR{name}=="OBS Virtual Camera (EzDora)", SYMLINK+="video-obs"
EOF
sudo udevadm control --reload-rules || true
sudo udevadm trigger --subsystem-match=video4linux || true

if [ -e /dev/video10 ] || [ -e /dev/video-obs ]; then
  echo "[ezdora][obs-vcam] Virtual camera ativa: $( [ -e /dev/video-obs ] && echo /dev/video-obs || echo /dev/video10 )"
  echo "[ezdora][obs-vcam] Nome amigável em apps: 'OBS Virtual Camera (EzDora)'"
else
  echo "[ezdora][obs-vcam] Módulo configurado. Reinicie para garantir a criação do device e do symlink /dev/video-obs."
fi
