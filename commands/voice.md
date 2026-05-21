---
description: "Voice agent setup — provision a Telnyx AI Assistant via MCP to manage your CKS project by phone"
argument-hint: "[setup|status]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:voice — Voice Agent Setup

Scaffold a Telnyx AI Assistant for your CKS project. Manage it by phone instead of typing.

## Arguments

| Arg | Action |
|---|---|
| `setup` | Run setup wizard — provision AI Assistant + Call Control App + phone number, scaffold Cloudflare Worker |
| `status` | Show current `.voice/config.json` (API keys masked) |
| (no args) | Run setup wizard |

## Dispatch

```
Agent(
  subagent_type="cks:voice-setup",
  prompt="
    SUBCOMMAND: {$ARGUMENTS or 'setup'}
  "
)
```

## Quick Reference

```
/cks:voice setup        — provision Telnyx AI Assistant + phone number via MCP
/cks:voice status       — show current voice config
```

## How It Works

```
Inbound call → Telnyx number → Call Control App → Cloudflare Worker → Telnyx AI Assistant → spoken response
```

Platform: Telnyx AI Assistant (provisioned directly via Telnyx MCP — no external bridge).
