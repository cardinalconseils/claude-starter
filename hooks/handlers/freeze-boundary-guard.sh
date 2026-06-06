#!/usr/bin/env bash
# freeze-boundary-guard.sh — PreToolUse hook: blocks Edit/Write outside freeze boundary
# State: .cks/freeze-dir.txt in the git repo root

INPUT=$(cat)
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
FREEZE_FILE="${REPO_ROOT}/.cks/freeze-dir.txt"

[ ! -f "$FREEZE_FILE" ] && echo '{}' && exit 0

FREEZE_DIR=$(tr -d '[:space:]' < "$FREEZE_FILE")
[ -z "$FREEZE_DIR" ] && echo '{}' && exit 0

FILE_PATH=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read()).get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)
[ -z "$FILE_PATH" ] && echo '{}' && exit 0

case "$FILE_PATH" in
  /*) ;;
  *) FILE_PATH="$(pwd)/$FILE_PATH" ;;
esac

case "$FILE_PATH" in
  "${FREEZE_DIR}/"*|"${FREEZE_DIR}")
    echo '{}'
    ;;
  *)
    printf '{"permissionDecision":"deny","message":"[freeze] Blocked: %s is outside the freeze boundary (%s). Run /cks:unfreeze to remove it."}\n' "$FILE_PATH" "$FREEZE_DIR"
    ;;
esac
