---
description: "Voice agent setup — scaffold Vapi.ai or ElevenLabs ConvAI to talk to the CKS concierge"
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
/cks:voice setup        — configure Vapi.ai or ElevenLabs + n8n bridge
/cks:voice status       — show current voice config
```

## How It Works

```
You speak → Voice platform → n8n webhook → Claude CLI (/cks:concierge) → spoken response
```

Supported platforms: Vapi.ai, ElevenLabs ConvAI, OpenAI Realtime, Retell AI.
