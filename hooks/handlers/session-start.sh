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

# --- Ecosystem Watch: surface HIGH alerts from last 14 days ---
ECOSYSTEM_INDEX="${CLAUDE_PLUGIN_ROOT}/skills/ecosystem-watch/index.md"
if [ -f "$ECOSYSTEM_INDEX" ]; then
  CUTOFF=$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d '14 days ago' +%Y-%m-%d 2>/dev/null)
  HIGH_ALERTS=$(awk -F'|' 'NR>2 && $5~/HIGH/ && $2>="'"$CUTOFF"'" {print "  •",$2,$3": "$4"—"$6}' "$ECOSYSTEM_INDEX" 2>/dev/null)
  if [ -n "$HIGH_ALERTS" ]; then
    echo ""
    echo "⚠️  ECOSYSTEM ALERT (last 14 days)"
    echo "$HIGH_ALERTS"
  fi
fi

# --- Control plane auto-init (safe, idempotent — only when project bootstrapped) ---
if [ -d ".prd" ] && [ ! -f ".cks/control-plane/config.yaml" ]; then
  mkdir -p .cks/control-plane/memory/project
  mkdir -p .cks/control-plane/memory/sessions
  mkdir -p .cks/control-plane/memory/agents
  cat > .cks/control-plane/config.yaml <<'CPEOF'
personas:
  enabled: false
raid:
  enabled: false
