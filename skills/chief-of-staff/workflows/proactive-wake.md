# Proactive Wake — Push, Don't Only Reply

The reactive brain (`workflows/channel-mode.md`) answers when messaged. On a scheduled
wake the same brain **starts** a message when something is worth surfacing — a blocker,
a due reminder, or a clarification the user left hanging. This is the difference between
a command parser and an assistant that watches your back.

## How a wake arrives

A scheduled wake re-enters the always-on top-level session with a proactive-wake prompt
(not a `<channel>` event). The session is already the chief of staff. On wake, run the
scan loop below instead of the per-message loop.

## Isolation: one wake = one user

`user-memory-guard` confines the session to `$CKS_ACTIVE_USER` and **blocks enumerating
sibling user directories** — by design. So a single wake scans exactly **one** user: the
one `CKS_ACTIVE_USER` is set to. Do not loop over all users from one session; the guard
will (correctly) block it. For a shared multi-user bot, register **one wake per user**,
each launched with that user's `CKS_ACTIVE_USER`, or run a per-user session.

## Scan loop (on each scheduled wake)

1. **Resolve the user.** `$USER_SLUG = $CKS_ACTIVE_USER` (`local` if unset). Never from
   text. All reads stay under the user's directory (`$CKS_HQ/users/$USER_SLUG/` when
   `CKS_HQ` is set, else `~/.cks/user/$USER_SLUG/`).
2. **Load context.** The user's `conversation-state.json`, `.prd/PRD-STATE.md` if the
   active project has one, and a grep of the user's `reminders.md` for anything now due.
3. **Collect push-worthy signals** (only these — see "What is worth interrupting"):
   - a **due reminder** (`reminders.md` line whose due time has passed)
   - a **blocker**: `phase_status` blocked/failed in PRD-STATE, or an open RAID blocker
   - a **stale pending clarification**: `conversation-state.pending` older than the
     stale threshold (default 12h) — the user never answered; nudge once
   - a **completed handoff while away**: a sprint/phase finished since the last turn
4. **Dedup against `last_proactive`.** Hash the top signal (type + subject). If it equals
   `conversation-state.last_proactive.signal` and the underlying state has not changed,
   **stay silent** — never re-nag the same thing.
5. **Respect quiet hours.** Inside the user's quiet window (default 22:00–08:00 local,
   overridable in `profile.md`), defer non-urgent pushes to the next wake. A hard blocker
   may still go out — judgment call, kept rare.
6. **If a signal survives 4–5, push it.** One short message in the user's source format
   (`SKILL.md` source-aware table), sent via the channel `reply` tool addressed to this
   user's chat. If the push asks a question, set `conversation-state.pending` so the
   user's next reply resumes the thread — never `AskUserQuestion`.
7. **Record it, by dispatch.** The brain writes nothing: a Level-1 dispatch sets
   `conversation-state.last_proactive = {signal, ts}`, appends the push to
   `recent_turns`, and marks a fired reminder done (`fired:` prefix). Silence is also a
   valid outcome — most wakes push nothing and record nothing.

## What is worth interrupting

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

A user can ask to be reminded ("remind me tomorrow 9am to deploy"). Each is an
append-only line under the user's guarded directory:

```
<user dir>/reminders.md
## [2026-06-08T09:00:00Z] deploy the telegram bot
```

On wake, grep for lines whose ISO due time is `<= now`, push them, then have the
recording dispatch mark them `fired:` so they are not re-pushed. Never echo a secret a
reminder happens to contain (`.claude/rules/secrets.md`).

**Setting a reminder** is the `/cks:remind` → `cks:assistant` (`Mode: reminders`) path: parse `<when>` to an
ISO due time, append `## [due] text` to the user's `reminders.md`, then ensure a wake
exists (one wake serves all of that user's reminders — never register a second).

## Registering the wake

Registration is a **gated action**: any role, including `cks:assistant`, proposes the
wake as a routine profile — `.routines/proactive-<user slug>/ROUTINE.md` per
`skills/routines/SKILL.md` (owner role `assistant`, `sources` = that user's guarded
directory, `report_to: [channel:<name>]`, Level 1) — and returns a `❓ DECISION REQUIRED`.
The chief of staff registers it after approval by following
`skills/routines/workflows/register.md` (`create_trigger`, one trigger per user, the
trigger prompt loads this workflow via `--routine`). The marker `proactive.json` in the
user's directory records the `trigger_id`, so the registration stays one-shot; the
routine's `STATE.md` carries `last_proactive`. If the session holds no Remote MCP, the
registration is reported under `NOT READ` with a `▶ ACTION REQUIRED` to run
`/cks:routine new` from a cloud session — a session-bound `CronCreate` is not a
substitute and is used only by `/cks:loop`. Cadence is the user's call (hourly is a sane
default for blockers; reminders fire at their own due time) — confirm it before
registering; proactive frequency is a preference, not a default to assume.

## Relationship to other state

| State | Role in proactive |
|---|---|
| `conversation-state.json` | source of `pending` age + `last_proactive` dedup; push appended to `recent_turns` |
| `user-memory` (`profile.md`) | quiet-hours window, push preferences (cadence, opt-out) |
| `reminders.md` | due reminders to fire |
| `.prd/PRD-STATE.md` | blocker / phase-complete signals |
| `proactive.json` | one-shot registration marker (the routine's `trigger_id`) |
| `.routines/proactive-<slug>/` | the wake's profile, `STATE.md` and run logs in HQ (`skills/routines/`) |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Loop over all users and push to each" | The guard blocks enumeration on purpose. One wake = one `CKS_ACTIVE_USER`. Register a wake per user. |
| "Push every wake so the user knows it's alive" | A bot that pings with nothing to say gets muted. Most wakes push nothing. |
| "Re-send the nudge until they answer" | Nudge a stale clarification once. `last_proactive` dedup exists to stop re-nagging. |
| "Use AskUserQuestion for the proactive question" | It stalls an unattended session. Set `pending` and let their reply resume the thread. |
| "Ignore quiet hours, it's important" | Only a true blocker overrides quiet hours, and rarely. Default is defer. |
| "I'll register the wake myself, it's just a cron" | Registration is gated. Propose it; the chief of staff registers after approval. |

## Verification

- [ ] Wake scans exactly one user (`$CKS_ACTIVE_USER`); never enumerates sibling dirs
- [ ] Only push-worthy signals (blocker / due reminder / stale pending / handoff) trigger a push
- [ ] `last_proactive` dedup prevents re-nagging an unchanged signal
- [ ] Quiet hours respected; only a hard blocker may override, rarely
- [ ] Pushes go out via the channel `reply` tool, formatted for the source
- [ ] A proactive question sets `pending`, never `AskUserQuestion`
- [ ] Fired reminders marked done and pushes recorded by a Level-1 dispatch; most wakes are silent
- [ ] Wake registration proposed, not performed, by the brain
