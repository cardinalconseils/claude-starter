# Telemetry Schema Rules

## What Gets Logged

Per-tool-call traces are written to `.prd/logs/sessions/{session_id}.jsonl` by `hooks/handlers/post-tool-trace.sh` (PostToolUse). These are per-dev artifacts — gitignored. The main `lifecycle.jsonl` is NOT flooded with tool traces.

## Layer 1 Fields (current)

| Field | Type | Description |
|---|---|---|
| `tool` | string | Claude Code tool name (Bash, Edit, Read, Agent, etc.) |
| `args_digest` | string | First 8 hex chars of SHA256(sorted tool_input JSON). Not reversible — safe for logging. |
| `outcome` | "success" \| "error" | Derived from `tool_response.error`. |
| `timestamp` | ISO 8601 UTC | Hook execution time. |
| `session_id` | string | From `.prd/logs/.current_session_id`. |

## Reserved Fields — Layer 2 (cost/latency, not yet shipped)

`duration_ms`, `cost_usd`, `tokens_in`, `tokens_out`

## Reserved Fields — Layer 3 (decision traces, not yet shipped)

`decision.considered` — array of alternatives the agent evaluated before choosing a tool.
`decision.chose` — the selected tool and why.

## Consuming the Traces

- **Retrospective agents**: read `.prd/logs/sessions/` to cluster tool-call failure patterns.
- **G2 AHE Evolution Agent** (future): reads session traces to propose rule mutations.
- **Existing consumers** (`/cks:logs`, `/cks:retro`, debug skill): continue reading `lifecycle.jsonl` unchanged — session traces are additive.

## What Agents Must NOT Do

- Never write raw credential values into `tool_input` — `args_digest` hashes the args before any logging.
- Never assume `duration_ms` or `cost_usd` are present until Layer 2 ships.
- Never write directly to `.prd/logs/sessions/` — only `post-tool-trace.sh` writes there.
