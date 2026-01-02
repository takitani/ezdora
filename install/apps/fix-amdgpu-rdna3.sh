#!/usr/bin/env bash
set -euo pipefail

# AMD RDNA3 GPU Stability Fix
# Applies kernel parameters to prevent crashes on RX 7000 series
# Affects: Navi 31/32/33 (RX 7600/7700/7800/7900) on kernels 6.14+
# Bug: DCN32 display controller timeout causing kernel panic
# References:
#   https://gist.github.com/danielrosehill/6a531b079906f160911a87dea50e1507
#   https://bbs.archlinux.org/viewtopic.php?id=306587

SCRIPT_NAME="fix-amdgpu-rdna3"
GRUB_FILE="/etc/default/grub"
PARAMS="amdgpu.sg_display=0 amdgpu.dcdebugmask=0x10 amdgpu.gpu_recovery=1"

log() { echo "[ezdora][$SCRIPT_NAME] $*"; }
warn() { echo "[ezdora][$SCRIPT_NAME] WARNING: $*"; }
error() { echo "[ezdora][$SCRIPT_NAME] ERROR: $*" >&2; }

# Detect AMD RDNA3 GPU (Navi 31/32/33)
detect_rdna3_gpu() {
  if ! command -v lspci >/dev/null 2>&1; then
    return 1
  fi

  # Check for Navi 31/32/33 device IDs (RDNA3)
  # Navi 31: 744c, 7480 (RX 7900 series)
  # Navi 32: 7470, 7471 (RX 7800/7700 series)
  # Navi 33: 7480, 7483 (RX 7600 series)
  if lspci -nn | grep -qiE "VGA.*\[1002:(744c|7470|7471|7480|7483)\]"; then
    return 0
  fi

  # Fallback: check for "Navi 3" in description
  if lspci | grep -qiE "VGA.*Navi 3[0-9]"; then
    return 0
  fi

  return 1
}

# Get kernel major.minor version as comparable number (6.14 -> 614)
get_kernel_version() {
  local version
  version=$(uname -r | cut -d. -f1,2 | tr -d '.')
  echo "$version"
}

# Check if kernel is affected (6.14+)
is_kernel_affected() {
  local kver
  kver=$(get_kernel_version)
  [[ "$kver" -ge 614 ]]
}

# Check if fix already applied
is_already_applied() {
  grep -q "amdgpu.sg_display" "$GRUB_FILE" 2>/dev/null
}

# Main
main() {
  log "Checking system for AMD RDNA3 GPU stability fix..."

  # Check for RDNA3 GPU
  if ! detect_rdna3_gpu; then
    log "No AMD RDNA3 GPU detected (RX 7000 series). Skipping."
    exit 0
  fi

  GPU_INFO=$(lspci | grep -i "VGA.*AMD" | head -1)
  log "Detected: $GPU_INFO"

  # Check kernel version
  KERNEL_VER=$(uname -r)
  if ! is_kernel_affected; then
    log "Kernel $KERNEL_VER is not affected (fix needed for 6.14+). Skipping."
    exit 0
  fi
  log "Kernel $KERNEL_VER is in affected range (6.14+)"

  # Check if already applied
  if is_already_applied; then
    log "Fix already applied to GRUB. Skipping."
    grep "GRUB_CMDLINE_LINUX" "$GRUB_FILE" | head -1
    exit 0
  fi

  # Check for GRUB file
  if [[ ! -f "$GRUB_FILE" ]]; then
    error "GRUB config not found at $GRUB_FILE"
    exit 1
  fi

  log "Applying RDNA3 stability fix..."

  # Backup
  BACKUP="${GRUB_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  log "Creating backup: $BACKUP"
  sudo cp "$GRUB_FILE" "$BACKUP"

  # Apply fix - append params to existing GRUB_CMDLINE_LINUX
  log "Adding kernel parameters: $PARAMS"

  # Get current value and append
  CURRENT=$(grep "^GRUB_CMDLINE_LINUX=" "$GRUB_FILE" | head -1 | sed 's/GRUB_CMDLINE_LINUX="//' | sed 's/"$//')
  NEW_VALUE="$CURRENT $PARAMS"

  sudo sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"$NEW_VALUE\"|" "$GRUB_FILE"

  log "New config:"
  grep "GRUB_CMDLINE_LINUX" "$GRUB_FILE" | head -1

  # Regenerate GRUB
  log "Regenerating GRUB config..."
  if [[ -f /boot/grub2/grub.cfg ]]; then
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  elif [[ -f /boot/grub/grub.cfg ]]; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  else
    warn "Could not find grub.cfg - run grub2-mkconfig manually"
  fi

  log "Done!"
  log ""
  log "Parameters applied:"
  log "  amdgpu.sg_display=0     - Disables scatter-gather (prevents DMA timeouts)"
  log "  amdgpu.dcdebugmask=0x10 - Disables DC debug (prevents hangs)"
  log "  amdgpu.gpu_recovery=1   - Enables auto-recovery instead of panic"
  log ""
  log "Reboot required to apply changes: sudo reboot"
  log ""
  log "If still crashing, manually add to GRUB:"
  log "  amdgpu.gfx_off=0 amdgpu.runpm=0"
  log ""
  log "To restore: sudo cp $BACKUP $GRUB_FILE && sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
}

main "$@"
