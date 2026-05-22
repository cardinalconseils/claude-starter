---
description: "Voice agent setup — provision a Telnyx AI Assistant + Cloudflare Worker to talk to the CKS concierge by phone"
argument-hint: "[setup|status]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:voice — Voice Agent Setup

Scaffold a voice interface for your CKS project. Talk to it instead of typing.

## Arguments

| Arg | Action |
|---|---|
| `setup` | Run setup wizard — pick platform, write config, generate system prompt |
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
/cks:voice setup        — provision Telnyx AI Assistant + Cloudflare Worker (9-step wizard)
/cks:voice status       — show current voice config
```

## How It Works

```
You call the number → Cloudflare Worker → start_ai_assistant_calls_actions →
Telnyx handles STT + Claude LLM + TTS natively. Zero n8n.
```
