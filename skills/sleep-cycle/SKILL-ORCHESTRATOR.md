---
name: cks:sleep-orchestrator
description: SkillOpt-Sleep cycle loop — opt-in guard, one consent block, harvest → replay → gate (cks:tester smoke evals) → stage → report, plus --adopt, --spike, --status, --enable (cks:operator schedule) and --disable modes. Runs in the top-level session so Agent() dispatch works.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# Sleep Cycle — The Loop

You run SkillOpt-Sleep at the top level of the session. `SKILL.md` is the doctrine
(deterministic/indeterministic split, `.claude/rules/sleep.md` carve-outs);
`workflows/{harvest,replay,gate,adopt}.md` hold the procedures. Nothing touches
`skills/*/SKILL.md` without gate passage and explicit user approval.

Inputs: `$ARGUMENTS` — `--skill=<name>` | `--spike` | `--status` | `--adopt` | `--enable`
| `--disable` | none (next queued cycle).

---

## Mode routing

| Args | Do |
|---|---|
| `--status` | §Status, exit |
| `--adopt` | §Adoption, exit |
| `--enable` | §Enable, exit |
| `--disable` | remove `.cks/sleep-enabled`; say "Sleep disabled. Deregister the nightly trigger via /cks:schedule --list." exit |
| `--spike` | §Spike |
| otherwise | §Cycle (target `--skill` or `.sleep/queue.json`) |

## Cycle

**Guard** — `.cks/sleep-enabled` missing → "Sleep not enabled. Run: /cks:sleep --enable" and exit.

**Binary check** — `scripts/sleep-engine.sh` must confirm `skillopt` presence and version
before any harvest (`.claude/rules/sleep.md` §5): absent → `▶ ACTION REQUIRED` with the
install command, exit non-zero; version drift → `💡 SUGGESTION`, update
`.cks/sleep-config.json:skillopt_version_seen`, continue.

**Consent (once per cycle, full prose)** — show, then `AskUserQuestion` approve/decline:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ LOOP-SCOPE CONSENT — READ BEFORE PROCEEDING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Action:     SkillOpt-Sleep cycle on branch sleep/<date>
Target:     .sleep/staged/ — proposals staged, never auto-applied
Skills:     {skill names}
Resets:     git reset --hard HEAD after each failed replay iteration
            This warning covers ALL in-cycle resets — you will NOT be asked again
Reversible: YES — skills/ untouched until you adopt via /cks:sleep --adopt
You lose:   Failed replay iterations (by design)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
Decline → exit cleanly.

**Step 1 — Harvest (D)** — `workflows/harvest.md`: parse `.prd/logs/sessions/*.jsonl`,
`.learnings/session-log.md`, `.sleep/queue.json` → `.sleep/harvest/{skill}-{date}.json`.

**Step 2 — Replay (I)** — `workflows/replay.md`: 5 held-out tasks per skill (seed
`session_id[:8]`), `scripts/sleep-engine.sh` → `.sleep/proposals/{skill}-{date}-raw.md`.

**Step 3 — Gate (D)** — `workflows/gate.md`. The baseline and proposed scores each come
from one dispatch:
```
Agent(subagent_type="cks:tester", prompt="Mode: evals. Tier: smoke. Type: regression. Target: {skills/{skill}/SKILL.md | /tmp/sleep-proposed-{skill}.md}. Do NOT auto-repair. Report pass rate as a decimal and write it to .sleep/gate-scores/{skill}-{baseline|proposed}.json.")
```
Compare against `lift_threshold` from `.cks/sleep-config.json` (default 0.05; a tie fails).
Pass → `.sleep/staged/`; fail → `.sleep/blocked/{skill}-{date}.json`. Record
`skillopt_version` from `.sleep/.skillopt-version-cache` in `.sleep/results/{date}.json`.

**Step 4 — Stage (D)** — `workflows/adopt.md` staging half: copy gated proposals to
`.sleep/staged/{skill}-{date}.md` with a readable diff summary; drop processed skills from
`.sleep/queue.json`.

**Step 5 — Report**
```
💤 Sleep cycle complete — {date}
   Processed: {N} skills   Staged: {N} (gate passed)   Blocked: {N} (see .sleep/blocked/)
   Run /cks:sleep --adopt to review staged proposals.
```

## Adoption (`--adopt`)

For each file in `.sleep/staged/`, show the `❓ DECISION REQUIRED` block (skill, date, lift
delta, change summary; options Adopt / View diff / Discard / Defer; Recommended: Adopt when
the gate confirmed lift). On Adopt:

1. Pre-score: dispatch `cks:tester` as in Step 3 against `skills/{skill}/SKILL.md`; write
   the provisional `.sleep/applied/{skill}-{date}.json` (`skill`, `started_at`, `pre_score`,
   `evals_tier`).
2. Apply the diff — this is the only permitted write to `skills/*/SKILL.md`:
   ```
   Agent(subagent_type="cks:builder", prompt="Apply the staged proposal .sleep/staged/{skill}-{date}.md to skills/{skill}/SKILL.md exactly — no other file, no scope expansion. Then move the proposal to .sleep/applied/{skill}-{date}.md. Report the patch SHA.")
   ```
3. Post-score: dispatch `cks:tester` again; `delta = post − pre`. Merge `post_score`,
   `delta`, `completed_at`, `reverted: false`, `patch_sha`, `proposal_source` into the JSON.
4. `delta < 0` → `💡 SUGGESTION` to revert with `git checkout HEAD -- skills/{skill}/SKILL.md`.
   Never auto-revert.
5. Confirm: `Adopted {skill}. Lift delta: {delta} (pre={pre} → post={post})`.

Discard → delete from staged. Defer → leave in place.

## Spike (`--spike`)

Skills `prd`, `retrospective`, `evals`; Steps 1–3 only; no consent block (read-only, no
resets); write `.concept/skillopt-integration/spike-results.md` and show the table
skill | baseline | post | lift | gate.

## Status (`--status`)

Last 3 `.sleep/results/*.json`, count of `.sleep/staged/`, queue depth, on/off flag, last
cycle date.

## Enable (`--enable`)

Create `.cks/sleep-enabled`, then:
```
Agent(subagent_type="cks:operator", prompt="Mode: schedule. Register the nightly SkillOpt-Sleep trigger: command /cks:sleep, nightly at 2am local, state file .agents/sleep-runner/state.json, autonomy Level 1. Confirm the registered id.")
```
Then: "Sleep enabled. Nightly cycle registered for 2am."

## Invariants

- No write to `skills/*/SKILL.md` outside Adoption step 2
- The consent block is never skipped for a full cycle; `.cks/sleep-enabled` is required
- Results always logged to `.sleep/results/{date}.json`; deterministic seed always used
- A proposal that failed the gate is never staged
