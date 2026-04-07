---
description: "Session awareness dashboard — see what all Claude Code sessions in this repo are doing, detect conflicts, send directives"
argument-hint: '[setup]'
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:peers — Session Dashboard

Dispatch the **peer-coordinator** agent to show what all sessions in this repo are working on.

## Dispatch

Parse `$ARGUMENTS`:
- No args → show dashboard (list all repo sessions, their activity, doc links, flag conflicts)
- `setup` → guided installation of claude-peers-mcp

### Setup Mode

If `$ARGUMENTS` contains `setup`:
```
Agent(subagent_type="peer-coordinator", prompt="SETUP MODE — guide the user through installing claude-peers-mcp. Read skills/peers/references/setup.md for the step-by-step guide. Walk through each step, verify success, and troubleshoot if needed.")
```

### Dashboard Mode (default)

```
Agent(subagent_type="peer-coordinator", prompt="Show the session dashboard. Use list_peers(scope='repo') ONLY. Parse each peer's auto-summary to extract activity, feature, status, and doc path. Display as a table. Flag any conflicts (two sessions on same feature). If no peers found, check if MCP is configured — if not, offer setup. Arguments: $ARGUMENTS")
```

### Directive Mode

When user says something like "tell session X to..." or "ask session X...":
```
Agent(subagent_type="peer-coordinator", prompt="The user wants to send a directive to another session. Show the dashboard first, then send the directive via send_message. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:peers                 Session dashboard — what is everyone doing?
/cks:peers setup           Install and configure claude-peers-mcp
```
