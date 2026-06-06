---
description: "Remove the active freeze boundary"
allowed-tools:
  - Bash
---

# /cks:unfreeze

Remove the active freeze boundary so edits are no longer restricted.

## Steps

Run:

```bash
if [ -f .cks/freeze-dir.txt ]; then
  FREEZE_PATH=$(cat .cks/freeze-dir.txt)
  rm .cks/freeze-dir.txt
  echo "Freeze boundary removed: $FREEZE_PATH"
else
  echo "No freeze boundary is active."
fi
```

Report the result to the user.

## Quick Reference

```
/cks:unfreeze  — removes the active freeze boundary
/cks:freeze    — set a new boundary
```
