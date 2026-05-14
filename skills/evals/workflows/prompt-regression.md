# Prompt Regression Eval Workflow

Detect silent quality regressions after prompt changes. A golden set of input/expected-output pairs that must continue to pass.

## What It Is

A versioned library of cases that define "this is what correct behavior looks like." Run after any prompt edit. A drop in pass rate = regression.

Can't rely on eyeballing — prompts often look fine and subtly degrade on edge cases. Golden set catches it.

## Golden Set Structure

```
.evals/golden/{feature-name}/
  case-001/
    input.json        — the input to the feature
    expected.md       — expected prose output (or expected.json for structured)
    metadata.json     — tier, eval_type, tags, added_date, added_reason
  case-002/
    ...
  judge-prompt.md     — the LLM-as-judge prompt for this feature
```

`metadata.json` shape:
```json
{
  "tier": "smoke|standard|comprehensive",
  "eval_type": "regression",
  "tags": ["happy-path", "edge-case", "past-bug"],
  "added_date": "2026-01-15",
  "added_reason": "Bug: model dropped the summary bullet when input >500 tokens"
}
```

Commit `.evals/golden/` to git. Regressions are trackable across PRs via git diff.

## Smoke Tier (3–5 cases)

Your "can't break this" list. The 3–5 behaviors that are absolutely load-bearing.

Criteria for smoke inclusion:
- Failure would be immediately visible to users
- Case covers the single most important feature behavior
- Previously caused a production incident

## Standard Tier (15–25 cases)

Full happy path + known edge cases from past bugs.

Build up incrementally:
- Start: copy your smoke cases
- Add: one case per major edge case
- Add: one case per production bug fixed (add_reason = bug reference)
- Target: 15–25 covering all known-fragile paths

## Comprehensive Tier (50–100+ cases)

Exhaustive regression library. Every failure ever seen becomes a case.

Rule: **every time a bug is fixed, add a case.** Never remove cases (mark obsolete instead with `"active": false` in metadata).

## Scoring

**Prose outputs** (use LLM-as-judge):
- Compare actual output to `expected.md` using judge prompt
- Judge evaluates semantic equivalence, not string match
- Score 0–1 per case; case passes if score ≥ threshold

**Structured outputs** (exact/schema match):
- Parse actual output against `expected.json` schema
- Binary pass/fail
- Field-level diffs reported for partial matches

**Tier pass/fail**:
- Score = % of cases above threshold
- Smoke: 100% must pass
- Standard: ≥ 95% must pass
- Comprehensive: ≥ 90% must pass (some churn acceptable at scale)

## When to Update Golden Set vs Treat as Regression

**Update golden** (intentional change):
- Deliberate prompt change with reviewed expected behavior
- Model version upgrade where behavior differences are known and acceptable
- Product decision to change feature behavior

Process: PR with golden set changes must include a comment explaining WHY expected behavior changed. Reviewer must approve the behavior change, not just the code.

**Treat as regression** (must fix):
- Unexpected score drop ≥ 5% on any tier
- Any specific case that previously passed now fails without an intentional prompt change
- Score drop correlated with a dependency update (model version, library version)

## Workflow

```
1. Run evals against current golden set
2. Compare scores to last known-good baseline (stored in .evals/baseline.json)
3. Flag any case where score dropped
4. Author decides: is this an intentional change or a regression?
5. If regression: fix prompt, re-run, confirm case passes before merge
6. If intentional: update golden set in same PR with explanation
7. Commit golden changes; baseline.json updates automatically on clean run
```

Never merge a PR where regression evals show unexpected failures. The golden set is the source of truth.

## Integration

- `.evals/golden/` committed to git
- Eval run produces `.evals/results/{timestamp}.json`
- Baseline stored at `.evals/baseline.json` (last clean comprehensive run)
- CI runs smoke tier; PR check runs standard tier; release gate runs comprehensive
