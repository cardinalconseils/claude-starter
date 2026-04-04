---
description: "Launch the CKS Kanban board — visual dashboard for your project lifecycle"
allowed-tools: Bash, Read, Glob
---

# /cks:board — Kanban Dashboard

Launch a visual Kanban board showing your project's features flowing through the 5-phase lifecycle.

## Steps

1. **Check prerequisites:**
   - Verify Node.js is available: `node --version`
   - If not available, show error: "Node.js is required for /cks:board. Install from https://nodejs.org"

2. **Find project root:**
   - Look for `.prd/` directory in the current project
   - If not found, warn the user but still launch (board will show empty state)

3. **Launch the board server:**
   ```bash
   node "${CLAUDE_PLUGIN_ROOT}/board/server.js" --project-root "$(pwd)" &
   ```
   - The server runs on port 4200 (falls back to random if taken)
   - Capture the actual port from server output

4. **Open the browser:**
   ```bash
   # macOS
   open "http://localhost:4200"
   # Linux
   xdg-open "http://localhost:4200" 2>/dev/null || echo "Open http://localhost:4200 in your browser"
   ```

5. **Report to user:**
   ```
   CKS Board is running at http://localhost:4200
   Press R in the board to refresh, or it auto-refreshes every 5 seconds.
   The board reads your .prd/ files — no database, no sync.
   To stop: close the terminal or Ctrl+C the server process.
   ```

## Quick Reference

```
/cks:board              — Launch the Kanban dashboard
```

## Rules

1. **Read-only** — the board only reads .prd/ files, never modifies them
2. **No dependencies** — uses only Node.js built-in modules
3. **Graceful** — if .prd/ doesn't exist, board shows empty state with /cks:new prompt
