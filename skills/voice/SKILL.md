---
name: voice
description: Voice agent scaffolding — Telnyx phone number and WebRTC widget as primary platform, Vapi.ai and ElevenLabs as alternatives, TeXML + n8n webhook bridge to CKS concierge
allowed-tools: [Read, Write, AskUserQuestion, WebFetch]
---

# Voice — Agent Scaffolding Skill

Scaffold voice interfaces for CKS projects. Covers platform selection, system prompt rules, and the webhook bridge to the concierge.

## Platform Comparison

| Platform | Best for | Claude support | Voice quality | Complexity |
|---|---|---|---|---|
| **Telnyx (phone number)** | Phone calls to manage project | Via webhook | Good | Low |
| **Telnyx (WebRTC widget)** | Browser-based, embed in web app | Via webhook | Good | Low |
| **Vapi.ai** | Web + phone, native Claude | Native | Good | Low |
| **ElevenLabs ConvAI** | Best voice quality | Via webhook | Excellent | Medium |

Recommended default: **Telnyx** — MCP tools available, real phone number, works for calls and browser widget.

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

## Telnyx Architecture

```
Phone call / Widget
     ↓
Telnyx (transcription via TeXML <Gather> or AI Gateway)
     ↓ POST webhook with { From, CallControlId, transcript }
n8n Webhook node
     ↓
Execute Command: claude --print "/cks:concierge ask '{transcript}' --source voice"
     ↓
Telnyx API: POST /calls/{call_control_id}/actions/speak  (TTS the response)
```

## Telnyx Phone Number Setup Steps

1. Sign up at telnyx.com → Mission Control Portal
2. Buy a phone number → Numbers → Search & Buy
3. Create a TeXML Application → Voice → TeXML Apps → New App
4. Set "Voice URL" to your n8n webhook endpoint
5. Assign phone number to the TeXML App
6. TeXML to gather speech and forward transcript:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Gather input="speech" action="{n8n-webhook-url}" method="POST" speechTimeout="2">
    <Say>Welcome to your CKS project assistant. How can I help?</Say>
  </Gather>
</Response>
```
7. n8n receives POST with `SpeechResult` field → calls Claude CLI → POSTs back to Telnyx `/v2/calls/{CallControlId}/actions/speak`
8. Set `TELNYX_API_KEY` env var (never commit)

## Telnyx WebRTC Widget Setup Steps

1. Mission Control → Voice → WebRTC → Create Credential (username/password)
2. Embed the Telnyx WebRTC JS SDK in the target web app
3. Widget connects to Telnyx → audio streams to Telnyx → webhook fires on transcription
4. Same n8n bridge as phone setup

## Telnyx n8n Nodes for the Bridge

- Webhook node: receives `SpeechResult` (TeXML) or transcript (AI Gateway)
- Function node: extract transcript from `$json.body.SpeechResult`
- Execute Command: `claude --print "/cks:concierge ask '{{$json.transcript}}' --source voice"`
- HTTP Request node: POST to `https://api.telnyx.com/v2/calls/{{$json.CallControlId}}/actions/speak` with `{ payload: "{{stdout}}", voice: "female" }`, header `Authorization: Bearer $TELNYX_API_KEY`

## Config Schema

Path: `.voice/config.json`

```json
{
  "platform": "telnyx",
  "mode": "phone",
  "api_key_placeholder": "TELNYX_API_KEY",
  "phone_number": "+1XXXXXXXXXX",
  "webhook_url": "https://{your-n8n}/webhook/cks-voice",
  "textml_app_id": "",
  "system_prompt_path": ".voice/system-prompt.txt",
  "voice": "female",
  "max_response_sentences": 2
}
```

Fields:
- `platform` — "telnyx" | "vapi" | "elevenlabs"
- `mode` — "phone" | "widget" (Telnyx only)
- `api_key_placeholder` — env var name holding the real key (never the key itself)
- `phone_number` — purchased Telnyx number (placeholder only, no real number committed)
- `webhook_url` — n8n webhook endpoint that bridges to Claude CLI
- `textml_app_id` — Telnyx TeXML App ID (from Mission Control)
- `system_prompt_path` — path to the voice system prompt file
- `voice` — "female" | "male" (Telnyx TTS)
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
| "I can use Telnyx without n8n — just call the API directly" | TeXML requires a URL that returns XML synchronously. n8n is the simplest bridge. |

## Verification

- [ ] Telnyx phone number purchased and assigned to TeXML App
- [ ] TeXML App "Voice URL" points to n8n webhook
- [ ] n8n webhook responds with Telnyx speak API call within 3s
- [ ] Test call to the phone number produces spoken CKS response
- [ ] `TELNYX_API_KEY` set as env var, not committed
- [ ] `.voice/config.json` exists with placeholder values (no real keys)
- [ ] `.voice/system-prompt.txt` exists with voice rules applied
- [ ] Concierge outputs max 2 sentences when `--source voice`
- [ ] No real API keys in any committed file
