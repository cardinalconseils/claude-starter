#!/bin/bash
# Write session ID for log correlation
mkdir -p .prd/logs
date -u +"%Y-%m-%dT%H:%M" > .prd/logs/.current_session_id

# --- Caveman mode status (default ON unless .cks/caveman-disabled exists) ---
if [ -f ".cks/caveman-disabled" ]; then
  CAVEMAN_STATUS="off"
  CAVEMAN_BANNER="🪨 Caveman: OFF — /cks:caveman on to enable"
else
  CAVEMAN_STATUS="on"
  CAVEMAN_BANNER="🪨 Caveman: ON (full) — /cks:caveman off to disable"
fi

# --- Version change detection ---
PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CURRENT_VERSION=$(cat "$PLUGIN_ROOT/VERSION" 2>/dev/null | head -1 | xargs)
[ -z "$CURRENT_VERSION" ] && CURRENT_VERSION=$(grep '"version"' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null | head -1 | sed 's/.*: *"//;s/".*//')
LAST_VERSION_FILE="$HOME/.claude/.cks-last-version"
LAST_VERSION=$(cat "$LAST_VERSION_FILE" 2>/dev/null)

if [ -n "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" != "$LAST_VERSION" ] && [ -n "$LAST_VERSION" ]; then
  REPO_URL=$(grep '"repository"' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null | sed 's/.*: *"//;s/".*//')
  [ -z "$REPO_URL" ] && REPO_URL="https://github.com/cardinalconseils/claude-starter"
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

# --- Auto-migration (silent, idempotent — applies all pending migrations) ---
if [ -d ".prd" ]; then
  VERSION_FILE=".prd/.cks-version"
  PROJECT_CKS_VER=$(cat "$VERSION_FILE" 2>/dev/null | head -1 | xargs)
  NEEDS_MIGRATE=false
  if [ -z "$PROJECT_CKS_VER" ]; then
    NEEDS_MIGRATE=true
    OLD_VER="pre-4.0"
  elif [ "$PROJECT_CKS_VER" != "$CURRENT_VERSION" ]; then
    NEEDS_MIGRATE=true
    OLD_VER="$PROJECT_CKS_VER"
  fi

  if [ "$NEEDS_MIGRATE" = true ]; then
    MIGRATE_SCRIPT="$PLUGIN_ROOT/scripts/auto-migrate.sh"
    if [ -x "$MIGRATE_SCRIPT" ]; then
      "$MIGRATE_SCRIPT" "$PLUGIN_ROOT"
      # Belt-and-suspenders: write stamp if still missing after auto-migrate.
      # Handles the case where multiple CKS plugin instances are installed and
      # an older project-scoped instance runs AFTER the user-scoped one — its
      # auto-migrate exits early (project stamp > plugin version) without stamping.
      if [ ! -f "$VERSION_FILE" ]; then
        echo "$CURRENT_VERSION" > "$VERSION_FILE"
      fi
      # Only print the migration message when this plugin's version matches the
      # stamp (avoids misleading "v4.15.0 → v4.13.20" from stale project-scoped
      # plugin instances).
      STAMP_NOW=$(cat "$VERSION_FILE" 2>/dev/null | head -1 | xargs)
      if [ "$STAMP_NOW" = "$CURRENT_VERSION" ]; then
        echo ""
        echo "✓ Auto-migrated v${OLD_VER} → v${CURRENT_VERSION}"
      fi
    else
      echo ""
      echo "⬆️  Run /cks:migrate — project at v${OLD_VER}, plugin at v${CURRENT_VERSION}"
    fi
  fi
fi

