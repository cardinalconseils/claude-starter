---
description: "Onboard GitHub webhook → Kanban automation — register webhook, set secret, verify handshake"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:setup-webhooks — GitHub Webhook Automation Setup

Onboard this project into bidirectional Kanban automation: when someone moves a
card on the GitHub Project board, a webhook tells the CKS runner what to do.

Thin dispatcher — routes to the `deployer` agent, which owns the onboarding
workflow (it surfaces `▶ ACTION REQUIRED` blocks for the steps you must run).

## Steps

1. **Parse arguments:**
   - `status` — report current webhook config (`webhook_enabled`, registered hook, last delivery)
   - `--port PORT` — console server port the webhook should target (default 4200)
   - no args — run the full onboarding flow

2. **Dispatch the deployer agent** to walk through setup:
   ```
   Agent(subagent_type="deployer",
         prompt="Onboard this project into GitHub webhook → Kanban automation.
                 Steps: (1) set webhook_enabled: true in .claude-plugin/plugin.json;
                 (2) generate a webhook secret and store it as GITHUB_WEBHOOK_SECRET;
                 (3) register a GitHub webhook on the configured repo pointing at
                 POST /webhooks/github on the console server;
                 (4) verify the handshake with a test delivery.
                 Surface ▶ ACTION REQUIRED for any step the user must run (gh / GitHub UI).
                 Args: {parsed args}")
   ```

3. **Report** the agent's result — registered hook URL, secret storage location, handshake status.

## Quick Reference

```
/cks:setup-webhooks            — Full onboarding: secret, hook registration, handshake
/cks:setup-webhooks status     — Show current webhook config and last delivery
/cks:setup-webhooks --port 4300 — Target a non-default console server port
```

## Rules

1. **Thin dispatcher** — all onboarding logic lives in the `deployer` agent
2. **Secrets stay masked** — the webhook secret is never echoed; see `.claude/rules/secrets.md`
3. **Gated off by default** — automation stays inert until `webhook_enabled: true` is set
