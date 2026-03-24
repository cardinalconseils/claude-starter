---
description: "Project status overview — git, build, PRD lifecycle, and code health"
allowed-tools: Bash, Read, Glob, Grep
---

# /cks:status — Project Status Dashboard

Show a unified project status. Combines git state, build health, PRD lifecycle position, and code health.

## Steps

1. **Git Status** — Current branch, uncommitted changes, recent commits
2. **Build Health** — Can the project build? (auto-detect and run build check)
3. **PRD Lifecycle** — If `.prd/PRD-STATE.md` exists:
   - Current phase, status, last action, next action
   - Roadmap summary from `.prd/PRD-ROADMAP.md` (phases with status)
   - If no `.prd/` → show "Not initialized — run /cks:new"
4. **Code Health** — Count TODO/FIXME/HACK annotations in source
5. **Dependencies** — Any outdated or vulnerable packages? (quick check only)

## Output

```
📊 Project Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Project:  [PROJECT_NAME]
  Branch:   [branch] | [clean/dirty]
  Build:    [passing/failing/unknown]

  Lifecycle:
    Phase:  [NN] — [name] ([status])
    Last:   [last action] ([date])
    Next:   [suggested command]

  Roadmap:
    [✓] Phase 01 — feature-name (complete)
    [▶] Phase 02 — feature-name (executing)
    [ ] Phase 03 — feature-name (planned)

  Code:     [N] TODOs, [N] FIXMEs, [N] HACKs
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

1. **Read-only** — never modify anything
2. **Fast** — skip slow checks (full test suite, deep audit). Use quick heuristics.
3. **Graceful** — if a section can't be checked (no build script, no .prd/), skip it without error
