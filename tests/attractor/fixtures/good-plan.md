## Goal

Add attractor gate evaluation to the sprint pipeline so the auto-mode runner can score PLAN.md and VERIFICATION.md at each checkpoint and set `preferred_label` automatically when confidence is high.

## Context

The attractor runner (`skills/attractor/auto-decisions.yaml`) defines two gates: `review_plan` and `sprint_review`. Currently these gates are scored manually by the agent. This plan implements automated scoring via bash check_cmds so the runner can operate without human intervention at each hexagon node.

## Implementation Steps

1. **Create gate scorer script** (`scripts/attractor-gate-scorer.sh`)
   - Reads `PLAN.md` or `VERIFICATION.md` depending on gate name passed as `$1`
   - Runs each criterion's check_cmd and counts passes
   - Writes result JSON to `.attractor/gate-scores.json`
   - Exit 0 always (hooks must not block)

2. **Wire scorer into attractor runner** (`skills/attractor/SKILL.md`)
   - Add `gate_scorer` step before `preferred_label` is set
   - Call `scripts/attractor-gate-scorer.sh review_plan` at Plan node
   - Call `scripts/attractor-gate-scorer.sh sprint_review` at Verify node

3. **Update auto-decisions.yaml** (`skills/attractor/auto-decisions.yaml`)
   - Add `check_cmds` array to `review_plan` block with 4 bash one-liners
   - Add `check_cmds` array to `sprint_review` block with 5 bash one-liners
   - Preserve existing `pass_threshold`, `pass_label`, `fail_label` keys

4. **Add gate score to DEVLOG** (`hooks/handlers/session-start.sh`)
   - Read `.attractor/gate-scores.json` if present
   - Print last gate result in session banner: `Gate: review_plan → approved (4/4)`

5. **Write unit tests** (`tests/attractor/gate-scorer.bats`)
   - Test: good-plan fixture scores ≥3/4 → approved
   - Test: bad-plan fixture scores <3/4 → revise
   - Test: good-verification fixture scores ≥4/5 → approved
   - Test: bad-verification fixture scores <4/5 → iterate

## Acceptance Criteria

- [ ] `scripts/attractor-gate-scorer.sh review_plan` exits 0 for good-plan.md and sets `preferred_label=approved`
- [ ] `scripts/attractor-gate-scorer.sh review_plan` exits 0 for bad-plan.md and sets `preferred_label=revise`
- [ ] `scripts/attractor-gate-scorer.sh sprint_review` exits 0 for good-verification.md and sets `preferred_label=approved`
- [ ] `scripts/attractor-gate-scorer.sh sprint_review` exits 0 for bad-verification.md and sets `preferred_label=iterate`
- [ ] All 4 bats tests in `tests/attractor/gate-scorer.bats` pass
- [ ] `.attractor/gate-scores.json` is written after each scorer run
- [ ] Session banner shows last gate result when `.attractor/gate-scores.json` exists

## File References

| File | Change |
|------|--------|
| `scripts/attractor-gate-scorer.sh` | New — scorer script |
| `skills/attractor/auto-decisions.yaml` | Add `check_cmds` arrays |
| `skills/attractor/SKILL.md` | Wire scorer into gate nodes |
| `hooks/handlers/session-start.sh` | Print gate score in banner |
| `tests/attractor/gate-scorer.bats` | New — bats test suite |
| `tests/attractor/fixtures/good-plan.md` | New — fixture |
| `tests/attractor/fixtures/bad-plan.md` | New — fixture |
| `tests/attractor/fixtures/good-verification.md` | New — fixture |
| `tests/attractor/fixtures/bad-verification.md` | New — fixture |

## DoD

- Scorer script exists and is executable
- All 4 bats tests pass (`bats tests/attractor/gate-scorer.bats`)
- `auto-decisions.yaml` has `check_cmds` for both gates
- Session banner shows gate result when score file present
