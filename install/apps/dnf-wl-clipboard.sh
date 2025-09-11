#!/usr/bin/env bash
set -euo pipefail
rpm -q wl-clipboard >/dev/null 2>&1 || sudo dnf install -y wl-clipboard

