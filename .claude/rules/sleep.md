---
# sleep Rules

Three carve-outs for the SkillOpt-Sleep nightly skill training loop.

## 1. Loop-Scope Consent (Destructive Ops Exception)

Standard rule: `.claude/rules/destructive-ops.md` requires a warning block before every `git reset --hard`.

Carve-out: When `sleep-runner` is running an active cycle, the single consent block shown at start covers all in-cycle `git reset --hard HEAD` operations. Per-skill warnings are suppressed.

Conditions: reset target is HEAD only; reset is on `sleep/<date>` branch only; user approved via AskUserQuestion at cycle start; every reset is logged in `.sleep/results/{date}.json`.

Why: The cycle runs nightly unattended. Per-skill reset prompts defeat the never-stop contract. User approved the cycle knowing resets are the discard mechanism for failed replay iterations.

## 2. Branch Naming Exception

Standard rule: `.claude/rules/git-hygiene.md` requires `{issue-number}-short-description`.

Carve-out: `sleep/<date>` branches are exempt. They are disposable cycle containers, not tied to GitHub issues. Expected lifecycle: review `.sleep/staged/` → adopt proposals → `git branch -D sleep/<date>`.

## 3. Governance Log Coalescing (v2 note)

A multi-skill cycle may generate repeated identical `git reset --hard` entries in `.cks/governance.json`. This is accepted noise for v1. Future fix: coalesce same `args_digest` within same `session_id` when `consecutive_identical >= 3`. Do not modify `governance-log.sh` now — track for G2 AHE Evolution Agent.

## 4. skills/ Write Protection (Adoption Only)

Standard behavior: nothing writes to `skills/*/SKILL.md` inside a cycle.

Writes to `skills/*/SKILL.md` are ONLY permitted during the adoption flow (`--adopt`), after an explicit user approval via `❓ DECISION REQUIRED` block. Any in-cycle write to `skills/` outside adoption is a violation.

Adoption flow MUST also record pre/post delta per §6 before declaring complete.

## 5. Binary Check Required

Every `/cks:sleep` invocation MUST exercise the binary presence and version check in `scripts/sleep-engine.sh` before any harvest or proposal work begins.

- Binary absent → emit `▶ ACTION REQUIRED` block and exit non-zero (per `external-tool-integration.md` rule 1)
- Binary present → capture version via `skillopt --version`; fall back to `pip show skillopt` if needed (per `external-tool-integration.md` rule 2 — parse, never echo raw stdout)
- Version drift detected → emit `💡 SUGGESTION` block; update `.cks/sleep-config.json:skillopt_version_seen`; continue cycle (per `external-tool-integration.md` rule 3 — suggest, never hard-fail on drift)

Violation: a sleep cycle that runs `skillopt` without first confirming binary presence is a silent harvest failure path — the cycle will error mid-run with an unhelpful message instead of a structured `▶ ACTION REQUIRED` block.

## 6. Adoption Outcome Metric

The `--adopt` flow MUST capture a pre/post smoke eval delta before declaring adoption complete.

- Before patching `skills/{skill}/SKILL.md`: dispatch `cks:evals-runner --tier=smoke`, capture mean pass rate as `pre_score`
- After patching: re-run evals, capture `post_score`; compute `delta = post_score - pre_score`
- Write `.sleep/applied/{skill}-{date}.json` with `{pre_score, post_score, delta, completed_at}` (schema: `.prd/phases/03-skillopt/design/data-shapes.md §2`)
- If `delta < 0`: emit `💡 SUGGESTION` to revert via `git checkout HEAD -- skills/{skill}/SKILL.md`; do NOT auto-revert

Adoption count alone is NOT a success metric — quality lift is. A skill adopted with `delta < 0` has degraded the skill set; the revert suggestion is the safety net. Hard auto-revert is forbidden (user decision only).
