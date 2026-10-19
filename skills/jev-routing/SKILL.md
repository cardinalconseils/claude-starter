---
name: jev-routing
description: "Dynamic per-dispatch model routing via TypeSafe Jev — a PreToolUse hook on the Agent tool that asks Jev which Claude tier a subagent dispatch needs and lowers tool_input.model when it is safe to. Use when: model routing, Jev, save tokens, cheaper model, dispatch cost, why did this dispatch use opus."
allowed-tools:
  - Read
  - Bash
---

# Jev Routing

## What It Does

Every `Agent`/`Task` dispatch normally runs on its role's static default model
(`agents/<role>.md` frontmatter `model:`, see `skills/prd/references/model-strategy.md`).
That default is a fixed ceiling picked for the worst case the role handles — most
dispatches are simpler than that worst case.

The `jev-model-router.sh` PreToolUse hook (`hooks/hooks.json`, matcher `Agent|Task`) asks
[TypeSafe Jev](https://typesafe.ai) two questions per dispatch, before the subagent starts:

1. Which Claude tier (`haiku`/`sonnet`/`opus`) is sufficient to do this task well on the
   first attempt?
2. Is this task high-stakes (production, money, credentials, data deletion, external
   comms, architectural commitment)?

**It only ever lowers cost by default.** The role's static model stays the ceiling: Jev
can route a dispatch *down* to a cheaper tier, never up, unless you explicitly opt into
upgrades (`allow_upgrade`, below). A dispatch is left untouched — same as if this skill
did not exist — whenever: the caller already set `model` explicitly, the role is exempt,
Jev's confidence is below the floor, or the task is flagged high-stakes. Any Jev failure
(timeout, HTTP error, malformed answer) fails open silently — the dispatch runs on its
normal default, nothing blocks.

## Setup

1. `export TYPESAFE_API_KEY=...` (get one at typesafe.ai) — never commit this
2. `export CKS_JEV_ROUTING=on` (or set `"enabled": true` in a config file below)
3. Network access to `https://api.typesafe.ai` from wherever Claude Code runs

Without both the key and `enabled`, the hook is a silent no-op — every dispatch behaves
exactly as it did before this skill existed.

## Config

First hit wins per key: env var -> `<repo-root>/.cks/jev-routing.json` -> global
`~/.cks/jev-routing.json` -> built-in default. The global file applies to every repo on
the machine; a repo's own `.cks/jev-routing.json` overrides it for that repo only.

```json
{
  "enabled": false,
  "min_confidence": 0.6,
  "high_stakes_threshold": 0.5,
  "allow_upgrade": false,
  "exempt_roles": ["cks:chief-of-staff"],
  "timeout_s": 4,
  "model": "jev-latest",
  "base_url": "https://api.typesafe.ai",
  "log_path": "~/.cks/logs/jev-routing.jsonl"
}
```

| Key | Env var | Default | Meaning |
|---|---|---|---|
| `enabled` | `CKS_JEV_ROUTING` | off | Master switch |
| `min_confidence` | `CKS_JEV_MIN_CONFIDENCE` | 0.6 | Below this, keep the role default |
| `high_stakes_threshold` | — | 0.5 | At/above this, keep the role default regardless of tier |
| `allow_upgrade` | `CKS_JEV_ALLOW_UPGRADE` | false | Let Jev route *above* the role default |
| `exempt_roles` | — | `["cks:chief-of-staff"]` | Never call Jev for these `subagent_type`s |
| `timeout_s` | `CKS_JEV_TIMEOUT` | 4 | Jev request timeout |
| `model` | `CKS_JEV_MODEL` | `jev-latest` | Jev model to query |
| `base_url` | `CKS_JEV_BASE_URL` | `https://api.typesafe.ai` | Jev API base |
| `log_path` | `CKS_JEV_LOG` | `~/.cks/logs/jev-routing.jsonl` | Decision log |

`TYPESAFE_API_KEY` is read from the environment only — it is never accepted from a
config file, never logged, never printed.

## Reading the Savings

```bash
python3 scripts/jev-route.py --report [--days N]
```

Prints a per-role table (dispatches, downgraded, kept-by-reason, fail-open, average Jev
latency) plus total Jev tokens spent evaluating. Every evaluated dispatch is one line in
`log_path`; the raw prompt and description are never written to it, only role, tier
choice, confidence, high-stakes score, final model and the reason — plus `session_id` and
`tool_use_id` from the hook payload. `tool_use_id` joins exactly against the same call's
tool trace (`.prd/logs/sessions/*.jsonl`); the resulting `agents/<role>.jsonl` line only
matches approximately (same role, nearby timestamp — SubagentStop has no parent
`tool_use_id`), and `session_id` is Claude Code's payload id, not the CKS
`.current_session_id` the other logs use (`.claude/rules/telemetry.md`).

Per-dispatch `cost_usd` in agent traces (`.prd/logs/agents/*.jsonl`) already reflects
whichever model actually ran, so aggregate cost reporting (`scripts/cost-report.sh`,
finops routines) needs no separate accounting for Jev — the savings show up there
automatically once a dispatch is routed to a cheaper model.

## Privacy

The dispatch's `description` and `prompt` (the latter capped at 12,000 chars, head+tail)
are sent to TypeSafe's API as part of the routing question. If that is not acceptable for
a given repo or session, leave `CKS_JEV_ROUTING` unset — the hook is inert without it.

## Turning It Off

Unset `CKS_JEV_ROUTING` / `TYPESAFE_API_KEY`, or set `"enabled": false` in either config
file. The hook still runs on every dispatch but exits with no output the instant it sees
the switch is off — no behavior change, no latency worth noticing.

## Companion Plugins

- `typesafe@typesafe-ai` — the skill for *building* with Jev directly (custom questions,
  other routing decisions beyond model tier)
- `fast-jev-compaction` — verbatim context compaction backed by Jev; needs
  `CLAUDE_CODE_ENABLE_FUNCTION_HOOKS=1`

## Verification

- [ ] `TYPESAFE_API_KEY` set and `CKS_JEV_ROUTING=on` before expecting any routing
- [ ] A dispatch with an explicit `model` in the brief is never touched
- [ ] `cks:chief-of-staff` (and any repo-added `exempt_roles`) never gets a Jev call
- [ ] `python3 scripts/jev-route.py --report` shows the expected downgrade/kept mix
- [ ] No API key, prompt, or description text ever appears in `log_path`
