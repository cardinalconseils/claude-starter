#!/bin/bash
# Outputs CKS version info — called by /cks:version command

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

PLUGIN_VER=$(grep '"version"' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null | head -1 | sed 's/.*: *"//;s/".*//')
REPO_URL=$(grep '"repository"' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null | sed 's/.*: *"//;s/".*//')

PROJECT_VER=""
if [ -f ".prd/.cks-version" ]; then
  PROJECT_VER=$(cat ".prd/.cks-version" | head -1 | xargs)
elif [ -d ".prd" ]; then
  PROJECT_VER="not stamped"
else
  PROJECT_VER="not initialized"
fi

if [ "$PROJECT_VER" = "not initialized" ]; then
  SYNC_STATUS="(run /cks:bootstrap or /cks:new)"
elif [ "$PROJECT_VER" = "not stamped" ]; then
  SYNC_STATUS="⬆ run /cks:migrate"
elif [ "$PROJECT_VER" != "$PLUGIN_VER" ]; then
  SYNC_STATUS="⬆ run /cks:migrate"
else
  SYNC_STATUS="✓ in sync"
fi

cat <<EOF
CKS Version
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Plugin:   v${PLUGIN_VER}
  Project:  ${PROJECT_VER}  ${SYNC_STATUS}

  Update:   claude plugin update cks@cks-marketplace
  Changes:  ${REPO_URL}/blob/main/CHANGELOG.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
