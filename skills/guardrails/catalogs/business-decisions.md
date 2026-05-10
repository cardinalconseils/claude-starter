# Business Decisions Guardrail Catalog

## Trigger

Always generated — applies to every project regardless of stack. Business decisions require human approval even in autonomous mode.

## Template

Write the following to `.claude/rules/business-decisions.md`:

```markdown
# Business Decision Rules

Some actions affect customers, revenue, or production state. They ALWAYS require explicit human approval via `AskUserQuestion` — even in autonomous mode, even with `--yes` flags, even mid-sprint.

## Gated Actions (MUST ask before proceeding)

1. **Production deploy** — any push, merge, or command that ships code to a live/prod environment (`vercel deploy --prod`, `git push prod`, `kubectl apply` against prod cluster, merging to a `main` branch with auto-deploy)
2. **Pricing or billing changes** — subscription tier edits, price changes, billing logic, Stripe product/price API calls, paywall changes
3. **External communications** — sending emails to real users, social posts, public announcements, blog posts, status page updates, transactional email template changes
4. **Destructive data operations** — deleting or migrating customer data, dropping tables in production, truncating tables, mass `UPDATE`/`DELETE` without `WHERE`
5. **Chatbot behavior changes** — modifying AI behavior facing end users (system prompts, tone, guardrails, persona, refusal rules)
6. **AI client-facing behavior** — agent logic, tool selection, or response generation that affects what clients/customers experience
7. **File or workflow removal** — deleting source files, removing GitHub Actions workflows, removing scheduled jobs, removing scripts

## Required Behavior

Before any gated action, the agent MUST output an `AskUserQuestion` block:

```
─────────────────────────────────────────────────
BUSINESS GATE — APPROVAL REQUIRED
─────────────────────────────────────────────────
Action:    [exactly what is about to happen]
Category:  [one of the 7 gates above]
Impact:    [who is affected — users, revenue, public]
Reversible: YES / NO / PARTIAL

  1. Approve and proceed
  2. Approve with modification (describe)
  3. Cancel

Reply with the number.
─────────────────────────────────────────────────
```

After the user replies:
- "Approve and proceed" → continue exactly the planned action
- "Approve with modification" → restate the modified action and re-confirm
- "Cancel" → stop and return control

## What is NOT Gated

These dev-only actions do NOT require a business gate:
- Writing tests, editing source files in a feature branch
- Running migrations against a local or dev database
- Sending emails to test inboxes (e.g., `*@example.com`, mailtrap)
- Deploying to dev or staging environments
- Editing `.claude/`, `.prd/`, or other planning artifacts

## Never

- NEVER bypass the gate because autonomous mode is on
- NEVER batch multiple gated actions under one approval — each one gets its own block
- NEVER assume past approval covers a new gated action
- NEVER expand scope beyond what the user approved
```
