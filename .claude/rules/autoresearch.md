---
# autoresearch Rules

Three carve-outs for the autonomous keep/discard loop.

## 1. Loop-Scope Consent (Destructive Ops Exception)

Standard rule: `.claude/rules/destructive-ops.md` requires a warning block before every `git reset --hard`.

Carve-out: When `autoresearch-runner` is running an active loop, the single consent block shown at start covers all in-loop `git reset --hard HEAD` operations. Per-iteration warnings are suppressed.

Conditions: reset target is HEAD only; reset is on `autoresearch/<tag>` branch only; user approved via AskUserQuestion at start; every reset is logged in results.tsv with `status=reset`.

Why: The loop runs overnight. Per-iteration prompts defeat the never-stop contract. User approved the loop knowing resets are the discard mechanism.

## 2. Branch Naming Exception

Standard rule: `.claude/rules/git-hygiene.md` requires `{issue-number}-short-description`.

Carve-out: `autoresearch/<tag>` branches are exempt. They are disposable experiment containers, not tied to GitHub issues. Expected lifecycle: review results.tsv → merge into feature branch or `git branch -D`.

## 3. Governance Log Coalescing (v2 note)

A 50-iteration loop generates 50 identical `git reset --hard` entries in `.cks/governance.json`. This is accepted noise for v1. Future fix: coalesce same `args_digest` within same `session_id` when `consecutive_identical >= 3`. Do not modify `governance-log.sh` now — track for G2 AHE Evolution Agent.
