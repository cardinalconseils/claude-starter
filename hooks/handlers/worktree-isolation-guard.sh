#!/bin/bash
# CKS Worktree Isolation Guard — advisory PreToolUse hook on Edit/Write/MultiEdit.
# Warns when production code is edited outside a git worktree (see .claude/rules/dispatch-first.md).
# Advisory only: always exits 0, never blocks.

HOOK_INPUT=$(cat 2>/dev/null)
FILE_PATH=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

[ -z "$FILE_PATH" ] && exit 0

# Only flag target-project production code — exclude docs, state, and CKS plugin sources.
if ! echo "$FILE_PATH" | grep -qE '(^|/)(src|app|lib|packages|server|api)/'; then
  exit 0
fi

# If the edit targets a git worktree, isolation is already in place — stay silent.
FILE_DIR=$(dirname "$FILE_PATH" 2>/dev/null)
GIT_DIR=$(git -C "$FILE_DIR" rev-parse --git-dir 2>/dev/null)
case "$GIT_DIR" in
  *"/worktrees/"*) exit 0 ;;
esac

echo "💡 dispatch-first: editing production code ($FILE_PATH) outside a worktree."
echo "   Per .claude/rules/dispatch-first.md, dispatch a code-writing agent with isolation: worktree."
exit 0
