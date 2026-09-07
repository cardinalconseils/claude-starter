#!/bin/bash
# CKS User-Memory Isolation Guard — confines access to the active user's memory dir.
# PreToolUse on file/exec tools. Exit 2 = BLOCK (cross-user or traversal) | Exit 0 = allow.
# Active user comes from $CKS_ACTIVE_USER (set by the channel adapter from the TRUSTED
# sender ID), defaulting to "local" for single-user/cli. Never derived from message text.
# Layout via scripts/hq-path.sh: $CKS_HQ/users/<slug> when HQ is set, else ~/.cks/user/<slug>.

INPUT=$(cat 2>/dev/null)
PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
[ -f "$PLUGIN_ROOT/scripts/hq-path.sh" ] && . "$PLUGIN_ROOT/scripts/hq-path.sh"
ACTIVE="${CKS_ACTIVE_USER:-local}"
HQ_ROOT=$(cks_hq_root 2>/dev/null || echo "$HOME/.cks")
USER_DIR=$(cks_user_dir "$ACTIVE" 2>/dev/null || echo "$HOME/.cks/user/$ACTIVE")
FINOPS=$(cks_finops_dir 2>/dev/null || echo "$HOME/.cks/finops")
ROUTINES="$HQ_ROOT/.routines"
PARSED=$(echo "$INPUT" | python3 -c "
import sys,json
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
ti=d.get('tool_input',d)
print(ti.get('command') or d.get('command') or '')
for k in ('file_path','path','notebook_path'):
    v=ti.get(k) or d.get(k)
    if v: print(v)
" 2>/dev/null)
CMD=$(printf '%s\n' "$PARSED" | head -1)
PATHS=$(printf '%s\n' "$PARSED" | tail -n +2)
block() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔒  USER-MEMORY ISOLATION — ACCESS BLOCKED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Active user: ${ACTIVE}"
  echo "  Reason:      $1"
  echo "  Allowed:     ${USER_DIR}/ (plus ${FINOPS}/ and ${ROUTINES}/)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  exit 2
}

# File tools (Read/Grep/Glob/Edit/Write): strong enforcement.
while IFS= read -r p; do
  [ -z "$p" ] && continue
  case "$p" in *".cks/user"*|"$HQ_ROOT/users"*) ;; *) continue ;; esac
  case "$p" in *".."*) block "Path traversal: $p" ;; esac
  case "$p" in
    "$USER_DIR"|"$USER_DIR/"*|*".cks/user/$ACTIVE"|*".cks/user/$ACTIVE/"*) ;;
    "$FINOPS"|"$FINOPS/"*|"$ROUTINES"|"$ROUTINES/"*) ;;
    *) block "Access outside active user dir: $p" ;;
  esac
done <<< "$PATHS"
# Bash: best-effort — block traversal and references to any non-active user slug.
if printf '%s' "$CMD" | grep -qE "\.cks/user|$HQ_ROOT/users"; then
  printf '%s' "$CMD" | grep -qE "(\.cks/user|$HQ_ROOT/users)/[^ ]*\.\." && block "Path traversal in Bash command"
  OTHERS=$(printf '%s' "$CMD" | grep -oE "(\.cks/user|$HQ_ROOT/users)/[A-Za-z0-9_-]+" | grep -vE "/${ACTIVE}$")
  [ -n "$OTHERS" ] && block "Bash command references another user's memory: $(echo "$OTHERS" | head -1)"
fi

exit 0
