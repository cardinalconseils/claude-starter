---
name: voice
description: Voice agent scaffolding — Telnyx AI Assistant + Call Control via MCP, Cloudflare Worker webhook, phone number provisioning directly from Claude
allowed-tools: [Read, Write, AskUserQuestion, mcp__claude_ai_Telnyx__invoke_api_endpoint, mcp__claude_ai_Telnyx__list_api_endpoints, mcp__claude_ai_Telnyx__get_api_endpoint_schema]
---

# Voice — Telnyx AI Assistant Scaffolding

Scaffold a Telnyx AI Assistant that lets you manage your CKS project by phone. Provisions via Telnyx MCP — no external bridge required.

## Architecture

```
Inbound call to Telnyx number
     ↓
Call Control Application
     ↓ webhook: call.initiated → call_control_id
Cloudflare Worker (~15 lines)
     ↓ POST /v2/calls/{call_control_id}/actions/ai_assistant/start
Telnyx AI Assistant
  — system prompt: CKS concierge instructions
  — model: Claude (via Telnyx LLM gateway)
  — handles STT + conversation + TTS natively
```

## What the `cks:voice-setup` Agent Provisions via MCP

1. **AI Assistant** — `create_ai_assistants` with CKS concierge system prompt
2. **Call Control Application** — `create_call_control_applications` with Cloudflare Worker URL as webhook
3. **Phone number selection** — `list_available_phone_numbers` filtered by country/region
4. **Cloudflare Worker** — scaffolded locally, deployed by user

## AI Assistant System Prompt (write to `.voice/system-prompt.txt`)

```
You are a voice assistant managing a software project built with CKS (Claude Code Starter Kit).

Rules:
- Never use markdown, bullets, headers, or numbered lists
- Maximum 2 sentences per response
- Use spoken language: say "the sprint phase" not "Phase 3"
- Confirm verbally before any destructive action
- Say "one moment please" when processing
- If unsure, ask one clarifying question

You understand these project management commands:
- "What's the status?" → summarize current phase and open tasks
- "Proceed with [phase]" → confirm and advance to next phase
- "What's left to ship?" → list open acceptance criteria
- "Start planning [feature]" → begin discovery for that feature
- "Any issues?" → report blocking problems

Keep responses conversational and brief. You are managing a real software project.
```

## Cloudflare Worker Scaffold (`.voice/worker.js`)

Deploys to Cloudflare Workers. Receives Telnyx call webhook and starts AI assistant.

```javascript
export default {
  async fetch(request, env) {
    const body = await request.json();
    const event = body?.data?.event_type;
    const callControlId = body?.data?.payload?.call_control_id;

    if (event === 'call.initiated' && callControlId) {
      await fetch(`https://api.telnyx.com/v2/calls/${callControlId}/actions/ai_assistant/start`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${env.TELNYX_API_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ assistant_id: env.TELNYX_ASSISTANT_ID })
      });
    }

    return new Response('ok');
  }
};
```

Worker env vars needed: `TELNYX_API_KEY`, `TELNYX_ASSISTANT_ID`

Deploy: `wrangler deploy` (set secrets via `wrangler secret put TELNYX_API_KEY`)

## Config Schema (`.voice/config.json`)

```json
{
  "platform": "telnyx",
  "assistant_id": "",
  "call_control_app_id": "",
  "phone_number": "",
  "worker_url": "",
  "api_key_placeholder": "TELNYX_API_KEY",
  "system_prompt_path": ".voice/system-prompt.txt"
}
```

Fields written by `cks:voice-setup` agent after provisioning via MCP.
`phone_number` and `assistant_id` are filled in after creation — no real API keys stored.

## MCP Provisioning Sequence

The `cks:voice-setup` agent runs these in order:

```
1. list_ai_assistants          → check if CKS assistant already exists
2. create_ai_assistants        → create with system prompt from .voice/system-prompt.txt
3. list_available_phone_numbers → filter by user's country, show options
4. [User selects number]
5. create_call_control_applications → webhook_event_url = Cloudflare Worker URL
6. Write .voice/config.json with assistant_id + call_control_app_id
7. Scaffold .voice/worker.js + wrangler.toml
8. Show deployment instructions
```

## Vapi.ai / ElevenLabs (fallback — no MCP)

Only if user explicitly prefers these. Setup remains manual (no MCP provisioning).
See previous version of this file for setup steps. Not recommended — Telnyx MCP is faster.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I still need n8n for the bridge" | Telnyx AI Assistant handles STT + LLM + TTS natively. Cloudflare Worker just starts it — 15 lines. |
| "The Cloudflare Worker is still an external dependency" | It's 15 lines and deploys in 30 seconds with `wrangler deploy`. Simpler than any n8n workflow. |
| "I can commit the API key for testing" | Voice API keys are billable. Use `wrangler secret put` — never commit. |
| "Markdown is fine in voice responses" | Hyphens and asterisks are read aloud literally. Plain text only. |
| "Two sentences is too limiting" | Voice users lose focus after 15 seconds. Brevity is the feature. |

## Verification

- [ ] AI assistant created — `list_ai_assistants` confirms it exists with correct system prompt
- [ ] Call Control Application created — `webhook_event_url` points to Cloudflare Worker URL
- [ ] `.voice/config.json` has `assistant_id` and `call_control_app_id` filled (no API keys)
- [ ] `.voice/system-prompt.txt` exists with voice rules
- [ ] `.voice/worker.js` exists with correct structure
- [ ] Cloudflare Worker deployed — `wrangler deploy` succeeds
- [ ] Test call: phone rings → AI assistant answers → spoken response (no markdown)
- [ ] `TELNYX_API_KEY` in Cloudflare secrets only, never committed
