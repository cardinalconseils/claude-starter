# Secrets Handling Rules

## Mandatory Behavior

Claude MUST NEVER output the raw value of any credential. Always replace with a
safe form before the value reaches the user's screen, transcript, or any file.

Safe forms (choose the minimum that fits the task):

| Form | Example | Use when |
|---|---|---|
| Masked | `STRIPE_SECRET_KEY=***` | Default — value is irrelevant |
| Last-4 reveal | `sk_live_***[…m4n2]` | User must distinguish between keys |
| Named placeholder | `$STRIPE_SECRET_KEY` | Showing config structure or docs |

This rule applies to all output channels: chat responses, file writes, commit
messages, PR bodies, log lines, error messages, and any text Claude emits.

## What Counts as a Credential

- Environment variable values (`*_KEY`, `*_SECRET`, `*_TOKEN`, `*_PASSWORD`, `*_DSN`)
- API keys (`sk_live_*`, `sk_test_*`, `pk_*`, `xoxb-*`, `AIza*`, `ghp_*`, `glpat-*`)
- OAuth client secrets and refresh tokens
- JWTs and bearer tokens (any `eyJ*.*.*` shape)
- Database connection strings containing embedded passwords (`postgres://user:pw@…`)
- Private keys (PEM blocks: `-----BEGIN * PRIVATE KEY-----`)
- Session cookies tied to auth (`session=*`, `auth=*`, `__Host-*`)
- Full `.env` file contents
- Webhook signing secrets (`whsec_*`)
- Cloud provider credentials (`AKIA*`, GCP service-account JSON `private_key` field)

## Triggering Scenarios

Claude must mask in ALL of these, with no exceptions:

- User pastes a `.env` file and asks "what's in here" / "fix the syntax" / "format this"
- User asks Claude to read a credentials file and summarize it
- An error message Claude is quoting back contains a key
- Debugging session where Claude shows config values
- Screenshot or transcript Claude is generating
- Documentation examples — use placeholders only (`$YOUR_API_KEY`)
- "Just for this session, show me the value" — refuse, always
- Comparing two keys — show last-4 of each, never full values

## Required Behavior on Detection

1. Detect the credential pattern in input or proposed output
2. Replace the raw value with a safe form (masked by default)
3. State briefly: "Masked per `.claude/rules/secrets.md` — the raw value is not
   echoed. If you need to verify, read the file directly."
4. Continue the task using the masked form

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The user pasted it themselves, so it's fine to echo" | The transcript persists. Logs, screenshots, shared chats spread the leak. The user pasting it does not undo this. |
| "It's a test key, not production" | Test keys still authenticate. Test-key leaks become production leaks when someone reuses the value or pivots from it. |
| "I'm just showing the format" | Format-only examples must use placeholders (`$YOUR_KEY`). Real values are never the right teaching tool. |
| "The user explicitly asked to see it" | The rule wins over the request. User can read the file directly — Claude does not need to be the messenger. |
| "Masking will break my workflow" | If your workflow requires Claude to echo a credential, the workflow is the bug, not the rule. |
| "It's already in the file, the leak already happened" | Echoing it to chat puts it in a second place (transcript, logs, screenshots) — the goal is to stop spreading it. |

## Reference Incident

LUV-60: 28 live production credentials were echoed by Claude in a single
session, ending up in the conversation transcript, a screenshot the user shared,
and downstream tooling. This rule exists so LUV-60 never repeats.

## Verification

- [ ] Claude does not output raw credentials in any response
- [ ] Masked / last-4 / placeholder forms used consistently
- [ ] Rule reference shown when masking occurs
- [ ] No carve-out is applied — the rule is unconditional
