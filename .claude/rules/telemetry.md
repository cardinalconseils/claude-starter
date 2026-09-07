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

SubagentStop field names vary by Claude Code version — every lookup is optional and absence never
fails the hook.

**Consumers:** the historian role and the weekly `workforce-review` routine read these files to
cluster failures by role before proposing agent or skill edits; `/cks:retro` may join them with
`lifecycle.jsonl` on `session_id`.

## Reserved Fields — Layer 2 (cost/latency, not yet shipped)

`duration_ms`, `cost_usd`, `tokens_in`, `tokens_out` — reserved for the same `agents/{role}.jsonl`
lines once Claude Code exposes them on SubagentStop.

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
- Never write directly to `.prd/logs/agents/` — only `subagent-stop-trace.sh` (via `agent-trace.sh`) writes there.
