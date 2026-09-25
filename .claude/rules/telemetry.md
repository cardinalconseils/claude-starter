# Telemetry Schema Rules

## What Gets Logged

Per-tool-call traces are written to `.prd/logs/sessions/{session_id}.jsonl` by `hooks/handlers/post-tool-trace.sh` (PostToolUse). These are per-dev artifacts — gitignored. The main `lifecycle.jsonl` is NOT flooded with tool traces.

## Layer 1 Fields (current)

| Field | Type | Description |
|---|---|---|
| `tool` | string | Claude Code tool name (Bash, Edit, Read, Agent, etc.) |
| `args_digest` | string | First 8 hex chars of SHA256(sorted tool_input JSON). Not reversible — safe for logging. |
| `outcome` | "success" \| "error" | Derived from `tool_response.error`. |
| `tool_use_id` | string | Payload `tool_use_id`, or empty. Present on every tool call, including Agent/Task. |
| `timestamp` | ISO 8601 UTC | Hook execution time. |
| `session_id` | string | From `.prd/logs/.current_session_id` — a CKS-generated id, NOT the Claude Code payload `session_id`. |

## Layer 2 — Agent Dispatch Traces (shipped)

One line per sub-agent dispatch is appended to `.prd/logs/agents/{role}.jsonl` by
`hooks/handlers/subagent-stop-trace.sh` (SubagentStop, logic in `scripts/agent-trace.sh`). Layer 1
only sees the literal tool name `Agent`; this layer is what gives each role a win/loss record.
Per-dev artifacts — `.prd/logs/` is gitignored. Written only when `.prd/logs/` already exists.

| Field | Type | Description |
|---|---|---|
| `ts` | ISO 8601 UTC | Hook execution time. |
| `role` | string | `agent_type` (or `subagent_type`) from the SubagentStop payload, e.g. `cks:debugger`; `"unknown"` when absent. Also the file name. |
| `agent_id` | string | Payload `agent_id`, or empty. |
| `outcome` | "completed" \| "error" | `"error"` when the last assistant line of the transcript contains `outcome=fail`, `outcome=error` or `"is_error": true`; otherwise `"completed"`. Best-effort. |
| `session_id` | string | From `.prd/logs/.current_session_id`, falling back to the payload `session_id`. |
| `transcript` | string | Basename of `transcript_path` / `agent_transcript_path`, or empty. |
| `model` | string | `message.model` of the last assistant line in the transcript, or empty. |
| `tokens_in` | int | Σ `usage.input_tokens` over the transcript, deduplicated by `message.id` (streaming repeats cumulative usage per line). |
| `tokens_out` | int | Σ `usage.output_tokens`, same dedupe. |
| `tokens_cache_read` | int | Σ `usage.cache_read_input_tokens`. |
| `tokens_cache_write` | int | Σ `usage.cache_creation_input_tokens`. |
| `cost_usd` | number (6 dp) | `tokens_in×input + tokens_out×output + cache_write×input×1.25 + cache_read×input×0.1`, all ÷ 1e6, prices from `skills/finops/references/model-prices.json`. **An estimate from list prices, not a bill.** |
| `duration_ms` | int | Last transcript `timestamp` − first, in ms; `0` when unknown. |
| `price_source` | `"model"` \| `"tier-fallback"` \| `"unknown"` | How the price was resolved (`references/model-prices.md`). `unknown` means `cost_usd` is `0` and the table needs the id. |

SubagentStop field names vary by Claude Code version — every lookup is optional and absence never
fails the hook.

**Consumers:** the historian role and the weekly `workforce-review` routine read these files to
cluster failures by role before proposing agent or skill edits; `/cks:retro` may join them with
`lifecycle.jsonl` on `session_id`.

Lines written before the cost fields shipped lack them; every reader treats a missing field as `0`.
`scripts/cost-report.sh [--period YYYY-MM] [--by role|model|session] [--json]` is the reference
reader; `hooks/handlers/budget-guard.sh` sums `cost_usd` against `.finops/BUDGET.md`.

## Jev Routing Log Join Keys

`scripts/jev-route.py` (`hooks/handlers/jev-model-router.sh`, PreToolUse on `Agent|Task`)
writes each routing decision to `~/.cks/logs/jev-routing.jsonl` (`skills/jev-routing/SKILL.md`).
Every line — including the `fail_open` case — carries `session_id` and `tool_use_id`, read
straight off the hook payload (default `""` when absent). The Jev log never carries the prompt
or description.

**Exact join:** a Jev routing line and the Layer 1 tool-trace line for that same `Agent`/`Task`
call join exactly on `tool_use_id` — `post-tool-trace.sh` fires PostToolUse for the same call
and carries the identical id.

**Approximate join only:** a Jev line does NOT join exactly to the resulting dispatch's
`agents/<role>.jsonl` line (Layer 2). SubagentStop carries `agent_id`, not the parent
`tool_use_id`, so an agent-trace line can only be matched to a Jev/tool-trace line
approximately — same `role`, timestamp inside the tool-trace call's window.

**`session_id` is not shared across logs.** The Jev log's `session_id` is Claude Code's own
payload session id. `post-tool-trace.sh` and `agent-trace.sh` instead use the CKS-generated
`.prd/logs/.current_session_id` (a timestamp string) for their `session_id` field. These are
two different values for the same session — do not join across files on `session_id`.

## Reserved Fields — Layer 3 (decision traces, not yet shipped)

`decision.considered` — array of alternatives the agent evaluated before choosing a tool.
`decision.chose` — the selected tool and why.

## Consuming the Traces

- **Retrospective agents**: read `.prd/logs/sessions/` to cluster tool-call failure patterns.
- **G2 AHE Evolution Agent** (future): reads session traces to propose rule mutations.
- **Existing consumers** (`/cks:logs`, `/cks:retro`, debug skill): continue reading `lifecycle.jsonl` unchanged — session traces are additive.

## What Agents Must NOT Do

- Never write raw credential values into `tool_input` — `args_digest` hashes the args before any logging.
- Never treat `cost_usd` as billed spend — it is a list-price estimate; the invoice is the source of truth in the ledger.
- Never write directly to `.prd/logs/sessions/` — only `post-tool-trace.sh` writes there.
- Never write directly to `.prd/logs/agents/` — only `subagent-stop-trace.sh` (via `agent-trace.sh`) writes there.
