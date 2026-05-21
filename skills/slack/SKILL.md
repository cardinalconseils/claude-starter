---
name: slack
description: Slack app setup, incoming webhooks, slash commands, n8n bridge for triggering CKS from Slack, Slack bot configuration
allowed-tools: [Read, Write, Bash, AskUserQuestion]
---

# Slack — Integration Skill

Connects CKS to Slack via webhooks and slash commands. Two modes: notify-only (webhooks) and interactive (slash commands via n8n).

## Slack App Creation

1. Go to [api.slack.com/apps](https://api.slack.com/apps) → "Create New App" → "From Scratch"
2. Name: "CKS Bot" — workspace: select your workspace
3. **Incoming Webhooks** → activate → "Add New Webhook to Workspace" → pick channel → copy URL
4. **Slash Commands** → "Create New Command":
   - Command: `/cks`
   - Request URL: `https://{your-n8n}/webhook/cks-slash`
   - Short Description: "Talk to your CKS project"
   - Usage Hint: `ask "what's the status?"`
5. **Bot Token Scopes** (under OAuth & Permissions): `chat:write`, `commands`, `incoming-webhook`
6. Install app to workspace → copy Bot User OAuth Token

## Config Schema

Path: `.slack/config.json`

```json
{
  "webhook_url": "https://hooks.slack.com/services/YOUR/WEBHOOK/URL",
  "channel": "#dev-updates",
  "notify_on": ["SubagentStop", "Stop", "deploy", "error"],
  "bot_token": "xoxb-YOUR-BOT-TOKEN-HERE"
}
```

Fields:
- `webhook_url` — incoming webhook URL from Slack app settings
- `channel` — default notification channel (webhook ignores this, slash commands use it)
- `notify_on` — list of CKS events that trigger a notification
- `bot_token` — Bot User OAuth Token (for interactive features, not required for webhooks only)

Do NOT commit real tokens. Use placeholder values. Tokens go in environment variables.

## n8n Blueprint Structure

The n8n workflow bridges Slack slash commands to CKS:

```
[Webhook node]
  path: /webhook/cks-slash
  method: POST
  response: immediately (to avoid Slack timeout)
    ↓
[Function node — parse slash text]
  const text = $json.body.text || '';
  const responseUrl = $json.body.response_url;
  return [{ json: { text, responseUrl } }];
    ↓
[Execute Command node]
  command: claude --print "/cks:concierge ask '{{$json.text}}' --source slack"
  (captures stdout)
    ↓
[HTTP Request node — POST to Slack response_url]
  URL: {{$json.responseUrl}}
  method: POST
  body: { "text": "{{$node['Execute Command'].json.stdout}}" }
```

Save blueprint as `.slack/n8n-blueprint.json` for import into n8n.

## Slack Response Format Rules

All CKS responses sent to Slack must follow:
- Plain text only — no markdown, no `*bold*`, no backtick code blocks
- Max 3 sentences per response
- No bullet lists — convert to comma-separated or prose
- Start with the most important information
- End with a clear next step if one exists

Example (bad): `**Status:** Sprint phase — 4/7 tasks done\n- Fix auth bug\n- Add tests`
Example (good): `Sprint phase, 4 of 7 tasks done. Next: fix auth bug. Reply with /cks proceed to continue.`

## notify_on Events

| Event | When it fires | Example message |
|---|---|---|
| `SubagentStop` | Any agent finishes | "CKS [sprint] on [main] — agent complete" |
| `Stop` | Session ends | "CKS [sprint] on [main] — session stopped" |
| `deploy` | Deployment completes | "CKS [release] on [main] — deployed" |
| `error` | Agent error or failed gate | "CKS [sprint] on [main] — error: build failed" |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Markdown looks fine in Slack" | Block Kit and most Slack clients render `*text*` as literal asterisks in webhook payloads. Use plain text. |
| "I'll commit the real webhook URL for now" | Webhook URLs grant write access to your Slack workspace. Treat them like passwords. |
| "The n8n timeout won't be an issue" | Slack requires a response within 3 seconds. n8n webhook must respond immediately; use response_url for the actual reply. |
| "I can skip the bot token if I have webhooks" | Webhooks are one-way. Interactive slash commands need a bot token or response_url. Plan which mode you need. |

## Verification

- [ ] `.slack/config.json` exists with placeholder values (no real tokens committed)
- [ ] Webhook URL responds to a test POST with a Slack message
- [ ] Slash command `/cks status` returns a plain-text response in under 3 seconds
- [ ] n8n blueprint imported and webhook node active
- [ ] `notify_on` events tested: send a test message to channel
- [ ] No real tokens in any committed file
