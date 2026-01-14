#!/usr/bin/env bash
set -euo pipefail
rpm -q gh >/dev/null 2>&1 || sudo dnf install -y gh
