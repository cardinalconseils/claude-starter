---
description: "Show project progress and route to the next action"
allowed-tools:
  - Read
---

# /cks:progress — Show Status + Route to Next Action

Read project state and display progress. This command is read-only — it never modifies state.

## What to Read

1. `.prd/status-packet.json` — if exists, use as primary state source (schema: `tools/status-packet.md`)
2. `.prd/PRD-STATE.md` — current phase and status (fallback if no packet)
3. `.prd/PRD-ROADMAP.md` — all phases and their statuses
4. `.prd/phases/*/` — check which phases have artifacts

## What to Display

1. **Overall progress**: phases complete / total
2. **Current phase**: status and what's been done
3. **Next action**: what the logical next step is
4. **Suggested command**: which `/cks:` command to run next

## Display Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CKS Progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Project: {name}
 Active Phase: {NN} — {name} ({status})

 Roadmap:
   {NN} {name}  {status}  {✅|▶|○}
   {NN} {name}  {status}  {✅|▶|○}
   ...

 Next: {suggested action}
 Run:  {suggested command}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
