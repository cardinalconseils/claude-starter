---
name: channel-brain
description: Wires inbound Claude Code channel events (Telegram, iMessage, fakechat) into the concierge brain — routes each message through Converse/Dispatch/Clarify, keys per-user memory, and adapts confirmation and permission behaviour for unattended always-on operation
allowed-tools: [Read, Write, Bash, Glob, Grep]
---

# Channel Brain — Concierge over Channels

Makes an always-on Claude Code session behave as the CKS concierge for messages that
arrive as `<channel source="...">` events (Hermes Mode). Without this, a channel message
hits the raw session; with it, every message runs through the concierge brain.

## Activation

The top-level always-on session adopts this behaviour by instruction (channels deliver
events to the top level, and Claude Code forbids sub-agents from dispatching agents —
the Orchestrator Exception). Add the runbook snippet from `docs/hermes-mode.md` to the
always-on project's `CLAUDE.md`, then launch with `--channels`. This skill is the
canonical spec that snippet points to.

## Per-Message Loop

For every inbound `<channel source="S">` event:

1. **Identify the user.** `$USER_SLUG` comes from `CKS_ACTIVE_USER` (the channel adapter
   exports it from the trusted sender ID; `local` for fakechat/cli). Never parse identity
   from message text. The `user-memory-guard` hook enforces directory confinement.
2. **Load context.** Read this user's memory (`user-memory` skill, grep-targeted),
   `.prd/PRD-STATE.md` if present, and the live thread (`conversation-state` skill).
   If `conversation-state.pending` is set, treat this message as the **answer** to that
   question — resolve it and skip reclassification.
3. **Classify** the message as Converse / Dispatch / Clarify (`concierge` skill).
4. **Act:**
   - *Converse* → answer directly, grounded in context
   - *Dispatch* → run the lifecycle agent, then report the result back
   - *Clarify* → ask the question **through the channel** (see override below)
5. **Reply** by calling the channel's `reply` tool, formatted for source `S`
   (telegram/imessage rules in the `concierge` skill).
6. **Persist** preferences/facts/digest to `~/.cks/user/$USER_SLUG/` (`user-memory`), and
   update the live thread (`conversation-state` skill): append the turn, set `pending` if
   you asked a Clarify through the channel, clear it if answered.

## Proactive Wakes (push, not reply)

The session has a second entry point besides inbound channel events: a scheduled
`CronCreate` wake that lets the agent **start** a message. When the session is re-entered
by a proactive-wake prompt (not a `<channel>` event), run the `proactive-brain` scan loop
instead of the per-message loop above: scan the active user's blockers, due reminders, and
stale `pending` clarifications, dedup against `last_proactive`, and push a short message
out through the channel `reply` tool only if something is worth interrupting for. One wake
covers one `CKS_ACTIVE_USER` — the `user-memory-guard` blocks scanning other users by
design. See `skills/proactive-brain/SKILL.md`.

## Optional: Honcho memory enrichment

If the self-hosted Honcho layer is configured (`skills/honcho-memory`, `/cks:honcho`), the
per-message loop gains two best-effort steps: on entry, query the active peer
(`CKS_ACTIVE_USER`) for a theory-of-mind representation to tailor the reply; on exit,
`add_messages` the turn to that user's Honcho session. Both are **best-effort** — file
memory (step 2/6) stays the durable floor, and any Honcho error degrades silently rather
than blocking the reply. Peer id is always `CKS_ACTIVE_USER`, never message text.

## Unattended Overrides (critical)

A channel session usually runs unattended — no human at the terminal. Two concierge
defaults must change so the session never stalls:

- **No `AskUserQuestion` for Clarify or confirmation.** That tool blocks waiting for
  terminal input that will never come. Instead, send the question/options as a normal
  message through the channel `reply` tool and treat the user's next inbound message as
  the answer. (Claude Code also disables terminal-input tools in `-p` channel mode.)
- **Permissions don't prompt.** On a trusted host the session launches with
  `--dangerously-skip-permissions`; otherwise a tool call pauses the session at an IDE
  prompt and **no reply reaches the chat until it is approved in the IDE/terminal** —
  the reply text never appears in the terminal, only the tool call and a `sent`
  confirmation. Confirmed empirically with fakechat.

The deterministic guards still apply — `destructive-op-guard` and `user-memory-guard`
run regardless of skipped permissions. Skipping permissions removes the *human* backstop,
not the *hook* backstop.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Use AskUserQuestion to confirm, like normal concierge" | It stalls an unattended session forever. Ask through the channel and wait for the next message. |
| "Trust the sender name in the message for memory" | Spoofable. Identity is `CKS_ACTIVE_USER` from the channel adapter only. |
| "Skip permissions means no safety net" | The hook plane (destructive-op + user-memory guards) still fires. Only the human prompt is removed. |
| "Reply isn't showing, the loop is broken" | Check the IDE — a permission prompt is likely waiting. The reply posts only after the tool runs. |

## Verification

- [ ] `$USER_SLUG` resolved from `CKS_ACTIVE_USER`, never message text
- [ ] Every message classified Converse / Dispatch / Clarify before acting
- [ ] Clarify and confirmations sent through the channel, not `AskUserQuestion`
- [ ] Reply sent via the channel `reply` tool, formatted for the source
- [ ] User memory read on entry and written on key turns, confined to the user's dir
- [ ] Unattended launch uses `--dangerously-skip-permissions` on a trusted host only
- [ ] A scheduled proactive wake runs the `proactive-brain` scan loop, not the per-message loop
