#!/usr/bin/env bash
set -euo pipefail
rpm -q zsh >/dev/null 2>&1 || sudo dnf install -y zsh

