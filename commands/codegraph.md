---
description: "CodeGraph MCP — install, init, index, status, upgrade, or uninstall the opt-in codebase knowledge graph (~47% fewer tokens on exploration)"
argument-hint: "[install|init|index|status|upgrade|uninstall]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:codegraph — CodeGraph MCP

Opt-in codebase knowledge graph. Cuts ~47% tokens and ~58% tool calls on exploration. Writes only to `.codegraph/` — fully reversible.

## Dispatch

Parse `$ARGUMENTS`. If empty, ask via `AskUserQuestion` with options: install / init / index / status / upgrade / uninstall.

### install

Output `▶ ACTION REQUIRED` block per `.claude/rules/human-intervention.md`:

```
Run:    npx codegraph install
Why:    Installs CodeGraph CLI and wires MCP server into Claude Code config
Then:   Run /cks:codegraph init to index this project
```

Source: https://github.com/colbymchenry/codegraph

### init / index / status / upgrade

```
Agent(
  subagent_type="cks:go-runner",
  prompt="Run: codegraph {sub-command}. Working directory: {cwd}. Report output and exit code."
)
```

### uninstall

Output `⛔ DESTRUCTIVE ACTION` block per `.claude/rules/destructive-ops.md`:

```
Action:     Remove CodeGraph MCP wiring and delete .codegraph/ index
Target:     .codegraph/ + MCP entry in Claude Code config
Reversible: YES — re-run /cks:codegraph install + init to restore
You lose:   Cached index (rebuilds in ~1 min on re-init)
Safer alt:  none — this is already the reversible path
```

After user confirms: `Agent(subagent_type="cks:go-runner", prompt="Run: codegraph uninstall. Cwd: {cwd}.")`

## Quick Reference

```
/cks:codegraph install    Wire MCP (user runs the npx command)
/cks:codegraph init       Initialize and index this project
/cks:codegraph status     Check MCP wiring and index health
/cks:codegraph uninstall  Remove MCP + .codegraph/ (reversible)
```
