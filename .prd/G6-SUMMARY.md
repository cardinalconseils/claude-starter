# Execution Summary: G6 — Harness Eval Framework

**Date:** 2026-06-08
**Status:** Complete

## Changes Made

### Files Created
- `commands/harness-eval.md` — thin dispatcher for `/cks:harness-eval`, parses `--hook` and `--tier` args, dispatches `cks:harness-eval-runner`
- `agents/harness-eval-runner.md` — 5-step eval loop (discover → load → run fixture → score → report+write), CRITICAL write-scope constraint enforced
- `skills/harness-evals/SKILL.md` — domain knowledge: fixture anatomy, golden corpus structure, scoring, G2 consumer contract, when to add cases
- `skills/harness-evals/workflows/hook-fixture-runner.md` — step-by-step bash mechanics: case discovery, temp-file-based invocation (avoids subshell exit-code loss), pattern matching, scaffold template, result JSON shape
- `.claude/rules/harness-evals.md` — mandatory rules: write-scope constraint, routing separation from evals-runner, golden case content rules, results gitignore, manual verify-before-commit
- `.harness-evals/golden/README.md` — corpus structure docs + worked examples for `destructive-op-guard` (both rm-rf-blocked and safe-command cases)

### Files Modified
- `commands/help.md` — added `/cks:harness-eval` line in QUALITY section near `/cks:evals`
- `commands/README.md` — incremented count 123 → 124
- `.gitignore` — added `.harness-evals/results/` (golden cases committed; results are per-dev)

## Acceptance Criteria Check

- [x] All 6 primary files created
- [x] No TODO/FIXME/HACK/XXX markers in created files (mktemp `XXXXXX` is not a marker)
- [x] `grep "harness-eval" commands/help.md` returns match
- [x] `grep "harness-evals/results" .gitignore` returns match
- [x] `wc -l commands/harness-eval.md` = 47 (under 60)
- [x] `destructive-op-guard.sh` exits 2 for `rm -rf` — verified with `printf '%s\n' '{"command":"rm -rf /tmp/test"}' | bash hooks/handlers/destructive-op-guard.sh; echo "exit: $?"` → exit: 2

## Implementation Notes

**Hook input format discovery:** `destructive-op-guard.sh` reads `.command` from the TOP-LEVEL JSON input (not `.tool_input.command`). It also writes its warning block to STDOUT (not stderr). The golden case README and skill were corrected to reflect this — `stdout_pattern` is the right field for asserting on this handler's output.

**Write-scope constraint:** Enforced in both the agent system prompt and `.claude/rules/harness-evals.md` — agent may only write to `.harness-evals/`. All hook/agent/command files are READ-ONLY.

**Separation from /cks:evals:** Explicitly called out in rules, skill, and agent prompt. These test shell determinism, not LLM quality.

**Temp files for stderr capture:** Workflow uses `mktemp` for both stdout and stderr to preserve `$?` in parent shell — avoids the classic `$(...)` subshell exit-code loss pattern.
