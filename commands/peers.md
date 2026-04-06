---
description: "Discover and coordinate with other Claude Code sessions via claude-peers-mcp"
argument-hint: '[setup|send|check] [--repo|--all] [message]'
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:peers — Peer Coordination

Dispatch the **peer-coordinator** agent to manage cross-session communication.

## Dispatch

Parse `$ARGUMENTS`:
- No args or `status` → show peer status (list active sessions + summaries)
- `setup` → guided installation of claude-peers-mcp
- `send <message>` → send message to a peer (agent will ask which peer)
- `check` → check incoming messages

### Scope

- Default: `scope="machine"` — shows ALL sessions across all repos
- `--repo`: `scope="repo"` — only sessions in the same git repository

### Setup Mode

If `$ARGUMENTS` contains `setup`:
```
Agent(subagent_type="peer-coordinator", prompt="SETUP MODE — guide the user through installing claude-peers-mcp. Read skills/peers/references/setup.md for the step-by-step guide. Walk through each step, verify success, and troubleshoot if needed.")
```

### Default Mode (status / send / check)

```
Agent(subagent_type="peer-coordinator", prompt="Peer coordination request. Action: {parsed_action}. Scope: {machine or repo from flags}. Message: {parsed_message}. List peers across ALL repos by default (scope=machine). If --repo flag is set, use scope=repo. When sending messages, allow messaging ANY peer regardless of repo. If no peers are available and action is not 'setup', explain that claude-peers-mcp is not configured and offer to run setup. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:peers                 Show all active peers (all repos)
/cks:peers --repo          Show peers in this repo only
/cks:peers setup           Install and configure claude-peers-mcp
/cks:peers send "msg"      Send a message to any peer
/cks:peers check           Check incoming messages
```
