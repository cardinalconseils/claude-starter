#!/bin/bash
# CKS Post-Edit Guard — validates DESIGN.md has all 9 required sections
# Runs as a PostToolUse hook on Edit/Write of DESIGN.md

FILE_PATH="${1:-}"
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Only check files named DESIGN.md
BASENAME="$(basename "$FILE_PATH")"
if [ "$BASENAME" != "DESIGN.md" ]; then
  exit 0
fi

SECTIONS=(
  "Visual Theme"
  "Color Palette"
  "Typography Rules"
  "Component Stylings"
  "Layout Principles"
  "Depth & Elevation"
  "Do's and Don'ts"
  "Responsive Behavior"
  "Agent Prompt Guide"
)

MISSING=""
for section in "${SECTIONS[@]}"; do
  if ! grep -qi "$section" "$FILE_PATH" 2>/dev/null; then
    MISSING="${MISSING}  - ${section}\n"
  fi
done

if [ -n "$MISSING" ]; then
  echo -e "⚠ DESIGN.md missing required sections:\n${MISSING}"
fi

exit 0
