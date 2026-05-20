#!/bin/bash
# Wrapper — delegates to generate-persona-manifest.py
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
python3 "$SCRIPT_DIR/generate-persona-manifest.py" "$@"
