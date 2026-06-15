---
name: sleep-cycle
description: "SkillOpt-Sleep nightly skill training loop — harvests CKS telemetry, replays tasks offline, gates improvements against held-out evals, stages proposals for user review. Integrates with session-start, retro, sprint, evals, and scheduler."
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent, AskUserQuestion
---

# sleep-cycle Skill

## What This Is

A nightly optimization loop that treats CKS skill `.md` files as trainable components.
Powered by Microsoft SkillOpt (MIT, v0.1.0, PyPI: `skillopt`).

The core promise: CKS's 145 static skills become self-improving — updated from actual
session usage, validated before staging, adopted only with user approval.

## Deterministic vs. Indeterministic Design

This is the load-bearing architecture of the sleep cycle. Violating this split produces
unverifiable proposals.

| Step | D/I | Why | How enforced |
|------|-----|-----|--------------|
| Harvest telemetry | **D** | Reads fixed file paths, fixed schema | No LLM involved |
| Mine task patterns | **D** | Regex + frequency count on JSONL | `scripts/sleep-engine.sh` |
| Held-out task selection | **D** | Random seed pinned per-run | `seed = session_id[:8]` |
| Replay tasks offline | **I** | LLM generates responses — expected to vary | temperature=0.7 |
| Skill edit generation | **I** | LLM proposes text edits — expected to vary | temperature=0.7 |
| Gate (score comparison) | **D** | Numeric threshold, same inputs = same verdict | `.cks/sleep-config.json` |
| Staging proposals | **D** | File write to `.sleep/staged/` | No LLM involved |
| Adoption review | **D** | Decision Required block, user input | AskUserQuestion |
| Skill apply (if approved) | **D** | Patch from staged diff | No LLM involved |

**Key invariant:** The indeterministic steps (replay + edit generation) are sandboxed
inside the cycle. Every output that exits the cycle (staged proposals, gate scores) goes
through a deterministic gate before touching any CKS file. Nothing indeterministic lands
in `skills/*/SKILL.md`.

## Lifecycle Integration Points

Sleep is not standalone. It connects at five points:

1. **Session Start** — surfaces pending proposals + staleness nudge (see session-start.sh)
2. **Sprint Review** — prd-executor queues touched skills into `.sleep/queue.json`
3. **Retrospective** — retro agent appends convention-matched skills to `.sleep/queue.json`
4. **Evals Gate** — evals-runner runs smoke tier before any proposal is staged
5. **Scheduler** — nightly cron at 2am (registered on first `--enable`)

## Directory Layout

```
.sleep/
  queue.json          — skills queued for next cycle (appended by retro + sprint)
  harvest/            — per-skill telemetry extracts (D output)
  proposals/          — raw skillopt output before gate (I output, ephemeral)
  staged/             — gated proposals awaiting user review (D output)
  applied/            — adopted proposals (audit trail)
  blocked/            — gate failures with reason (D output)
  results/            — per-cycle summary JSON (D output)
.cks/
  sleep-enabled       — opt-in flag (create to enable)
  sleep-config.json   — threshold config (optional, defaults to 0.05)
```

## Queue Format

`.sleep/queue.json`:
```json
{
  "queued": [
    {"skill": "prd", "source": "sprint", "queued_at": "2026-06-15T14:00"},
    {"skill": "retrospective", "source": "retro", "queued_at": "2026-06-15T15:30"}
  ]
}
```

`source` values: `sprint` | `retro` | `manual` | `spike`

## sleep-config.json Defaults

```json
{
  "lift_threshold": 0.05,
  "held_out_tasks": 5,
  "max_skills_per_cycle": 10,
  "spike_skills": ["prd", "retrospective", "evals"]
}
```

## Spike vs. Full Cycle

| Mode | Stages? | Git resets? | Output |
|------|---------|-------------|--------|
| `--spike` | No | No | `spike-results.md` only |
| Full cycle | Yes | Yes (consent-gated) | `.sleep/staged/` proposals |

Spike is always safe to run — no staging, no destructive ops.
Full cycle requires opt-in + loop-scope consent.

## Skill Selection Strategy

Priority order for a full cycle:
1. Skills in `.sleep/queue.json` (sourced from sprint or retro)
2. Skills with highest telemetry signal (most tool-call hits in session logs)
3. Skills not run in the past 30 days

Cap at `sleep-config.json → max_skills_per_cycle` (default: 10) per cycle.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The lift looks small, I'll skip the gate" | Gate threshold is 0.05 (5%). Below that = noise. If it fails, the proposal is blocked by design. |
| "I'll apply the proposal directly, skip the Decision Required block" | Rule violation. Adoption always goes through the user. NEVER auto-apply. |
| "Spike results look good, I'll stage them" | Spike mode does not stage. That's the point. Run a full cycle to stage. |
| "I'll queue all 145 skills at once" | `max_skills_per_cycle` exists for budget reasons. Queue discipline matters. |
| "The telemetry is sparse, I'll skip harvest" | Sparse harvest = fewer seeds. Run the cycle anyway — skillopt handles low-signal gracefully. |

## Verification

- [ ] `.cks/sleep-enabled` guards cycle execution
- [ ] Loop-scope consent fires exactly once per cycle, never per skill
- [ ] Held-out seed = `session_id[:8]` — same session = same held-out set
- [ ] No proposal in `.sleep/staged/` bypassed the evals gate
- [ ] `skills/*/SKILL.md` unchanged until user approves via `--adopt`
- [ ] Every cycle writes `.sleep/results/{date}.json`
