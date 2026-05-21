---
name: voice
description: Voice agent scaffolding — Vapi.ai and ElevenLabs ConvAI setup patterns for CKS-managed projects, voice prompt rules, webhook bridge
allowed-tools: [Read, Write, AskUserQuestion, WebFetch]
---

# Voice — Agent Scaffolding Skill

Scaffold voice interfaces for CKS projects. Covers platform selection, system prompt rules, and the webhook bridge to the concierge.

## Platform Comparison

| Platform | Best for | Claude support | Voice quality | Complexity |
|---|---|---|---|---|
| **Vapi.ai** | Web + phone, fastest setup | Native | Good | Low |
| **ElevenLabs ConvAI** | Best voice quality | Via webhook | Excellent | Medium |
| **OpenAI Realtime** | Lowest latency | No | Good | High (server required) |
| **Retell AI** | Telephony / call centers | Via webhook | Good | Medium |

Recommended default: **Vapi.ai** — native Claude support, no server required, works in browser and phone.

## Voice System Prompt Rules

Voice agents have strict output constraints. Every system prompt for a voice-backed CKS agent must include:

```
You are a voice assistant for a software project managed by CKS.

Rules:
- Never use markdown, bullets, or numbered lists in your responses
- Maximum 2 sentences per response
- Use natural spoken language — say "the sprint phase" not "Phase 3"
- Before any destructive action, ask for verbal confirmation
- Use "pause" when the user should wait: "Checking your project status, please hold."
- If unsure what the user wants, ask one clarifying question
```

## CKS Concierge as Voice Backend

Architecture: `Voice Platform → Webhook → n8n → Claude CLI → TTS response`

```
[User speaks]
     ↓
[Voice platform (Vapi.ai)]
     ↓ POST to webhook with { transcript, call_id }
[n8n Webhook node]
     ↓
[Function node — extract transcript]
     ↓
[Execute Command node]
  command: claude --print "/cks:concierge ask '{{transcript}}' --source voice"
     ↓
[HTTP Request — POST response back to platform]
  Vapi: POST to vapi.ai/call/{call_id}/message with { message: stdout }
  ElevenLabs: POST to response URL with { text: stdout }
```

## Config Schema

Path: `.voice/config.json`

```json
{
  "platform": "vapi",
  "api_key_placeholder": "VAPI_API_KEY",
  "webhook_url": "https://{your-n8n}/webhook/cks-voice",
  "system_prompt_path": ".voice/system-prompt.txt",
  "voice_id": "alloy",
  "max_response_sentences": 2
}
```

Fields:
- `platform` — "vapi" | "elevenlabs" | "openai-realtime" | "retell"
- `api_key_placeholder` — env var name holding the real key (never the key itself)
- `webhook_url` — n8n webhook endpoint that bridges to Claude CLI
- `system_prompt_path` — path to the voice system prompt file
- `voice_id` — platform-specific voice identifier
- `max_response_sentences` — enforced by the concierge agent when source=voice

## Vapi.ai Setup Steps

1. Create account at [vapi.ai](https://vapi.ai)
2. Create Assistant → set System Prompt (copy from `.voice/system-prompt.txt`)
3. Under "Server URL" → enter n8n webhook URL
4. Under "Model" → select Claude (native) or set to custom with webhook
5. Test via Vapi dashboard "Talk" button
6. Copy API key → set `VAPI_API_KEY` env var (never commit)

## ElevenLabs ConvAI Setup Steps

1. Create account at [elevenlabs.io](https://elevenlabs.io)
2. Conversational AI → New Agent → paste system prompt
3. Set "Webhook" as LLM → point to n8n webhook
4. n8n webhook calls Claude CLI, returns text to ElevenLabs for TTS
5. Copy API key → set `ELEVENLABS_API_KEY` env var

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Markdown is fine in voice responses" | Asterisks and hyphens are read aloud literally. Plain text only. |
| "Two sentences is too limiting" | Voice users lose attention after ~15 seconds. Two sentences is a feature, not a constraint. |
| "I can commit the API key for testing" | Voice API keys grant billable usage. Treat them like credit card numbers. |
| "I'll skip the system prompt rules — it's just a demo" | Demo habits become production habits. Enforce voice rules from day one. |

## Verification

- [ ] `.voice/config.json` exists with placeholder values (no real keys)
- [ ] `.voice/system-prompt.txt` exists with voice rules applied
- [ ] n8n workflow responds to a test webhook POST within 3 seconds
- [ ] Voice platform "Test" call produces spoken output (no markdown artifacts)
- [ ] Concierge outputs max 2 sentences when `--source voice`
- [ ] No real API keys in any committed file