CPEOF
  touch .cks/control-plane/memory/project/facts.md
  touch .cks/control-plane/memory/project/decisions.md
  touch .cks/control-plane/memory/project/gotchas.md
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
      LAST_SESSION=$(grep "^## Session" "$LATEST_FILE" 2>/dev/null | tail -1 | sed 's/^## //')
      LAST_HEADER_LINE=$(grep -n "^## Session" "$LATEST_FILE" 2>/dev/null | tail -1 | cut -d: -f1)
      if [ -n "$LAST_HEADER_LINE" ]; then
        LAST_SESSION_BODY=$(awk "NR>$LAST_HEADER_LINE && NR<=$((LAST_HEADER_LINE + 8))" "$LATEST_FILE" 2>/dev/null | grep -v "^$" | head -5)
      fi
    fi
  fi

  # Check for pending convention proposals
  PENDING_CONVENTIONS=""
  if [ -f "$LEARNINGS_DIR/conventions.md" ]; then
    PENDING_COUNT=$(grep -c "^\- \[ \]" "$LEARNINGS_DIR/conventions.md" 2>/dev/null || echo 0)
    [ "$PENDING_COUNT" -gt 0 ] && PENDING_CONVENTIONS="${PENDING_COUNT} pending convention(s)"
  fi

  # Sleep cycle status (only if sleep is enabled and .sleep/ dir exists)
  SLEEP_BANNER=""
  if [ -f ".cks/sleep-enabled" ] && [ -d ".sleep" ]; then
    SLEEP_STAGED=$(ls .sleep/staged/ 2>/dev/null | wc -l | tr -d ' ')
    # Always show last-harvest info when results exist (AC-3.1, AC-3.2)
    LAST_RESULT=$(ls .sleep/results/*.json 2>/dev/null | sort | tail -1)
    if [ -n "$LAST_RESULT" ]; then
      LAST_RESULT_DATE=$(basename "$LAST_RESULT" .json)
      LAST_RESULT_TS=$(date -d "$LAST_RESULT_DATE" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$LAST_RESULT_DATE" +%s 2>/dev/null || echo "$(date +%s)")
      DAYS_AGO=$(( ( $(date +%s) - LAST_RESULT_TS ) / 86400 ))
      if [ "${DAYS_AGO:-0}" -gt 7 ]; then
        SLEEP_HARVEST_BANNER="⚠ Sleep: stale (last harvest ${DAYS_AGO} days ago) — run /cks:sleep --status"
      else
        SLEEP_HARVEST_BANNER="💤 Sleep: last harvest ${LAST_RESULT_DATE}"
      fi
    else
      SLEEP_HARVEST_BANNER="💤 Sleep: not yet run"
    fi
    # Show staged-pending banner first when applicable (AC-3.1 staged banner preserved)
    if [ "${SLEEP_STAGED:-0}" -gt 0 ]; then
      SLEEP_BANNER="💤 Sleep proposals pending (${SLEEP_STAGED}) — /cks:sleep --adopt to review
${SLEEP_HARVEST_BANNER}"
    else
      SLEEP_BANNER="${SLEEP_HARVEST_BANNER}"
    fi
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
    if [ -n "$LAST_SESSION_BODY" ]; then
      echo "$LAST_SESSION_BODY" | while IFS= read -r line; do echo "         ${line}"; done
    fi
  fi

  # User profile status
  PROFILE_FILE="$HOME/.cks/user-profile.md"
  if [ -f "$PROFILE_FILE" ]; then
    PROFILE_NAME=$(grep "^name:" "$PROFILE_FILE" 2>/dev/null | sed 's/name: *//' | xargs)
    PROFILE_ROLE=$(grep "^role:" "$PROFILE_FILE" 2>/dev/null | sed 's/role: *//' | xargs)
    PROFILE_STYLE=$(grep "^communication_style:" "$PROFILE_FILE" 2>/dev/null | sed 's/communication_style: *//' | xargs)
    PROFILE_BANNER="${PROFILE_NAME:+$PROFILE_NAME — }${PROFILE_ROLE}${PROFILE_STYLE:+ / $PROFILE_STYLE}  — /cks:me to update"
    echo "Profile: ✓ ${PROFILE_BANNER}"
    echo ""
    echo "--- USER PROFILE (active for this session) ---"
    cat "$PROFILE_FILE"
    echo "--- END USER PROFILE ---"
  else
    echo "Profile: not set — /cks:me to personalize (5 min)"
  fi
  if [ -n "$PENDING_CONVENTIONS" ]; then
    echo "Review:  ${PENDING_CONVENTIONS} — /cks:sprint-close to review"
  fi
  if [ -n "$SLEEP_BANNER" ]; then
    echo "${SLEEP_BANNER}"
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

  # CCCS threat issues — surfaced by remote Claude Desktop routine
  CCCS_CHECK="${CLAUDE_PLUGIN_ROOT}/scripts/cccs-session-check.sh"
  [ -x "$CCCS_CHECK" ] && "$CCCS_CHECK" 2>/dev/null || true

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
        # Find the matching archive file before deleting the pointer
        ARCHIVE_FILE=$(ls -t .prd/handoffs/HANDOFF-*.md 2>/dev/null | head -1)
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━"
        echo "⚡ HANDOFF RESUME"
        echo "━━━━━━━━━━━━━━━━━━━━"
        echo "${NEXT_STEP}"
        echo "Full handoff: ${ARCHIVE_FILE:-$HANDOFF_FILE}"
        echo "━━━━━━━━━━━━━━━━━━━━"
        # Consume the pointer — archive copy preserved in .prd/handoffs/
        rm -f "$HANDOFF_FILE" 2>/dev/null
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
# --- CKS v6 Control Plane: activation gate ---
CP_CONFIG=".cks/control-plane/config.yaml"
CP_MANIFEST=".cks/control-plane/personas/manifest.yaml"
PLUGIN_CP_MANIFEST="${CLAUDE_PLUGIN_ROOT}/skills/control-plane/personas/manifest.yaml"

if [ -f "$CP_CONFIG" ]; then
  # Determine which manifest to use: project-local overrides plugin default
  MANIFEST_TO_USE=""
  if [ -f "$CP_MANIFEST" ]; then
    MANIFEST_TO_USE="$CP_MANIFEST"
  elif [ -f "$PLUGIN_CP_MANIFEST" ]; then
    MANIFEST_TO_USE="$PLUGIN_CP_MANIFEST"
  fi

  # Check personas.enabled in config
  PERSONAS_ENABLED=$(grep "enabled: true" "$CP_CONFIG" 2>/dev/null | head -1)

  if [ -n "$PERSONAS_ENABLED" ]; then
    if [ -n "$MANIFEST_TO_USE" ]; then
      PERSONA_COUNT=$(grep -c "^  [a-z]" "$MANIFEST_TO_USE" 2>/dev/null || echo 0)
    else
      PERSONA_COUNT=0
    fi
    echo ""
    echo "🎭 Control Plane: active — ${PERSONA_COUNT} personas loaded"
    [ -n "$MANIFEST_TO_USE" ] && echo "   Manifest: $(basename "$MANIFEST_TO_USE") ($(wc -c < "$MANIFEST_TO_USE" | tr -d ' ') bytes)"
    echo "   Run /cks:personas to view roster"
  fi

  # Check raid.enabled in config
  RAID_ENABLED=$(grep "raid:" "$CP_CONFIG" 2>/dev/null)
  RAID_FILE=".cks/control-plane/raid/raid.md"
  if [ -n "$RAID_ENABLED" ] && [ -f "$RAID_FILE" ]; then
    OPEN_COUNT=$(grep -c "^Status: Open" "$RAID_FILE" 2>/dev/null || echo 0)
    [ "$OPEN_COUNT" -gt 0 ] && echo "   RAID:  ${OPEN_COUNT} open item(s) — /cks:raid to review"
  fi

  # Phase 1: Show registered heartbeat agents from state files
  HEARTBEAT_STATE_DIR=".cks/control-plane/heartbeat/state"
  if [ -d "$HEARTBEAT_STATE_DIR" ]; then
    HEARTBEAT_COUNT=$(ls "$HEARTBEAT_STATE_DIR"/*.json 2>/dev/null | wc -l | tr -d ' ')
    SUPABASE_URL=$(grep "supabase_url:" "$CP_CONFIG" 2>/dev/null | sed 's/.*supabase_url: *//' | xargs)
    if [ "$HEARTBEAT_COUNT" -gt 0 ]; then
      echo "   Agents: ${HEARTBEAT_COUNT} heartbeat agent(s) registered"
      if [ -z "$SUPABASE_URL" ]; then
        echo "   ⚠ supabase_url missing in config.yaml — Phase 1 DB features inactive"
      else
        echo "   DB: ${SUPABASE_URL%%/*}// (run /cks:heartbeat status for live view)"
      fi
    fi
  fi

  # Memory summary
  MEMORY_SESSIONS_DIR=".cks/control-plane/memory/sessions"
  LATEST_MEM=$(ls -t "$MEMORY_SESSIONS_DIR"/*.md 2>/dev/null | head -1)
  if [ -n "$LATEST_MEM" ]; then
    MEM_LINE=$(head -1 "$LATEST_MEM" | sed 's/^## //')
    echo "   Memory: ${MEM_LINE}"
  fi
  FACTS_COUNT=$(grep -c "^## \[" ".cks/control-plane/memory/project/facts.md" 2>/dev/null || echo 0)
  DECISIONS_COUNT=$(grep -c "^## \[" ".cks/control-plane/memory/project/decisions.md" 2>/dev/null || echo 0)
  [ "$((FACTS_COUNT + DECISIONS_COUNT))" -gt 0 ] && \
    echo "   KB: ${FACTS_COUNT} facts, ${DECISIONS_COUNT} decisions — /cks:memory to review"

   # Phase 3: Agent Registry — clean stale locks, register this session
   PLUGIN_ROOT_CP="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
   REGISTRY_SCRIPT="$PLUGIN_ROOT_CP/scripts/agent-registry.sh"
   if [ -x "$REGISTRY_SCRIPT" ]; then
     SESSION_ID=$(date +%Y%m%d-%H%M%S)-$$
     export CKS_SESSION_ID="$SESSION_ID"
     "$REGISTRY_SCRIPT" clean 2>/dev/null || true
     PHASE_TASK=$(grep "Next Action:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)
     "$REGISTRY_SCRIPT" register "$SESSION_ID" "${PHASE_TASK:-idle}" 2>/dev/null || true
     ACTIVE_COUNT=$(ls .cks/control-plane/agents/registry/*.lock 2>/dev/null | wc -l | tr -d ' ')
     [ "${ACTIVE_COUNT:-0}" -gt 1 ] && echo "   Sessions: ${ACTIVE_COUNT} active — /cks:agents for coordination"
     SYNC_SCRIPT="$PLUGIN_ROOT_CP/scripts/sync-agent-sessions.sh"
     [ -x "$SYNC_SCRIPT" ] && "$SYNC_SCRIPT" start "$SESSION_ID" "${PHASE_TASK:-idle}" 2>/dev/null || true
   fi
   # Phase 4: Observability start + cost banner
   OBS_START="${PLUGIN_ROOT_CP}/scripts/observability-start.sh"
   [ -x "$OBS_START" ] && "$OBS_START" 2>/dev/null || true
   TOTALS_FILE=".cks/control-plane/observability/totals.json"
   if [ -f "$TOTALS_FILE" ] && command -v jq >/dev/null 2>&1; then
     WEEK_SESS=$(jq -r '.week_sessions // 0' "$TOTALS_FILE" 2>/dev/null || echo 0)
     WEEK_DUR=$(jq -r '.week_duration_seconds // 0' "$TOTALS_FILE" 2>/dev/null || echo 0)
     WEEK_HRS=$(( WEEK_DUR / 3600 ))
     TOTAL_SESS=$(jq -r '.total_sessions // 0' "$TOTALS_FILE" 2>/dev/null || echo 0)
     echo "   Cost:  ${WEEK_SESS} session(s) this week (${WEEK_HRS}h) | ${TOTAL_SESS} total — /cks:cost"
   fi
   # Phase 5: Pending improvements
   IMPROVEMENTS_PENDING_DIR=".cks/control-plane/improvements/pending"
   if [ -d "$IMPROVEMENTS_PENDING_DIR" ]; then
     IMP_COUNT=$(ls "$IMPROVEMENTS_PENDING_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
     [ "${IMP_COUNT:-0}" -gt 0 ] && echo "   Improve: ${IMP_COUNT} pending proposal(s) — /cks:improve"
   fi
   # Phase 6: Health check + queue depth
   HEALTH_SCRIPT="${PLUGIN_ROOT_CP}/scripts/control-plane-health.sh"
   if [ -x "$HEALTH_SCRIPT" ]; then
     HEALTH_OUT=$("$HEALTH_SCRIPT" 2>/dev/null)
     [ -n "$HEALTH_OUT" ] && echo "$HEALTH_OUT"
   fi
   QUEUE_DEPTH=$(ls ".cks/control-plane/sync-queue/"*.json 2>/dev/null | wc -l | tr -d ' ')
   [ "${QUEUE_DEPTH:-0}" -gt 0 ] && echo "   ⚠ Sync queue: ${QUEUE_DEPTH} item(s) — /cks:control-plane --drain"
fi
# --- End control plane gate ---

exit 0
