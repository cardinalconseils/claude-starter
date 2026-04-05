#!/bin/bash
# Write session ID for log correlation
mkdir -p .prd/logs
date -u +"%Y-%m-%dT%H:%M" > .prd/logs/.current_session_id

# --- Version change detection ---
PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CURRENT_VERSION=$(grep '"version"' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null | head -1 | sed 's/.*: *"//;s/".*//')
LAST_VERSION_FILE="$HOME/.claude/.cks-last-version"
LAST_VERSION=$(cat "$LAST_VERSION_FILE" 2>/dev/null)

if [ -n "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" != "$LAST_VERSION" ] && [ -n "$LAST_VERSION" ]; then
  REPO_URL=$(grep '"repository"' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null | sed 's/.*: *"//;s/".*//')
  cat <<EOF

🆙 CKS updated: ${LAST_VERSION} → ${CURRENT_VERSION}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Changelog: ${REPO_URL}/blob/main/CHANGELOG.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
fi

# Save current version for next comparison
if [ -n "$CURRENT_VERSION" ]; then
  mkdir -p "$(dirname "$LAST_VERSION_FILE")"
  echo "$CURRENT_VERSION" > "$LAST_VERSION_FILE"
fi

# --- Migration check (detection only — dispatches to /cks:migrate) ---
if [ -d ".prd" ]; then
  VERSION_FILE=".prd/.cks-version"
  PROJECT_CKS_VER=$(cat "$VERSION_FILE" 2>/dev/null | head -1 | xargs)
  if [ -z "$PROJECT_CKS_VER" ] && [ -f ".prd/PRD-STATE.md" ]; then
    echo ""
    echo "⬆️  Run /cks:migrate — project state predates current CKS version"
  elif [ -n "$PROJECT_CKS_VER" ] && [ "$PROJECT_CKS_VER" != "$CURRENT_VERSION" ]; then
    echo ""
    echo "⬆️  Run /cks:migrate — project at v${PROJECT_CKS_VER}, plugin at v${CURRENT_VERSION}"
  fi
fi

# CKS SessionStart hook — show PRD status or onboarding prompt

if [ -f ".prd/PRD-STATE.md" ]; then
  # Existing project — show resume status
  PHASE=$(grep "Active Phase:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)
  PHASE_NAME=$(grep "Phase Name:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)
  STATUS=$(grep "Phase Status:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)
  LAST=$(grep "Last Action:" .prd/PRD-STATE.md | head -1 | sed 's/.*: *//;s/\*//g' | xargs)
  LAST_DATE=$(grep "Last Action Date:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)
  NEXT=$(grep "Next Action:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)
  CMD=$(grep "Suggested Command:" .prd/PRD-STATE.md | sed 's/.*: *//;s/\*//g' | xargs)

  # Check for session continuity — last session's learnings
  LEARNINGS_DIR=".learnings"
  LAST_SESSION=""
  if [ -d "$LEARNINGS_DIR" ]; then
    # Find most recent session file
    LATEST_FILE=$(ls -t "$LEARNINGS_DIR"/session-*.md 2>/dev/null | head -1)
    if [ -n "$LATEST_FILE" ]; then
      LEARN_DATE=$(basename "$LATEST_FILE" | sed 's/session-//;s/.md//')
      # Get last session summary line (the ## Session HH:MM — ... line)
      LAST_SESSION=$(grep "^## Session" "$LATEST_FILE" 2>/dev/null | tail -1 | sed 's/^## //')
    fi
  fi

  # Check for pending convention proposals
  PENDING_CONVENTIONS=""
  if [ -f "$LEARNINGS_DIR/conventions.md" ]; then
    PENDING_COUNT=$(grep -c "^\- \[ \]" "$LEARNINGS_DIR/conventions.md" 2>/dev/null || echo 0)
    [ "$PENDING_COUNT" -gt 0 ] && PENDING_CONVENTIONS="${PENDING_COUNT} pending convention(s)"
  fi

  # Count guardrail files
  RULES_COUNT=0
  if [ -d ".claude/rules" ]; then
    RULES_COUNT=$(ls .claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ')
  fi

  cat <<EOF
📍 CKS Session Resume
━━━━━━━━━━━━━━━━━━━━
Phase:   ${PHASE} — ${PHASE_NAME}
Status:  ${STATUS}
Rules:   ${RULES_COUNT} guardrail(s) active
Last:    ${LAST} (${LAST_DATE})
Next:    ${NEXT}
Run:     ${CMD}
EOF

  # Show last session context if available
  if [ -n "$LAST_SESSION" ]; then
    echo "Memory:  ${LAST_SESSION}"
  fi
  if [ -n "$PENDING_CONVENTIONS" ]; then
    echo "Review:  ${PENDING_CONVENTIONS} — /cks:sprint-close to review"
  fi

  echo "Start:   /cks:sprint-start"
  echo "━━━━━━━━━━━━━━━━━━━━"

  # --- Generate status packet for machine consumption ---
  if command -v jq >/dev/null 2>&1; then
    LAST_EVT=$(tail -1 .prd/logs/lifecycle.jsonl 2>/dev/null | jq -r '.event // "none"')
    LAST_EVT_TS=$(tail -1 .prd/logs/lifecycle.jsonl 2>/dev/null | jq -r '.timestamp // ""')
    FEATURE_ID=$(grep "Active Feature:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)
    PRD_ID=$(grep "PRD ID:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)
    jq -cn \
      --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")" \
      --arg fid "${FEATURE_ID:-}" \
      --arg prd "${PRD_ID:-}" \
      --arg phase "${PHASE:-idle}" \
      --arg status "${STATUS:-idle}" \
      --arg checkpoint "${LAST:-}" \
      --arg next "${NEXT:-}" \
      --arg le "${LAST_EVT:-none}" \
      --arg lt "${LAST_EVT_TS:-}" \
      '{generated_at:$ts,feature_id:$fid,prd_id:$prd,phase:$phase,sub_step:null,status:$status,last_checkpoint:$checkpoint,blocker:null,recommended_action:$next,confidence_pct:null,last_event:$le,last_event_ts:$lt,active_workers:0,gates_passed:null,gates_total:null}' \
      > .prd/status-packet.json 2>/dev/null
  fi
else
  # First time in this project — show onboarding
  HAS_CODE=false
  if [ -f "package.json" ] || [ -f "pyproject.toml" ] || [ -f "Cargo.toml" ] || [ -f "go.mod" ] || [ -f "requirements.txt" ]; then
    HAS_CODE=true
  fi

  if [ "$HAS_CODE" = true ]; then
    cat <<EOF
🆕 CKS — First time in this project
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Existing codebase detected. How would you like to start?

  /cks:adopt       → Mid-development? Adopt CKS into your current work
  /cks:bootstrap   → Fresh start with CKS lifecycle for this project
  /cks:help        → See all available commands
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  else
    cat <<EOF
🆕 CKS — First time in this project
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
No codebase detected. How would you like to start?

  /cks:kickstart   → Got an idea? Go from idea to scaffolded project
  /cks:bootstrap   → Have code already? Set up CKS lifecycle
  /cks:help        → See all available commands
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  fi
fi
exit 0
