---
description: "Export board state (features, sessions, notes, activity) as a committed markdown summary"
allowed-tools: Bash, Read, Glob, Write
---

# /cks:board-export — Export Board State to Repo

Dumps the current CKS Board state into a markdown summary committed to the repo. This captures everything visible in the board UI into version-controlled files.

## Steps

1. **Check if board server is running:**
   - Try `curl -s http://localhost:4200/api/projects` (with token if needed)
   - If not reachable, read directly from `.prd/` files instead

2. **Export features and state:**
   - Read features from `/api/features?projectId=N` or from `.prd/phases/`
   - Write `.prd/BOARD-EXPORT.md` with:
     - Project name and export date
     - Feature table: name, phase, status, artifacts, next action
     - Activity timeline (last 20 events from lifecycle.jsonl)
     - Any board chat notes per feature

3. **Export session transcripts:**
   - Check `.prd/logs/sessions/` for any transcript files
   - List them in the export summary

4. **Export chat notes per feature:**
   - If board is running, call `POST /api/export-notes` for each feature with chat messages
   - This writes BOARD-NOTES.md into each feature's phase directory

5. **Report:**
   ```
   Exported board state to .prd/BOARD-EXPORT.md
   - N features documented
   - N session transcripts found
   - N features with board notes
   ```

## Quick Reference

```
/cks:board-export       — Export full board state to repo
```

## Rules

1. **Additive** — never delete existing files, only create/update export files
2. **Idempotent** — safe to run multiple times
3. **Works offline** — if board server isn't running, reads from .prd/ files directly
