---
description: "Slack integration — setup notifications and bot slash commands for CKS"
argument-hint: "[setup|notify|bot|status]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:slack — Slack Integration

Connect CKS to Slack. Notification webhooks or interactive slash commands via n8n.

## Arguments

| Arg | Action |
|---|---|
| `setup` | Run full setup wizard — creates `.slack/config.json` and n8n blueprint |
| `notify` | Send a test notification to your configured webhook |
| `bot` | Generate n8n blueprint for slash command support |
| `status` | Show current `.slack/config.json` (masked webhook URL) |
| (no args) | Run setup wizard |

## Dispatch

```
Agent(
  subagent_type="cks:slack-integrator",
  prompt="
    SUBCOMMAND: {$ARGUMENTS or 'setup'}
  "
)
```

## Quick Reference

```
/cks:slack setup        — configure webhook + n8n blueprint
/cks:slack notify       — test: send message to Slack channel
/cks:slack bot          — generate n8n blueprint for /cks slash command
/cks:slack status       — show config (tokens masked)
```
