# Source: https://github.com/phuryn/pm-skills (MIT) — adapted for CKS

# Assumption Mapping — Facilitation Workflow

Read `skills/strategic-frameworks/workflows/assumption-mapping.yaml` for scoring definitions before starting.

Read `skills/strategic-frameworks/output-schemas.yaml` for the `assumption_mapping` output schema.

## Purpose

Surface and prioritize the riskiest assumptions before committing to PLAN.md or GTM execution. Forces the team to distinguish between what they know and what they're guessing. Output: `.strategic-frameworks/assumption-mapping-{date}.yaml`. Patch PLAN.md Risk Notes and append PRD-STATE.md Working Notes row.

## When to Run

- Before writing PLAN.md when CONTEXT.md contains 2+ mentions of "assumption," "hypothesis," or "we think"
- Before GTM-BRIEF.md to surface riskiest launch assumptions
- Any time a decision relies on unvalidated beliefs about customers, technology, or business model

## Facilitation Steps

### Step 1 — Collect Assumptions

Use AskUserQuestion:
- Ask: "List every assumption this plan relies on. Don't filter — include obvious ones and gut feelings."
- Seed with common assumption categories if the user is stuck:
  - **Customer:** "We believe customers have this problem at this frequency"
  - **Solution:** "We believe our solution solves it better than alternatives"
  - **Business:** "We believe customers will pay this price"
  - **Technical:** "We believe this approach is feasible with current team/stack"
  - **Market:** "We believe this market is large enough / growing fast enough"
- Minimum: 5 assumptions. If fewer, prompt for more — under-assumption is under-thinking.

### Step 2 — Score Each Assumption

For each assumption, score two dimensions:

**Impact** (1–5): If this assumption is wrong, how badly does the plan fail?
- 5 = the entire initiative collapses
- 3 = major rework required
- 1 = minor inconvenience

**Evidence** (1–5): How much validated evidence supports this assumption?
- 5 = confirmed by data / user research / signed contracts
- 3 = anecdotal signals / early interviews
- 1 = pure speculation / no evidence

**Risk Score** = Impact × (5 − Evidence). Higher score = riskiest assumption.

### Step 3 — Classify and Prioritize

Sort by Risk Score descending. Classify:

| Class | Condition | Action |
|-------|-----------|--------|
| **Leap of Faith** | Impact ≥ 4, Evidence ≤ 2 | Must validate before commit — this is a bet-the-plan assumption |
| **Watch** | Impact 3–4, Evidence 3–4 | Validate during sprint — add to CONTEXT.md risk section |
| **Validated** | Evidence ≥ 4 | Record the evidence — no further action needed |
| **Low Stakes** | Impact ≤ 2 | Acknowledge and proceed — not worth validation investment |

### Step 4 — Validation Action Plan

For each "Leap of Faith" assumption:

Use AskUserQuestion:
- Ask: "How can we validate [assumption] before committing? What's the smallest test?"
- Options: customer interview, landing page test, technical spike, competitive research, expert call.
- Assign: owner, deadline, success criteria.

### Step 5 — Risk Notes for PLAN.md

Summarize in PLAN.md Risk Notes section:
- List top 3 assumptions by Risk Score
- State the validation action and deadline for each Leap of Faith assumption
- Explicitly note: "This plan proceeds with the following unvalidated assumptions: [list]"

## Output

Write to `.strategic-frameworks/assumption-mapping-{YYYY-MM-DD}.yaml`:

```yaml
framework: assumption_mapping
date: {YYYY-MM-DD}
assumptions:
  - id: A1
    statement: ""
    category: customer | solution | business | technical | market
    impact: 1-5
    evidence: 1-5
    risk_score: 0
    class: leap_of_faith | watch | validated | low_stakes
    validation_action: ""
    owner: ""
    deadline: ""
leaps_of_faith: []
risk_notes: ""
```

Append to `.prd/PRD-STATE.md` Working Notes:
```
| assumption_mapping_run | {YYYY-MM-DD} | .strategic-frameworks/assumption-mapping-{YYYY-MM-DD}.yaml |
```

If PLAN.md exists, patch the Risk Notes section with top 3 assumptions by Risk Score.
