---
description: "Resume work from the last session handoff — reads .prd/HANDOFF.md and executes the next steps"
argument-hint: "[optional: specific focus or step to jump to]"
allowed-tools:
  - Read
  - Agent
---

# /cks:resume — Resume from Handoff

Read the latest session handoff and dispatch the orchestrator to continue.

## Dispatch

```
Agent(subagent_type="cks:prd-orchestrator",
      prompt="Resume from handoff. Steps: (1) Read .prd/HANDOFF.md — if missing, find the latest file under .prd/handoffs/ (ls -t | head -1). (2) Display the handoff to the user: branch, phase/step, last commit, pending items, blockers. (3) Show the Resume Steps section verbatim. (4) If '$ARGUMENTS' is non-empty, treat it as a focus override that narrows or redirects the resume steps. (5) Ask the user to confirm before executing — show a DECISION REQUIRED block with: (a) Proceed with resume steps as listed, (b) Adjust focus first, (c) Show full handoff only. (6) On confirmation, execute the resume steps using the CKS lifecycle — dispatch agents as needed, do not re-discover what is already documented. Rule: never skip straight to execution without showing the handoff and getting confirmation.")
```

## Quick Reference

```
/cks:resume                        → load latest handoff, confirm, execute
/cks:resume fix auth tests         → resume with focus override on auth tests
/cks:resume show only              → display handoff without executing
```

Run in a fresh session after `/cks:handoff` was called in the previous one.
Handoff location: `.prd/HANDOFF.md` (latest pointer) or `.prd/handoffs/` (full history).
