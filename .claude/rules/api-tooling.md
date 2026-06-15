# API Tooling Rules

## Mandatory Behavior

When `prd-discoverer` or `prd-planner` detects an external API signal in any feature description,
CONTEXT.md, or PLAN.md, it MUST surface a `💡 SUGGESTION` block prompting the user to run
`/cks:print-cli` before finalizing PLAN.md. This is a non-blocking suggestion — it does NOT
delay PLAN.md if the user dismisses it.

## Trigger Patterns

Match is case-insensitive. Any single match is sufficient.

**Generic API language**
- `third-party API`, `external API`, `REST API`, `GraphQL`, `API endpoint`
- `API key`, `API token`, `bearer token`, `webhook`

**Code signals in feature descriptions**
- `fetch(`, `axios`, `got(`, `requests.get`, `http.get`, `HttpClient`

**Named services (non-exhaustive — add as encountered)**
- `Notion`, `Linear`, `Stripe`, `Slack`, `GitHub`, `Airtable`, `HubSpot`,
  `Salesforce`, `Twilio`, `SendGrid`, `ESPN`, `OpenAI`, `Anthropic`,
  `Vercel`, `Supabase`, `Railway`, `Cloudflare`

## Required Behavior

When a trigger pattern is matched:

1. Surface this block (non-blocking — PLAN.md can proceed):

```
· · · · · · · · · · · · · · · · · · · · · · · ·
💡 SUGGESTION
· · · · · · · · · · · · · · · · · · · · · · · ·
External API detected: {matched service or pattern}
/cks:print-cli --api {service-name} generates a typed CLI + MCP + skill in one shot.
Run it now (before PLAN.md) to make the integration a designed component, not a TODO.
· · · · · · · · · · · · · · · · · · · · · · · ·
```

2. Log dismissals to `.prd/phases/{NN}/DISMISSED-API-TOOLING.md` — never re-prompt for the same service in the same phase.

3. Do NOT block PLAN.md — this is a `💡 SUGGESTION`, not a `▶ ACTION REQUIRED`.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The team will handle the API integration in the sprint" | Surfacing it now costs 5 seconds. Discovering it's missing in sprint costs hours. Suggest it. |
| "The API is simple, no CLI needed" | The user decides that — surface the suggestion and let them dismiss it. |
| "I already mentioned it in prose" | The suggestion block is the required format. Prose mentions are invisible in fast-moving sprints. |
