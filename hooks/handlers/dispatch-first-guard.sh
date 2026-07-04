#!/bin/bash
# CKS Dispatch-First Guard — blocks Edit/Write/MultiEdit on protected CKS-layer paths
# (commands/agents/skills/hooks/src/app/lib) when done directly in the main working
# tree during an active .prd/ lifecycle. See .claude/rules/dispatch-first.md.

HOOK_INPUT=$(cat 2>/dev/null)
FILE_PATH=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

# Fail open when no CKS lifecycle is active — this plugin ships to non-CKS projects too.
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
[ -z "$REPO_ROOT" ] && exit 0
[ ! -d "$REPO_ROOT/.prd" ] && exit 0

if ! echo "$FILE_PATH" | grep -qE '(^|/)(src|app|lib|commands|agents|skills|hooks)/'; then
  exit 0
fi

# Proxy signal (reused from worktree-isolation-guard.sh): a file inside a git worktree
# means an isolated agent is editing it — dispatch already happened. This does NOT
# detect a subagent dispatched without worktree isolation — that's a separate,
# already-documented requirement (see dispatch-first.md "Worktree Requirement").
FILE_DIR=$(dirname "$FILE_PATH" 2>/dev/null)
GIT_DIR=$(git -C "$FILE_DIR" rev-parse --git-dir 2>/dev/null)
case "$GIT_DIR" in
  *"/worktrees/"*) exit 0 ;;
esac

SUGGESTED_AGENT="cks:prd-executor"
echo "─────────────────────────────────────────────────"
echo "DISPATCH-FIRST VIOLATION"
echo "─────────────────────────────────────────────────"
echo "The orchestrator was about to edit code directly."
echo "Target: $FILE_PATH"
echo "Action: dispatch an agent instead."
echo ""
echo "Suggested:"
echo "  Agent(subagent_type=\"$SUGGESTED_AGENT\","
echo "        prompt=\"...\","
echo "        isolation=\"worktree\")"
echo "─────────────────────────────────────────────────"
exit 2
