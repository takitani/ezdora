#!/usr/bin/env bash
set -euo pipefail
rpm -q wkhtmltopdf >/dev/null 2>&1 || sudo dnf install -y wkhtmltopdf