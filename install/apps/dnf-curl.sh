#!/usr/bin/env bash
set -euo pipefail
rpm -q curl >/dev/null 2>&1 || sudo dnf install -y curl

