#!/bin/bash
# PreToolUse (Agent|Task) — Jev model router: asks TypeSafe Jev which Claude tier a
# dispatch needs, then lowers tool_input.model when it is safe to. Opt-in via
# CKS_JEV_ROUTING + TYPESAFE_API_KEY (skills/jev-routing/SKILL.md). All logic lives in
# scripts/jev-route.py; this file only pipes the event through. Exit 0 always.

INPUT=$(cat 2>/dev/null)
command -v python3 >/dev/null 2>&1 || exit 0
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
printf '%s' "$INPUT" | python3 "$PLUGIN_ROOT/scripts/jev-route.py"
exit 0
