---
name: proactive-brain
description: Lets the always-on conversational agent initiate messages — on a scheduled wake it scans the active user's blockers, due reminders, and stale clarifications, then pushes a short nudge out through the channel reply tool instead of waiting to be asked
allowed-tools: [Read, Write, Bash, Glob, Grep, CronCreate]
---

# Proactive Brain — Push, Don't Only Reply

The reactive brain (`channel-brain`) answers when messaged. The proactive brain wakes on
a schedule and **starts** a message when something is worth surfacing — a blocker, a due
reminder, or a clarification the user left hanging. This is gap #4 in `docs/hermes-mode.md`
(Hermes Mode P5): the difference between a command parser and an assistant that watches
your back.

## How a Wake Arrives

A `CronCreate` schedule re-enters the always-on top-level session with a proactive-wake
prompt (not a `<channel>` event). The session is already the concierge brain
(`channel-brain` is loaded). On wake, run the scan loop below instead of the per-message
loop. Register the schedule with the existing `cks:scheduler` agent or `CronCreate`
directly — see "Registering the Wake".

## Isolation: one wake = one user

`user-memory-guard` confines the session to `$CKS_ACTIVE_USER` and **blocks enumerating
sibling user directories** — by design. So a single wake scans exactly **one** user: the
one `CKS_ACTIVE_USER` is set to. Do not try to loop over all users from one session; the
guard will (correctly) block it. For a shared multi-user bot, register **one wake per
user**, each launched with that user's `CKS_ACTIVE_USER`, or run a per-user session. This
is the same isolation-strength trade-off recorded in `skills/user-memory` and the Hermes
roadmap — proactive does not relax it.

## Scan Loop (on each scheduled wake)

1. **Resolve the user.** `$USER_SLUG = $CKS_ACTIVE_USER` (`local` if unset). Never from
   text. All reads/writes stay under `~/.cks/user/$USER_SLUG/`.
2. **Load context.** Read the user's `conversation-state.json` (`conversation-state`
   skill), `.prd/PRD-STATE.md` if the active project has one, and grep the user's
   `reminders.md` (below) for anything now due.
3. **Collect push-worthy signals** (only these — see "What Is Worth Interrupting"):
   - a **due reminder** (`reminders.md` line whose due time has passed)
   - a **blocker**: `phase_status` blocked/failed in PRD-STATE, or an open RAID blocker
   - a **stale pending clarification**: `conversation-state.pending` older than the
     stale threshold (default 12h) — the user never answered; nudge once
   - a **completed handoff while away**: a sprint/phase finished since the last turn
4. **Dedup against `last_proactive`.** Hash the top signal (type + subject). If it equals
   `conversation-state.last_proactive.signal` and the underlying state has not changed,
   **stay silent** — never re-nag the same thing.
5. **Respect quiet hours.** If now is inside the user's quiet window (default 22:00–08:00
   local, overridable in `profile.md`), defer non-urgent pushes to the next wake. A hard
   blocker may still go out — judgment call, kept rare.
6. **If a signal survives 4–5, push it.** Compose one short message in the user's source
   format (telegram/imessage rules in `concierge`), send it via the channel `reply` tool
   addressed to this user's chat. If the push asks a question, set
   `conversation-state.pending` so the user's next reply resumes the thread (P3) — do
   **not** use `AskUserQuestion` (it stalls an unattended session; same rule as
   `channel-brain`).
7. **Record it.** Set `conversation-state.last_proactive = {signal, ts}`, append the
   push to `recent_turns`, mark a fired reminder done (`~~struck~~` or a `fired:` prefix),
   and write the file. Silence is also a valid outcome — most wakes push nothing.

## What Is Worth Interrupting

Interrupting a human has a cost. Push only when the user would thank you for it.

| Push | Don't push |
|---|---|
| A reminder the user explicitly set is due | "Still here if you need me" / idle chatter |
| Their active sprint is blocked or failed | Routine progress that needs no decision |
| A clarification they left hanging (once) | A second nudge for the same unanswered thing |
| A long-running build they kicked off finished | Anything already pushed and unchanged |

The bar: a real change in *their* world that needs *their* attention. When unsure, stay
silent — a missed nudge is cheaper than a spammy bot.

## Reminders

A user can ask the agent to remind them ("remind me tomorrow 9am to deploy"). Store each
as an append-only line under the user's guarded dir:

```
~/.cks/user/<user_slug>/reminders.md
## [2026-06-08T09:00:00Z] deploy the telegram bot
```

On wake, grep for lines whose ISO due time is `<= now`, push them, then mark them fired
(prefix `fired:` so they are not re-pushed). Append-only; never echo secrets from a
reminder (`.claude/rules/secrets.md`).

**Setting a reminder (the `/cks:remind` / `cks:reminder` path).** Parse `<when>` to an ISO
due time (`date -d`), append `## [due] text` to the user's `reminders.md`, then run the
**one-shot wake registration**: if `~/.cks/user/<slug>/proactive.json` already says
`registered: true`, reuse the existing wake; otherwise register one `CronCreate` wake
(cadence is the user's choice, hourly default) and record `proactive.json`. One wake serves
all of that user's reminders — never register a second.

## Registering the Wake

Do not hand-roll scheduling. Reuse what CKS already has:

- **`CronCreate`** directly — schedule a recurring prompt that says: "Proactive wake for
  user `<slug>`. Follow `skills/proactive-brain` scan loop. `CKS_ACTIVE_USER=<slug>`."
- or the **`cks:scheduler`** agent for a guided setup (it writes a state file then calls
  `CronCreate`).

Cadence is the user's call (hourly is a sane default for blockers; reminders fire at their
own due time). Confirm cadence before registering — proactive frequency is a preference,
not a default to assume.

## Relationship to Other State

| State | Role in proactive |
|---|---|
| `conversation-state.json` | source of `pending` age + `last_proactive` dedup; push appended to `recent_turns` |
| `user-memory` (`profile.md`) | quiet-hours window, push preferences (cadence, opt-out) |
| `reminders.md` | due reminders to fire |
| `.prd/PRD-STATE.md` | blocker / phase-complete signals |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Loop over all users in `~/.cks/user/` and push to each" | The guard blocks enumeration on purpose. One wake = one `CKS_ACTIVE_USER`. Register a wake per user. |
| "Push every wake so the user knows it's alive" | A bot that pings with nothing to say gets muted. Most wakes push nothing. |
| "Re-send the nudge until they answer" | Nudge a stale clarification once. `last_proactive` dedup exists to stop re-nagging. |
| "Use AskUserQuestion for the proactive question" | It stalls an unattended session. Set `pending` and let their reply resume the thread. |
| "Ignore quiet hours, it's important" | Only a true blocker overrides quiet hours, and rarely. Default is defer. |

## Verification

- [ ] Wake scans exactly one user (`$CKS_ACTIVE_USER`); never enumerates sibling dirs
- [ ] Only push-worthy signals (blocker / due reminder / stale pending / handoff) trigger a push
- [ ] `last_proactive` dedup prevents re-nagging an unchanged signal
- [ ] Quiet hours respected; only a hard blocker may override, rarely
- [ ] Pushes go out via the channel `reply` tool, formatted for the source
- [ ] A proactive question sets `pending` (P3), never `AskUserQuestion`
- [ ] Fired reminders marked done; pushes appended to `recent_turns`; most wakes are silent
