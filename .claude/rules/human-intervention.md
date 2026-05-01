# Human Intervention Rules

Three mandatory formats for any message requiring human attention. Use the correct format — never use plain prose for these situations.

---

## 1. Action Required

Use when the user **must** run a terminal command or perform a manual step Claude cannot do.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    [exact command or step]
Why:    [one-line reason]
Then:   [what to tell Claude or do next, or "continue"]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Triggers: interactive login (`gcloud auth login`, `gh auth login`), installing a tool, opening a URL to authenticate, copying an API key, starting a local server.

Rules:
- `Run:` field must be copy-pasteable — no placeholders like `<your-value>`
- `Then:` must tell the user exactly what to do or say next — never leave them guessing
- For multi-step sequences: one block per step, in order

---

## 2. Decision Required

Use when Claude **cannot proceed** without the user choosing an option.

```
─────────────────────────────────────────────────
❓ DECISION REQUIRED
─────────────────────────────────────────────────
[One sentence describing what needs to be decided and why it matters]

  1. [Option A] — [one-line consequence]
  2. [Option B] — [one-line consequence]
  3. [Option C] — [one-line consequence]

Reply with the number or describe what you want.
─────────────────────────────────────────────────
```

Triggers: architectural choice with real trade-offs, ambiguous user intent where guessing wrong wastes work, explicit user decision points in a lifecycle (e.g., "release or iterate?").

Rules:
- Maximum 4 options — if more exist, pre-filter to the realistic ones
- Always include a free-text escape ("describe what you want")
- Never ask for a decision that Claude can reasonably decide itself

---

## 3. Suggestion

Use for optional recommendations the user can ignore without breaking anything.

```
· · · · · · · · · · · · · · · · · · · · · · · ·
💡 SUGGESTION
· · · · · · · · · · · · · · · · · · · · · · · ·
[The suggestion, 1–3 lines]
· · · · · · · · · · · · · · · · · · · · · · · ·
```

Triggers: a next step the user might not have thought of, a better approach to what they just did, a follow-up worth scheduling.

Rules:
- Never use this format for blocking situations — use Action Required or Decision Required instead
- One suggestion per block — don't stack multiple inside a single box
- If the suggestion requires a command, include it; but it's optional, so no "Then:" field needed

---

## Visual Hierarchy Summary

| Format | Border | Emoji | Blocking? |
|--------|--------|-------|-----------|
| Destructive Action | `━━━` | ⛔ | Yes — user must confirm |
| Action Required | `━━━` | ▶ | Yes — Claude is waiting |
| Decision Required | `───` | ❓ | Yes — Claude is blocked |
| Suggestion | `· · ·` | 💡 | No — optional |

Heavy borders (`━━━`) = Claude is stopped. Light borders (`───`, `· · ·`) = Claude can continue.
