---
description: "Restrict file edits to a specific directory for this session"
allowed-tools:
  - AskUserQuestion
  - Bash
---

# /cks:freeze

Set a freeze boundary so edits outside the chosen directory are blocked.

## Steps

1. Ask the user for the directory to freeze to.
2. Resolve the path to absolute.
3. Write it to `.cks/freeze-dir.txt`.
4. Confirm activation.

## Instructions

Ask the user:

```
AskUserQuestion(
  question: "Which directory should be the freeze boundary? (All edits outside this path will be blocked)",
  options: ["Enter a path below", "Cancel"]
)
```

If the user provides a path:

```bash
mkdir -p .cks
FREEZE_PATH=$(cd "$(eval echo "$USER_PATH")" 2>/dev/null && pwd) || FREEZE_PATH=$(eval echo "$USER_PATH")
echo "$FREEZE_PATH" > .cks/freeze-dir.txt
echo "Freeze boundary set: $FREEZE_PATH"
```

Confirm with:

```
Freeze active. Edits outside `{path}` will be blocked by the PreToolUse hook.
Run /cks:unfreeze to remove the boundary.
```

## Quick Reference

```
/cks:freeze    — prompts for directory, activates boundary
/cks:unfreeze  — removes the active boundary
```
