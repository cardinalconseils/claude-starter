---
description: "Discover and coordinate with other Claude Code sessions via claude-peers-mcp"
argument-hint: '[setup|send|check] [message]'
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

### Setup Mode

If `$ARGUMENTS` contains `setup`:
```
Agent(subagent_type="peer-coordinator", prompt="SETUP MODE — guide the user through installing claude-peers-mcp. Read skills/peers/references/setup.md for the step-by-step guide. Walk through each step, verify success, and troubleshoot if needed.")
```

### Default Mode (status / send / check)

```
Agent(subagent_type="peer-coordinator", prompt="Peer coordination request. Action: {parsed_action}. Message: {parsed_message}. IMPORTANT: Only discover and message peers in the SAME git repository (scope=repo). Never send messages to peers in other repos — this prevents cross-contamination of codebases. If no peers are available and action is not 'setup', explain that claude-peers-mcp is not configured and offer to run setup. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:peers                 Show peers in this repo
/cks:peers setup           Install and configure claude-peers-mcp
/cks:peers send "msg"      Send a message to a peer in this repo
/cks:peers check           Check incoming messages
```
