# Sub-step [3g]: Merge to Main

<context>
Phase: Sprint (Phase 3)
Requires: UAT approved ([3f])
Produces: Git commit + PR
</context>

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3g.started" "{NN}-{name}" "Sprint: merge to main started"`

## Instructions

The sprint produces a **potentially shippable increment**.

### First Sprint — Standard Commit

1. Stage and commit changes:
```bash
git add -A
git commit -m "$(cat <<'EOF'
feat(phase-{NN}): {phase name}

Phase {NN} of PRD-{NNN}: {feature name}
- {key change 1}
- {key change 2}

Acceptance: {X}/{Y} criteria verified
QA: unit ✓ integration ✓ E2E ✓
UAT: {N}/{M} scenarios passed

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

2. Create PR (but do NOT deploy — that's Phase 5):
```bash
gh pr create --title "PRD-{NNN}: {Feature Title}" --body "$(cat <<'EOF'
## Summary
{from SUMMARY.md}

## Verification
- [x] QA: {X}/{Y} acceptance criteria passed
- [x] UAT: {N}/{M} scenarios passed
- [x] Code review: {status}

## Design Reference
Screens: .prd/phases/{NN}-{name}/design/screens/

---
*Sprint complete — awaiting Phase 4 (Review) before release*
EOF
)"
```

### Iteration Sprint — Iteration Commit

1. Stage and commit changes:
```bash
git add -A
git commit -m "$(cat <<'EOF'
fix(phase-{NN}): {phase name} — Iteration #{iteration}

Phase {NN} of PRD-{NNN}: {feature name} — Iteration #{iteration}
Reason: {iteration_reason from STATE.md}
- {backlog item 1 addressed}
- {backlog item 2 addressed}

Backlog: {N}/{M} items resolved
QA: unit ✓ integration ✓ E2E ✓

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

2. Create PR:
```bash
gh pr create --title "PRD-{NNN}: {Feature Title} — Iteration #{iteration}" --body "$(cat <<'EOF'
## Summary — Iteration #{iteration}
{from SUMMARY-iter{iteration}.md}

**Iteration reason:** {iteration_reason}

## Backlog Items Addressed
{from PLAN-iter{iteration}.md — checklist of items}

## Verification
- [x] QA: {X}/{Y} acceptance criteria passed
- [x] Backlog: {N}/{M} items resolved
- [x] Code review: {status}

## Iteration History
| # | Reason | Items | Status |
|---|--------|-------|--------|
{for each iteration: number, reason, item count, resolved/partial}

---
*Iteration #{iteration} complete — awaiting Phase 4 (Review)*
EOF
)"
```

```
  [3g] Merge to Main          ✅ PR #{number} — {url} {iteration ? "(Iteration #"+iteration+")" : ""}
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3g.completed" "{NN}-{name}" "Sprint: merge to main complete"`
