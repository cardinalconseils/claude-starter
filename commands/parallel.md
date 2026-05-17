---
description: "Generate a tmux C.W.A.S. parallel workspace — Controller + N Workers from PLAN.md or a goal string"
argument-hint: "[--from-plan | \"goal string\"]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:parallel — Tmux Parallel Workspace Generator

Generate a tmux C.W.A.S. (Controller → Workers → Artifacts → Synthesis) workspace.
Reads the active PLAN.md (`--from-plan`) or decomposes a bare goal into 4–6 Workers.
Agent writes `.cks/parallel/YYYYMMDD-HHMMSS/` then prints the `bash launch.sh` instruction — never executes it.

## Argument Parsing

`$ARGUMENTS` format: `[--from-plan | "goal string"]`

- `--from-plan` → deterministic: reads active phase PLAN.md, maps each step to a Worker
- `"goal string"` → non-deterministic: agent decomposes goal into 4–6 Workers (labeled as best-effort)
- `--help` or `help` → print Quick Reference and stop (no agent dispatch)
- No arguments → show Quick Reference and stop

## Dispatch

Parse `$ARGUMENTS`:

1. If empty or `--help` or `help`, print the Quick Reference block below and stop.
2. Otherwise dispatch:

```
Agent(subagent_type="cks:parallel-launcher",
      prompt="Run /cks:parallel. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:parallel --from-plan             Deterministic: reads active phase PLAN.md
/cks:parallel "build auth flow"       Non-deterministic: decomposes goal into 4-6 workers
/cks:parallel --help                  Show this help

Output: .cks/parallel/YYYYMMDD-HHMMSS/
  launch.sh        Executable tmux script (run manually from your terminal)
  CLAUDE.md        Controller system prompt (opus)
  tasks/worker-XX.md   Per-worker brief (sonnet)
  src/interfaces.md    Shared shapes/contracts

Requirements: tmux installed (brew install tmux | apt install tmux)
Note: Run launch.sh from your terminal, NOT from inside Claude Code.
```
