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
echo "$FILE_PATH" | grep -qE '(^|/)(src|app|lib|commands|agents|skills|hooks)/' || exit 0

# A file inside a git worktree means an isolated agent is editing it — dispatch already
# happened. A subagent dispatched without worktree isolation is not detected here.
GIT_DIR=$(git -C "$(dirname "$FILE_PATH" 2>/dev/null)" rev-parse --git-dir 2>/dev/null)
case "$GIT_DIR" in *"/worktrees/"*) exit 0 ;; esac

echo "─────────────────────────────────────────────────"
echo "DISPATCH-FIRST VIOLATION"
echo "─────────────────────────────────────────────────"
echo "The orchestrator was about to edit code directly."
echo "Target: $FILE_PATH"
echo "Action: dispatch an agent instead."
echo "Suggested:"
echo "  Agent(subagent_type=\"cks:builder\", prompt=\"...\", isolation=\"worktree\")"
echo "─────────────────────────────────────────────────"
exit 2
