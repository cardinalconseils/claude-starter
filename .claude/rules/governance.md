# Governance Log Rules

## What Gets Logged

HIGH-risk Bash commands that were allowed to run are appended to `.cks/governance.json` (JSONL, append-only) by `hooks/handlers/governance-log.sh` (PostToolUse). This file is gitignored — per-dev artifact, never ships with the plugin.

CRITICAL-blocked commands (exit 2 from `destructive-op-guard.sh`) never reach PostToolUse and are not captured in v1. CRITICAL rejection logging is a v2 extension.

## Schema

| Field | Type | Description |
|---|---|---|
| `ts` | ISO 8601 UTC | Hook execution time. |
| `session_id` | string | From `.prd/logs/.current_session_id`. |
| `tool` | string | Always "Bash" in v1. |
| `args_digest` | string | First 8 hex chars of SHA256(sorted tool_input JSON). Not reversible. |
| `risk_level` | "HIGH" | CRITICAL-blocked ops not captured in v1. |
| `risk_reason` | string | Human-readable risk description. |
| `decision` | "approved" \| "ran-with-error" | Outcome of the risky command. |

## Reserved Fields — v2

`decision: "rejected"` — for CRITICAL blocks (requires `destructive-op-guard.sh` to write directly).

## What Agents Must NOT Do

- Never read raw command text from `tool_input` — only `args_digest` is stored.
- Never write directly to `.cks/governance.json` — only `governance-log.sh` writes there.
- Never assume `decision: "rejected"` entries exist until v2 ships.

## Primary Consumer

G2 AHE Evolution Agent (future) — reads `(args_digest, risk_reason, decision)` pairs to learn which action classes trigger human gates and propose policy mutations.
