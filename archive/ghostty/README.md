# Ghostty Scripts (Archived)

These scripts were archived on 2025-12-30 after migrating from Ghostty to Kitty terminal.

## Reason for Archive

- Ghostty had issues with KDE Plasma integration (keyboard shortcuts, clipboard)
- Kitty provides better Wayland support and more stable experience
- Migration commit: `b4cb046`

## Contents

### Installation Scripts (from install/apps/)
- `dnf-ghostty.sh` - DNF installation
- `ghostty-osc52-fix.sh` - OSC 52 clipboard fix
- `ghostty-set-zsh.sh` - Set zsh as default shell in Ghostty
- `ghostty-wayland-clipboard.sh` - Wayland clipboard integration
- `kde-default-terminal-ghostty.sh` - Set as KDE default terminal
- `kde-fix-ghostty-shortcut.sh` - Fix KDE keyboard shortcuts

### Troubleshooting Scripts (from troubleshooting/kde-terminal/)
- `troubleshooting/ghostty-clean-config.sh`
- `troubleshooting/ghostty-deep-test.sh`
- `troubleshooting/ghostty-diagnose.sh`
- `troubleshooting/ghostty-fix-keys.sh`
- `troubleshooting/ghostty-test-keys.sh`

## Restoring

If you want to use Ghostty again, move these scripts back to their original locations and rename with `.sh` extension.