# --- Work hierarchy: legacy auto-wrap (idempotent, silent on failure) ---
if [ -d ".prd/phases" ] && [ ! -f ".prd/work-hierarchy.md" ]; then
  PHASE_DIRS=$(ls -1d .prd/phases/*/ 2>/dev/null | head -50)
  if [ -n "$PHASE_DIRS" ]; then
    {
      echo "---"
      echo "version: 1"
      echo "active_feature: F-LEGACY"
      echo "active_phase: —"
      echo "features:"
      echo "  - id: F-LEGACY"
      echo "    title: \"Legacy\""
      echo "    status: doing"
      echo "    slug: legacy"
      echo "    phases:"
      for d in $PHASE_DIRS; do
        base=$(basename "$d")
        num=$(echo "$base" | sed 's/^\([0-9][0-9]*\).*/\1/')
        slug=$(echo "$base" | sed 's/^[0-9][0-9]*-//')
        [ -z "$num" ] && continue
        echo "      - id: P-${num}"
        echo "        title: \"Legacy phase: ${slug}\""
        echo "        status: doing"
        echo "        slug: ${slug}"
        echo "        tasks: []"
      done
      echo "---"
      echo ""
      echo "# Work Hierarchy"
      echo ""
      echo "_Auto-wrapped from existing flat phases. Edit via \`/cks:work\` only._"
    } > .prd/work-hierarchy.md.tmp 2>/dev/null
    if [ -s ".prd/work-hierarchy.md.tmp" ]; then
      mv .prd/work-hierarchy.md.tmp .prd/work-hierarchy.md 2>/dev/null
    else
      rm -f .prd/work-hierarchy.md.tmp 2>/dev/null
    fi
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

  RTK_STATUS="not installed"
  command -v rtk >/dev/null 2>&1 && RTK_STATUS="active ($(rtk --version 2>/dev/null | head -1))"

  # Detect missing breadcrumb — warn instead of silently showing blanks
  NEXT_DISPLAY="${NEXT}"
  CMD_DISPLAY="${CMD}"
  MISSING_CRUMB=false
  if [ -z "$NEXT" ] || [ "$NEXT" = "—" ]; then
    NEXT_DISPLAY="⚠ No context left — run /cks:status to detect where you are"
    CMD_DISPLAY="/cks:status"
    MISSING_CRUMB=true
  fi

  cat <<EOF
