#!/bin/bash
# CKS Large Read Guard — blocks whole-file Read of oversized files so the orchestrator's
# context is not permanently occupied by content a subagent should hold.
# Enforces .claude/rules/dispatch-first.md; scoped reads (offset/limit) always pass.

INPUT=$(cat 2>/dev/null)
TOOL_NAME=$(printf '%s' "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null)
case "$TOOL_NAME" in ""|Read) ;; *) exit 0 ;; esac

read -r LIMIT FILE_PATH <<EOF
$(printf '%s' "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin).get('tool_input',{}) or {}; print(d.get('limit') or '-', d.get('file_path') or '')" 2>/dev/null)
EOF

# A scoped read is the correct behaviour this guard redirects to — never block it.
[ "$LIMIT" != "-" ] && exit 0
[ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ] && exit 0
grep -Iq . "$FILE_PATH" 2>/dev/null || exit 0   # binary (image, pdf) — not a context risk

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || printf '.')
[ -f "$ROOT/.cks/large-read-disabled" ] && exit 0

THRESHOLD="${CKS_LARGE_READ_LINES:-500}"
case "$THRESHOLD" in ""|*[!0-9]*) THRESHOLD=500 ;; esac  # bad env must not block every read
LINES=$(wc -l < "$FILE_PATH" 2>/dev/null | tr -d ' ')
[ -z "$LINES" ] && exit 0
[ "$LINES" -le "$THRESHOLD" ] 2>/dev/null && exit 0

MODE="${CKS_LARGE_READ_MODE:-block}"
HEAD="LARGE READ BLOCKED"
[ "$MODE" = "warn" ] && HEAD="LARGE READ (warn only — not blocked)"

cat >&2 <<MSG
$HEAD — $FILE_PATH is $LINES lines (threshold $THRESHOLD).
A whole-file read stays in this session's context and is re-sent on every later turn.
Use one of these instead:
  Agent(subagent_type="Explore", prompt="<narrow question about $FILE_PATH>")  ← preferred
  Read(file_path="$FILE_PATH", offset=<n>, limit=<n>)  ← when you know the slice you need
Tune: CKS_LARGE_READ_LINES · CKS_LARGE_READ_MODE=warn · .cks/large-read-disabled
MSG

[ "$MODE" = "warn" ] && exit 0
exit 2
