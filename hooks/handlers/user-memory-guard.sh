#!/bin/bash
# CKS User-Memory Isolation Guard — confines access to the active user's memory dir.
# PreToolUse on file/exec tools. Exit 2 = BLOCK (cross-user or traversal) | Exit 0 = allow.
# Active user comes from $CKS_ACTIVE_USER (set by the channel adapter from the TRUSTED
# sender ID), defaulting to "local" for single-user/cli. Never derived from message text.

INPUT=$(cat 2>/dev/null)
BASE="$HOME/.cks/user"
ACTIVE="${CKS_ACTIVE_USER:-local}"

PATHS=$(echo "$INPUT" | python3 -c "
import sys,json
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
ti=d.get('tool_input',d)
for k in ('file_path','path','notebook_path'):
    v=ti.get(k) or d.get(k)
    if v: print(v)
" 2>/dev/null)
CMD=$(echo "$INPUT" | python3 -c "
import sys,json
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
ti=d.get('tool_input',d)
print(ti.get('command') or d.get('command') or '')
" 2>/dev/null)

block() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔒  USER-MEMORY ISOLATION — ACCESS BLOCKED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Active user: ${ACTIVE}"
  echo "  Reason:      $1"
  echo "  Allowed:     ${BASE}/${ACTIVE}/ only"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  exit 2
}

# File tools (Read/Grep/Glob/Edit/Write): strong enforcement.
while IFS= read -r p; do
  [ -z "$p" ] && continue
  case "$p" in *".cks/user"*) ;; *) continue ;; esac
  case "$p" in *".."*) block "Path traversal: $p" ;; esac
  case "$p" in
    "$BASE/$ACTIVE"|"$BASE/$ACTIVE/"*|*".cks/user/$ACTIVE"|*".cks/user/$ACTIVE/"*) ;;
    *) block "Access outside active user dir: $p" ;;
  esac
done <<< "$PATHS"

# Bash: best-effort — block traversal and references to any non-active user slug.
if echo "$CMD" | grep -q '\.cks/user'; then
  echo "$CMD" | grep -qE '\.cks/user/[^ ]*\.\.' && block "Path traversal in Bash command"
  OTHERS=$(echo "$CMD" | grep -oE '\.cks/user/[A-Za-z0-9_-]+' | grep -v "\.cks/user/${ACTIVE}$")
  [ -n "$OTHERS" ] && block "Bash command references another user's memory: $(echo "$OTHERS" | head -1)"
fi

exit 0
