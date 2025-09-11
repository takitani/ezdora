#!/usr/bin/env bash
set -euo pipefail
rpm -q zip >/dev/null 2>&1 || sudo dnf install -y zip

