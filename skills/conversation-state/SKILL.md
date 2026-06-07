---
name: conversation-state
description: Persists the live conversation thread per user so an always-on session resumes mid-thread after a restart — running summary, recent turns, active work, and any pending clarification awaiting the user's next reply
allowed-tools: [Read, Write, Bash, Glob, Grep]
---

# Conversation State — Resumable Threads

Keeps the *live* thread on disk so a restarted session (VPS redeploy, crash, channel
reconnect) picks up exactly where it left off. Distinct from `user-memory` (durable
long-term facts/preferences): conversation-state is the in-flight thread and is allowed
to churn.

## Location

`~/.cks/user/<user_slug>/conversation-state.json` — under the per-user directory, so the
`user-memory-guard` hook already confines access. `<user_slug>` is `CKS_ACTIVE_USER`
(trusted sender ID; `local` for fakechat/cli).

## Schema

```json
{
  "user_slug": "local",
  "source": "telegram",
  "thread_summary": "Helping set up the Telegram bot; decided on VPS host.",
  "recent_turns": [
    {"role": "user",  "text": "how do I add the bot?", "ts": "2026-06-07T19:40:00Z"},
    {"role": "agent", "text": "Create it with BotFather, then …",  "ts": "2026-06-07T19:40:05Z"}
  ],
  "active_feature": "telegram-setup",
  "active_phase": null,
  "pending": {
    "type": "clarify",
    "question": "Single-user or shared bot?",
    "options": ["single", "shared"],
    "asked_ts": "2026-06-07T19:41:00Z"
  },
  "last_updated": "2026-06-07T19:41:00Z"
}
```

`pending` is `null` when nothing is awaiting an answer. `recent_turns` is capped (keep the
last ~10); older context lives in `thread_summary`, a short running paragraph.

## Protocol

**On each inbound message (after resolving `$USER_SLUG`):**
1. Read this user's `conversation-state.json` (absent file → fresh thread).
2. If `pending` is set, interpret the message as the **answer** to that question — this is
   what makes a clarification survive a restart. Resolve it, then clear `pending`.
3. Otherwise rehydrate `thread_summary` + `recent_turns` as context for the reply.

**After replying:**
4. Append the user message and the agent reply to `recent_turns`; trim to the last ~10.
5. Refresh `thread_summary` when the thread shifts topic or `recent_turns` is trimmed —
   keep it one short paragraph.
6. Set `pending` if you just asked a Clarify (through the channel), or clear it if resolved.
7. Update `active_feature` / `active_phase` and `last_updated`. Write the file
   (`mkdir -p` the user dir first).

**On restart:** nothing special — state is on disk, so the next inbound message rehydrates
it. That is the entire point.

## Relationship to Other State

| State | Holds | Lifetime |
|---|---|---|
| `conversation-state.json` | the live thread + pending question | resumable, churns |
| `user-memory` (`profile/facts/history`) | durable facts & preferences | permanent, append-only |
| `.cks/concierge-state.json` | last intent/dispatch (per project) | per project |

At the end of a conversation, distil it into a `history.md` digest (`user-memory`) and let
`conversation-state` reset for the next thread.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Keep the whole transcript in recent_turns" | It bloats the file and the context. Cap at ~10 turns; summarize the rest. |
| "Pending questions live in session memory" | A restart wipes session memory. Persist `pending` or the thread breaks mid-question. |
| "Conversation-state and user-memory are the same thing" | One is the live thread (churns), the other is durable facts. Mixing them loses both. |
| "Skip the summary, the turns are enough" | After trimming, the turns alone lose earlier context. The running summary is the memory of what scrolled off. |

## Verification

- [ ] State stored at `~/.cks/user/<slug>/conversation-state.json` (under the guarded dir)
- [ ] On inbound, `pending` is checked first and resolved before reclassifying
- [ ] `recent_turns` capped (~10); `thread_summary` kept current and short
- [ ] `pending` set when a Clarify is asked, cleared when answered
- [ ] File written after each turn; survives and rehydrates across a restart
