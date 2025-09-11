#!/usr/bin/env bash
set -euo pipefail
rpm -q xclip >/dev/null 2>&1 || sudo dnf install -y xclip

