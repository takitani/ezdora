#!/usr/bin/env bash
set -euo pipefail
rpm -q tree >/dev/null 2>&1 || sudo dnf install -y tree

