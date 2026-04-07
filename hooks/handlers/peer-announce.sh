#!/bin/bash
# Auto-announce session status to claude-peers broker
# Called on: SessionStart, SubagentStop, PostToolUse (PRD-STATE changes), Stop
# Must exit 0 always — never block the user

BROKER_PORT="${CLAUDE_PEERS_PORT:-7899}"
BROKER_URL="http://127.0.0.1:${BROKER_PORT}"
PEER_ID_FILE=".prd/logs/.peer_id"

# --- Find or cache peer ID ---
PEER_ID=""
if [ -f "$PEER_ID_FILE" ]; then
  PEER_ID=$(cat "$PEER_ID_FILE" 2>/dev/null)
fi

if [ -z "$PEER_ID" ]; then
  # Discover our peer ID by matching TTY
  MY_TTY=$(tty 2>/dev/null | sed 's|/dev/||')
  if [ -n "$MY_TTY" ] && [ "$MY_TTY" != "not a tty" ]; then
    PEERS_JSON=$(curl -s --max-time 1 "$BROKER_URL/list-peers" -X POST \
      -H "Content-Type: application/json" \
      -d "{\"scope\":\"machine\",\"cwd\":\"$(pwd)\",\"git_root\":\"$(git rev-parse --show-toplevel 2>/dev/null)\"}" 2>/dev/null)
    if [ -n "$PEERS_JSON" ] && command -v jq >/dev/null 2>&1; then
      PEER_ID=$(echo "$PEERS_JSON" | jq -r ".[] | select(.tty == \"$MY_TTY\") | .id" 2>/dev/null | head -1)
      if [ -n "$PEER_ID" ]; then
        mkdir -p "$(dirname "$PEER_ID_FILE")" 2>/dev/null
        echo "$PEER_ID" > "$PEER_ID_FILE" 2>/dev/null
      fi
    fi
  fi
fi

# No peer ID — broker not running or not registered, skip silently
[ -z "$PEER_ID" ] && exit 0

# --- Build summary from available context ---
SUMMARY=""
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
[ -z "$PROJECT_NAME" ] && PROJECT_NAME=$(basename "$(pwd)")

# Source 1: PRD-STATE.md (lifecycle phases)
if [ -f ".prd/PRD-STATE.md" ]; then
  PHASE=$(grep "Active Phase:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)
  PHASE_NAME=$(grep "Phase Name:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)
  STATUS=$(grep "Phase Status:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)
  FEATURE=$(grep "Active Feature:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)
  FEATURE_DIR=$(grep "Feature Directory:" .prd/PRD-STATE.md 2>/dev/null | sed 's/.*: *//;s/\*//g' | xargs)

  if [ -n "$PHASE" ] && [ "$PHASE" != "idle" ] && [ "$PHASE" != "—" ]; then
    # Map phase number + name to activity code
    ACTIVITY=""
    case "$PHASE_NAME" in
      *[Dd]iscover*) ACTIVITY="discover" ;;
      *[Dd]esign*)   ACTIVITY="design" ;;
      *[Ss]print*)   ACTIVITY="sprint:${PHASE}" ;;
      *[Rr]eview*)   ACTIVITY="review" ;;
      *[Rr]elease*)  ACTIVITY="release" ;;
      *)             ACTIVITY="phase:${PHASE}" ;;
    esac

    DOC_PATH=""
    [ -n "$FEATURE_DIR" ] && DOC_PATH=" | Doc: .prd/phases/${FEATURE_DIR}/"

    SUMMARY="[${ACTIVITY}] ${FEATURE:-$PROJECT_NAME} — ${STATUS:-in progress}${DOC_PATH}"
  fi
fi

# Source 2: .kickstart/state.md (kickstart flow)
if [ -z "$SUMMARY" ] && [ -f ".kickstart/state.md" ]; then
  KS_STEP=$(grep "current_step:" .kickstart/state.md 2>/dev/null | sed 's/.*: *//' | xargs)
  if [ -n "$KS_STEP" ]; then
    SUMMARY="[kickstart:${KS_STEP}] ${PROJECT_NAME} — in progress"
  fi
fi

# Source 3: Git branch (fallback for freeform sessions)
if [ -z "$SUMMARY" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$BRANCH" ] && [ "$BRANCH" != "HEAD" ]; then
    SUMMARY="[active] ${PROJECT_NAME} — branch ${BRANCH}"
  else
    SUMMARY="[active] ${PROJECT_NAME}"
  fi
fi

# Special: if called from Stop hook, override with closing
if [ "${CKS_HOOK_EVENT:-}" = "stop" ]; then
  SUMMARY="[closing] ${PROJECT_NAME} — session ending"
fi

# --- Send to broker ---
curl -s --max-time 1 "$BROKER_URL/set-summary" -X POST \
  -H "Content-Type: application/json" \
  -d "{\"id\":\"${PEER_ID}\",\"summary\":\"${SUMMARY}\"}" >/dev/null 2>&1

exit 0
