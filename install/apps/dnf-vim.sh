#!/usr/bin/env bash
set -euo pipefail
rpm -q vim-enhanced >/dev/null 2>&1 || sudo dnf install -y vim-enhanced