📍 CKS Session Resume
━━━━━━━━━━━━━━━━━━━━
Phase:   ${PHASE} — ${PHASE_NAME}
Status:  ${STATUS}
Rules:   ${RULES_COUNT} guardrail(s) active
RTK:     ${RTK_STATUS}
Last:    ${LAST} (${LAST_DATE})
Next:    ${NEXT_DISPLAY}
Run:     ${CMD_DISPLAY}
EOF

  # Work hierarchy active pointers (if any)
  if [ -f ".prd/work-hierarchy.md" ]; then
    ACTIVE_F=$(grep "^Active Feature:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)
    ACTIVE_PH=$(grep "^Active Phase (Hierarchy):" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)
    if [ -n "$ACTIVE_F" ] && [ "$ACTIVE_F" != "—" ]; then
      echo "Work:    ${ACTIVE_F}${ACTIVE_PH:+ / ${ACTIVE_PH}}"
    fi
  fi

  # Show last session context if available
  if [ -n "$LAST_SESSION" ]; then
    echo "Memory:  ${LAST_SESSION}"
  fi

  # User profile status
  PROFILE_FILE="$HOME/.cks/user-profile.md"
  if [ -f "$PROFILE_FILE" ]; then
    PROFILE_NAME=$(grep "^name:" "$PROFILE_FILE" 2>/dev/null | sed 's/name: *//' | xargs)
    PROFILE_ROLE=$(grep "^role:" "$PROFILE_FILE" 2>/dev/null | sed 's/role: *//' | xargs)
    PROFILE_STYLE=$(grep "^communication_style:" "$PROFILE_FILE" 2>/dev/null | sed 's/communication_style: *//' | xargs)
    PROFILE_BANNER="${PROFILE_NAME:+$PROFILE_NAME — }${PROFILE_ROLE}${PROFILE_STYLE:+ / $PROFILE_STYLE}  — /cks:me to update"
    echo "Profile: ✓ ${PROFILE_BANNER}"
  else
    echo "Profile: not set — /cks:me to personalize (5 min)"
  fi
  if [ -n "$PENDING_CONVENTIONS" ]; then
    echo "Review:  ${PENDING_CONVENTIONS} — /cks:sprint-close to review"
  fi

  # Peer status (optional — only if claude-peers broker is reachable)
  PEER_INFO=""
  if command -v curl >/dev/null 2>&1; then
    PEER_HEALTH=$(curl -s --max-time 1 http://127.0.0.1:${CLAUDE_PEERS_PORT:-7899}/health 2>/dev/null)
    if [ -n "$PEER_HEALTH" ]; then
      PEER_COUNT=$(curl -s --max-time 1 http://127.0.0.1:${CLAUDE_PEERS_PORT:-7899}/list-peers -X POST -H "Content-Type: application/json" -d '{"scope":"machine"}' 2>/dev/null | grep -o '"id"' | wc -l | tr -d ' ')
      [ "$PEER_COUNT" -gt 1 ] && echo "Peers:   ${PEER_COUNT} active session(s) — /cks:peers to coordinate"
    fi
  fi

  # Factory queue check — requires gh CLI and a GitHub remote
  if command -v gh >/dev/null 2>&1; then
    FACTORY_COUNT=$(gh issue list --label "cks:factory" --state open 2>/dev/null | wc -l | tr -d ' ')
    BACKLOG_COUNT=$(gh issue list --label "cks:backlog" --state open 2>/dev/null | wc -l | tr -d ' ')
    QUEUED=$((FACTORY_COUNT + BACKLOG_COUNT))
    [ "$QUEUED" -gt 0 ] && echo "Factory: ${QUEUED} issue(s) queued — /cks:factory or /cks:next to run"
  fi

  echo "Voice:   ${CAVEMAN_BANNER}"
  # Phase-aware start hint
  PHASE_NUM=$(echo "$PHASE" | grep -o '^[0-9]*' | sed 's/^0*//')
  case "$PHASE_NUM" in
    1) START_CMD="/cks:discover" ;;
    2) START_CMD="/cks:design" ;;
    3) START_CMD="/cks:sprint" ;;
    4) START_CMD="/cks:review" ;;
    5) START_CMD="/cks:release" ;;
    *) START_CMD="/cks:sprint-start" ;;
  esac
  echo "Start:   ${START_CMD}"
  echo "━━━━━━━━━━━━━━━━━━━━"

  # Fresh handoff detection — show ⚡ Next Step if HANDOFF.md written in last 2 hours
  HANDOFF_FILE=".prd/HANDOFF.md"
  if [ -f "$HANDOFF_FILE" ]; then
    AGE=$(( $(date +%s) - $(date -r "$HANDOFF_FILE" +%s 2>/dev/null || echo 0) ))
    if [ "$AGE" -lt 7200 ]; then
      NEXT_STEP=$(grep "^>" "$HANDOFF_FILE" 2>/dev/null | head -1 | sed 's/^> *//')
      if [ -z "$NEXT_STEP" ]; then
        NEXT_STEP=$(grep "⚡" "$HANDOFF_FILE" 2>/dev/null | tail -1 | sed 's/.*⚡[^>]*//')
      fi
      if [ -n "$NEXT_STEP" ]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━"
        echo "⚡ HANDOFF RESUME"
        echo "━━━━━━━━━━━━━━━━━━━━"
        echo "${NEXT_STEP}"
        echo "Full handoff: ${HANDOFF_FILE}"
        echo "━━━━━━━━━━━━━━━━━━━━"
      fi
    fi
  fi

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

  ${CAVEMAN_BANNER}
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

  ${CAVEMAN_BANNER}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  fi
fi
exit 0
