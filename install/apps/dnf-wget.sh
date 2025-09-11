#!/usr/bin/env bash
set -euo pipefail
rpm -q wget >/dev/null 2>&1 || sudo dnf install -y wget

