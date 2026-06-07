---
name: honcho-memory
description: Optional self-hosted Honcho memory layer that AUGMENTS CKS file memory — adds theory-of-mind user representations (the dialectic) on top of the durable local files, keyed to the trusted CKS_ACTIVE_USER as the Honcho peer. File memory stays the always-available floor; Honcho is best-effort enrichment.
allowed-tools: [Read, Write, Bash, Glob, Grep]
---

# Honcho Memory — Self-Hosted Theory-of-Mind Layer

`skills/user-memory` stores facts you *write* (append-only markdown). Honcho *infers* a
model of the user — preferences, habits, goals — via its **dialectic**, and you query it
("what does Honcho know about this user?"). This skill adds Honcho as an **optional,
self-hosted** layer **on top of** file memory, never replacing it.

## Augment policy (non-negotiable)

- **File memory + `user-memory-guard` is the durable, local floor.** Always write it.
- **Honcho is best-effort enrichment.** If the local Honcho instance is unreachable, the
  turn proceeds on file memory alone — **never block a reply on Honcho**.
- This keeps the deterministic local backstop while gaining user-modelling. Honcho down ≠
  agent down.

## Mapping onto what CKS already has

| CKS | Honcho |
|---|---|
| `CKS_ACTIVE_USER` (trusted sender id) | **peer id** (the user); the agent is a second peer (`assistant`) |
| `conversation-state` live thread | a **session** (`add_messages` per turn) |
| `user-memory` profile/facts | the **representation / peer card** (`get_representation`, `get_peer_card`) |
| end-of-convo `history.md` digest | auto-derived by the dialectic (no manual digest needed) |

## Isolation boundary (replaces the guard for the Honcho plane)

The filesystem guard cannot reach an API. The boundary becomes **peer-id discipline**,
enforced the same way:

- `peer_id := CKS_ACTIVE_USER` — set by the channel adapter from the **trusted sender id**.
  **Never** derive the peer from message text. Query/write **only** the active peer.
- One Honcho **workspace per host**; peers are scoped within it. The agent must only ever
  `chat`/`get_representation` for the active peer — treat another peer's id like another
  user's directory: off-limits.
- Self-hosted instance runs on the same trusted host (`http://localhost:8000`), so memory
  never leaves the box. Keys handled per `.claude/rules/secrets.md`.

## Per-turn protocol (when Honcho is configured)

On inbound, after resolving `$USER_SLUG = CKS_ACTIVE_USER`:
1. **Enrich (optional, fast):** query the active peer for tailoring —
   `chat`/`get_representation` with `reasoning_level: minimal` for speed. Fold the result
   into how you answer. On any error/timeout, skip silently and use file memory.
2. **Answer** as usual (Converse / Dispatch / Clarify).
3. **Record:** `add_messages` for the user turn and the agent reply to this user's session.
   The dialectic derives the representation in the background — no manual fact-writing.
4. **Still write file memory** per `user-memory` (the floor). Honcho is additive.

Use `set_peer_card` only to *correct* a fact the user explicitly fixes; let the dialectic
do the rest.

## Self-hosting (keeps data on your box)

```bash
git clone https://github.com/plastic-labs/honcho.git && cd honcho
cp docker-compose.yml.example docker-compose.yml
cp .env.template .env        # set ONE deriver LLM key: LLM_ANTHROPIC_API_KEY / _GEMINI_ / _OPENAI_
docker compose up -d --build # api+deriver+db+redis → http://localhost:8000
```

> **Cost note:** the deriver runs an LLM to build representations. This is the *only*
> per-token cost, and it is for **memory synthesis, not conversation** — your Claude
> subscription still drives the chat. Point the deriver at a cheap model (Haiku / Gemini
> Flash) to keep it negligible.

**Access path — two options:**
- **MCP (preferred, tool-native):** register Honcho's MCP server so the agent gets memory
  tools (`chat`, `get_representation`, `add_messages`, `get_peer_card`, …). The documented
  form targets the hosted endpoint:
  ```bash
  claude mcp add honcho --transport http --url "https://mcp.honcho.dev" \
    --header "Authorization: Bearer hch-…" --header "X-Honcho-User-Name: <peer>"
  ```
  Pointing the MCP server at your **local** `:8000` instance (instead of the cloud) is the
  one thing to confirm on-host — the integrator validates it. If unconfirmed, fall back to:
- **SDK at `http://localhost:8000`** (blank API key for local) — small Python/TS calls.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Replace the markdown with Honcho, it's smarter" | Then a network blip = no memory. Files are the local floor; Honcho augments. |
| "Pass the sender's name from the message as the peer" | Spoofable. Peer id is `CKS_ACTIVE_USER` from the trusted adapter only — same rule as the guard. |
| "Use the hosted MCP, it's easier" | That ships user data to the cloud. The user chose self-hosted; keep it on `localhost:8000`. |
| "Block the reply until the representation loads" | Enrichment is best-effort. Timeout → answer on file memory. Never stall on memory. |
| "The deriver is free because I'm on a subscription" | The deriver is a separate LLM call. Budget it; use a cheap model. |

## Verification

- [ ] File memory + guard still written every turn (Honcho never replaces the floor)
- [ ] `peer_id` resolved only from `CKS_ACTIVE_USER`; only the active peer is queried
- [ ] Honcho instance is local (`http://localhost:8000`); data does not leave the host
- [ ] Enrichment failures degrade silently to file memory — no blocked replies
- [ ] Deriver points at a cheap model; the cost trade-off is acknowledged
- [ ] API / LLM keys handled per `.claude/rules/secrets.md`, never in the repo
