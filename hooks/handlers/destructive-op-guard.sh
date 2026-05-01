#!/bin/bash
# CKS Destructive Operation Guard — blocks catastrophic commands before execution
# Runs as PreToolUse hook on all Bash tool calls
# Exit 2 = BLOCK (critical, irreversible) | Exit 0 = WARN (high risk, allowed)

# Read command from stdin — Claude Code passes tool_input as JSON
INPUT=$(cat 2>/dev/null)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('command',''))" 2>/dev/null)
if [ -z "$COMMAND" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.command // ""' 2>/dev/null)
fi
if [ -z "$COMMAND" ]; then
  exit 0
fi

RISK_LEVEL=""
RISK_REASON=""
REVERSIBLE="NO"

# ── File System ────────────────────────────────────────────────────────────────
if echo "$COMMAND" | grep -qE '\brm\s+(-[rfRF]*[rR][fF]?[rfRF]*|-rf|-fr|--recursive.*--force|--force.*--recursive)'; then
  RISK_LEVEL="CRITICAL"; RISK_REASON="Recursive + forced file deletion — unrecoverable"
elif echo "$COMMAND" | grep -qE 'find\s.+(-delete|-exec\s+rm)'; then
  RISK_LEVEL="CRITICAL"; RISK_REASON="find with -delete or -exec rm — may remove many files"
elif echo "$COMMAND" | grep -qE '\brm\s+(-f|--force)\s+'; then
  RISK_LEVEL="HIGH"; RISK_REASON="Forced file deletion — no confirmation, no trash"
fi

# ── Git Destructive ────────────────────────────────────────────────────────────
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*\s*(--force|-f)\b'; then
  RISK_LEVEL="CRITICAL"; RISK_REASON="Force push rewrites shared git history — permanent for others"
elif echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  RISK_LEVEL="CRITICAL"; RISK_REASON="Hard reset discards ALL uncommitted work permanently"
elif echo "$COMMAND" | grep -qE 'git\s+clean\s+-[a-zA-Z]*f'; then
  RISK_LEVEL="CRITICAL"; RISK_REASON="git clean -f removes untracked files — no trash, no undo"
elif echo "$COMMAND" | grep -qE 'git\s+(checkout|restore)\s+\.'; then
  RISK_LEVEL="HIGH"; RISK_REASON="Discards all working tree changes — uncommitted work lost"
elif echo "$COMMAND" | grep -qE 'git\s+branch\s+-D\s+'; then
  RISK_LEVEL="HIGH"; RISK_REASON="Force-deletes branch — may lose commits not merged elsewhere"
  REVERSIBLE="MAYBE"
elif echo "$COMMAND" | grep -qE 'git\s+rebase\s+.*--onto'; then
  RISK_LEVEL="HIGH"; RISK_REASON="Rebasing with --onto rewrites commit history"
  REVERSIBLE="MAYBE"
fi

# ── Database ───────────────────────────────────────────────────────────────────
if echo "$COMMAND" | grep -qiE '\b(DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE(\s+TABLE)?)'; then
  RISK_LEVEL="CRITICAL"; RISK_REASON="Drops or truncates database object — all data is lost"
elif echo "$COMMAND" | grep -qiE '\bDELETE\s+FROM\b' && ! echo "$COMMAND" | grep -qiE '\bWHERE\b'; then
  RISK_LEVEL="CRITICAL"; RISK_REASON="DELETE without WHERE — removes EVERY row in the table"
elif echo "$COMMAND" | grep -qiE '\bALTER\s+TABLE\b.*\bDROP\s+COLUMN\b'; then
  RISK_LEVEL="HIGH"; RISK_REASON="Dropping a column destroys all data in that column"
fi

# ── Infrastructure ─────────────────────────────────────────────────────────────
if echo "$COMMAND" | grep -qE 'terraform\s+destroy'; then
  RISK_LEVEL="CRITICAL"; RISK_REASON="Destroys ALL managed infrastructure resources"
elif echo "$COMMAND" | grep -qE '(kubectl\s+delete|aws\s+.*(delete|rm\s+--recursive)|gcloud\s+.+\s+delete\b)'; then
  RISK_LEVEL="HIGH"; RISK_REASON="Deletes cloud/cluster resource(s) — may affect production"
  REVERSIBLE="MAYBE"
fi

# ── Config & Secrets ───────────────────────────────────────────────────────────
if echo "$COMMAND" | grep -qE '>\s*\.env|>\s*\.env\.'; then
  RISK_LEVEL="CRITICAL"; RISK_REASON="Overwrites .env file — current secrets will be lost"
fi

[ -z "$RISK_LEVEL" ] && exit 0

# ── Output ─────────────────────────────────────────────────────────────────────
DISPLAY_CMD="${COMMAND:0:60}"
[ "${#COMMAND}" -gt 60 ] && DISPLAY_CMD="${DISPLAY_CMD}..."

echo ""
if [ "$RISK_LEVEL" = "CRITICAL" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🚨  CRITICAL — IRREVERSIBLE OPERATION BLOCKED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Command:    ${DISPLAY_CMD}"
  echo "  Risk:       ${RISK_REASON}"
  echo "  Reversible: NO — this cannot be undone"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Respond with the EXACT command to confirm you want this run."
  echo "  Example: 'Yes, run: ${DISPLAY_CMD}'"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  exit 2
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠️   HIGH RISK — DESTRUCTIVE OPERATION"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Command:    ${DISPLAY_CMD}"
  echo "  Risk:       ${RISK_REASON}"
  echo "  Reversible: ${REVERSIBLE}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  exit 0
fi
