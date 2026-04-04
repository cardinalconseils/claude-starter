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

2. **Ensure dependencies are installed:**
   ```bash
   cd "${CLAUDE_PLUGIN_ROOT}/board" && [ -d node_modules/sql.js ] || npm install --no-fund --no-audit 2>&1
   ```
   - If npm install fails, show the error and suggest running it manually

3. **Parse arguments:**
   - `--lan` — Bind to 0.0.0.0 for local network access
   - `--tunnel` — Start a Cloudflare Tunnel for remote internet access
   - Pass any flags through to the server command

4. **Launch the board server** using Bash with `run_in_background: true`:
   ```bash
   node "${CLAUDE_PLUGIN_ROOT}/board/server.js" --project-root "$(pwd)" [--lan] [--tunnel]
   ```

5. **Open the browser:**
   ```bash
   # macOS
   open "http://localhost:4200"
   # Linux
   xdg-open "http://localhost:4200" 2>/dev/null || echo "Open http://localhost:4200 in your browser"
   ```

6. **Report to user:**
   ```
   CKS Board is running at http://localhost:4200
   Press R in the board to refresh, or it auto-refreshes via live file watching.
   The board reads your .prd/ files — no database sync needed.
   To stop: close the terminal or Ctrl+C the server process.
   ```

## Quick Reference

```
/cks:board              — Launch the Kanban dashboard
/cks:board --lan        — Accessible on local network (0.0.0.0)
/cks:board --tunnel     — Accessible via Cloudflare Tunnel (internet)
```

## Rules

1. **Read-only** — the board only reads .prd/ files, never modifies them
2. **Auto-install** — dependencies (sql.js) are installed automatically if missing
3. **Graceful** — if .prd/ doesn't exist, board shows empty state with /cks:new prompt
