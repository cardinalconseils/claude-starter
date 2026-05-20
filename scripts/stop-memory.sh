#!/bin/bash
# Writes dated session snapshot and syncs memory to Supabase.
# Called from stop.sh. Always exits 0.

CP_CONFIG=".cks/control-plane/config.yaml"
[ -f "$CP_CONFIG" ] || exit 0

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
SESSIONS_DIR=".cks/control-plane/memory/sessions"
mkdir -p "$SESSIONS_DIR" 2>/dev/null

SNAPSHOT_FILE="${SESSIONS_DIR}/$(date +%Y-%m-%d-%H%M).md"

if [ ! -f "$SNAPSHOT_FILE" ]; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
  COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
  UNCOMMITTED=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
  PHASE=$(grep "Active Phase:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)
  NEXT=$(grep "Next Action:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)

  cat > "$SNAPSHOT_FILE" <<EOF
## Session $(date +%H:%M) — Branch: ${BRANCH} | Phase: ${PHASE:-—} | Commits: ${COMMIT_COUNT} | Uncommitted: ${UNCOMMITTED} files
Next: ${NEXT:-—}
EOF
fi

SYNC_SCRIPT="$PLUGIN_ROOT/scripts/memory-sync.sh"
[ -x "$SYNC_SCRIPT" ] && "$SYNC_SCRIPT" 2>/dev/null || true

exit 0
