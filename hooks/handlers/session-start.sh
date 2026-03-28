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

  cat <<EOF
📍 CKS Session Resume
━━━━━━━━━━━━━━━━━━━━
Phase:   ${PHASE} — ${PHASE_NAME}
Status:  ${STATUS}
Last:    ${LAST} (${LAST_DATE})
Next:    ${NEXT}
Run:     ${CMD}
━━━━━━━━━━━━━━━━━━━━
EOF
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
