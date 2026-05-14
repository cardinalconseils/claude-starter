# Bidirectional Kanban Automation — CKS v5

> How CKS v5 keeps a GitHub Projects v2 Kanban board and the Attractor runner in
> sync — in both directions — so the board is a live control surface, not just a
> mirror.

## Overview

CKS v5 syncs sprint state between the Attractor pipeline and a GitHub Projects v2
Kanban board **bidirectionally**:

- **Outbound (CKS → Kanban):** as the runner advances through pipeline nodes, it
  moves the phase's card and updates custom fields.
- **Inbound (Kanban → CKS):** when a human drags a card to a new column, a GitHub
  webhook tells the runner what to do.

A 60-second reconciliation loop is the backstop — it re-syncs board state on a
timer so a missed webhook self-heals on the next cycle.

Everything is **gated off by default**. `attractor_mode: false` and
`webhook_enabled: false` in `plugin.json` keep v4 behavior unchanged until the
v5.0.0 release flips the defaults.

## The Two Directions

### Outbound — CKS → Kanban

The runner's `enterNode` helper and the sync helpers in
`tools/github-project-sync.js` (built in Wave 1) push state to the board:

- `moveCard(itemId, column)` — moves the phase card as the pipeline progresses
  (Discover → Ready, Implement → In Progress, Verify/SprintReview → In Review,
  Release → Done).
- `setCustomField(itemId, field, value)` — updates Phase Number, Runner State,
  PR Count, Last Sync.
- `commentOnPhaseItem(itemId, body)` — posts progress notes on the card.

When the GitHub Project is not configured, every helper no-ops — the pipeline
runs fully local. See `docs/PROJECT-INTEGRATION.md` for the node → column map.

### Inbound — Kanban → CKS

When a human moves a card, GitHub fires a `projects_v2_item` webhook. The webhook
listener (`tools/webhook-listener.js`, built in Wave 6) verifies it and
translates the column move into a runner action.

## The Webhook Listener

`tools/webhook-listener.js` has three responsibilities:

1. **HMAC-SHA256 signature verification.** Every webhook is verified against the
   `X-Hub-Signature-256` header using the shared webhook secret. The comparison
   is **constant-time** (`crypto.timingSafeEqual`) — a non-constant-time compare
   is a security finding, not a style nit. Missing, malformed, or mismatched
   signatures are rejected.

2. **Column → action dispatch map.** Each board column maps to a runner action:

   | Column      | Action       | Meaning |
   |-------------|--------------|---------|
   | Backlog     | `idle`       | Parked — runner takes no action |
   | Ready       | `idle`       | Queued — wait for an explicit start |
   | In Progress | `resume`     | Start or resume the runner on this phase |
   | In Review   | `await_gate` | Pause at the next human gate |
   | Blocked     | `halt`       | Stop the runner; needs a human unblock |
   | Done        | `finalize`   | Mark complete; release path |

3. **Idempotent 60s reconciliation loop.** `startReconciliationLoop()` re-reads
   the Project every 60 seconds and re-derives the dispatches implied by current
   board state. It is **idempotent** — the result reflects state, it does not
   accumulate — so applying it repeatedly is safe and a webhook missed during
   downtime is recovered on the next cycle.

The listener is config-gated: `isEnabled()` requires both `webhook_enabled: true`
and a configured GitHub Project. Otherwise every export no-ops.

## The Console Server

The CKS Console server (`board/server.js`) mounts the inbound endpoint:

```
POST /webhooks/github
```

The route reads the raw request body, hands it to the webhook listener for
signature verification, and on success dispatches the column change. The
listener module is required lazily so the server still boots if it is absent.

## Setup

Use the onboarding command:

```
/cks:setup-webhooks
```

It walks through enabling automation, generating the webhook secret, registering
the GitHub webhook against `POST /webhooks/github`, and verifying the handshake.

Relevant `plugin.json` flags:

- `webhook_enabled` — master switch for inbound automation. `false` by default.
- `attractor_mode` — master switch for the Attractor pipeline. `false` by default.
- `github_project` — `{ owner, repo, number }` block identifying the Kanban board.

Until v5.0.0, all three stay off/empty so v4 behavior is unchanged.

## Safety & Failure Modes

| Situation | Behavior |
|-----------|----------|
| Invalid / missing webhook signature | `POST /webhooks/github` responds **401**; nothing dispatched |
| `webhook_enabled: false` | Endpoint responds **503 "webhooks disabled"**; listener exports no-op |
| Listener module unavailable | Endpoint responds **503**; server still boots and serves the board |
| Oversized webhook payload | Endpoint responds **413** |
| GitHub unreachable (reads) | Sync helpers return safe defaults; pipeline continues local |
| GitHub unreachable (writes) | Sync helpers throw `GitHubUnreachableError`; release is non-blocking |
| Missed webhook (server was down) | The 60s reconciliation loop re-derives state on its next cycle |

The reconciliation loop is the core safety net: even if every webhook is lost,
board state and runner state converge within 60 seconds.
