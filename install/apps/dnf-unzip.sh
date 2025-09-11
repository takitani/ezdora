#!/usr/bin/env bash
set -euo pipefail
rpm -q unzip >/dev/null 2>&1 || sudo dnf install -y unzip

