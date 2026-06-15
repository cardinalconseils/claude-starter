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
