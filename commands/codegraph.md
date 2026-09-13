---
description: "Graft codebase context graph — install, init, build, check, blast, viz, or uninstall the opt-in graph that backs codebase exploration"
argument-hint: "[install|init|build|check|blast|viz|uninstall]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:codegraph — Graft context graph

Optional context graph; the roles that explore code query it before grep-and-read. Writes only
`graft/` (self-gitignored) and the `.claude/` wiring `graft init` drops in — fully reversible.
Source: https://github.com/trailhq/Graft

## Dispatch

Parse `$ARGUMENTS`; if empty ask via `AskUserQuestion`: install / init / build / check / blast / viz / uninstall.

### install

Two `▶ ACTION REQUIRED` blocks per `.claude/rules/human-intervention.md`, in order:

```
Run:    npm install -g @nanonets/graft
Why:    Installs the graft CLI and its MCP server
Then:   Run the second block
```

```
Run:    graft init --agents claude
Why:    Wires the MCP server, skill, hooks and statusline into this project and builds the graph
Then:   Restart Claude Code so the graft MCP tools load
```

### init / build / check / blast / viz
`Agent(subagent_type="cks:operator", prompt="Mode: deps — graft {sub-command}. Cwd: {cwd}. Report what it produced and the exit code; never echo raw stdout.")`

### uninstall
`⛔ DESTRUCTIVE ACTION` block per `.claude/rules/destructive-ops.md`:

```
Action:     Remove every file and config entry graft wrote in this project
Target:     graft/, .claude/skills/graft/, graft's hooks + statusline in .claude/settings.json, the graft entry in .mcp.json
Reversible: YES — re-run /cks:codegraph install + init to restore
You lose:   The local graph cache (rebuilds in seconds) and the wiring
Safer alt:  graft uninstall --keep-cache — removes the wiring, keeps the graph
```

On confirm: `Agent(subagent_type="cks:operator", prompt="Mode: deps — graft uninstall -y. Cwd: {cwd}.")`

## Quick Reference

```
/cks:codegraph install|init|build|check|blast|viz|uninstall
build rebuilds · check reports drift · blast --base origin/main is the PR radius
graft init writes nothing without a TTY — cloud, CI and routine sessions pass --agents claude --yes
DO_NOT_TRACK=1 turns off graft's anonymous telemetry (or: graft telemetry disable)
```
