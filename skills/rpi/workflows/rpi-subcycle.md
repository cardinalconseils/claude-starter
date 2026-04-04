# Workflow: R-P-I Sub-Cycle

<purpose>
Step-by-step gate check procedures, iteration refresh logic, and status display format
for the Research-Plan-Implement sub-cycle within any CKS lifecycle phase.
</purpose>

## Gate Check Procedure: R→P (Research → Plan)

### Step 1: Scan for Research Artifacts

```
1. Read .prd/PRD-STATE.md → extract {NN} and {name}
2. Check: .prd/phases/{NN}-{name}/{NN}-RESEARCH.md exists?
3. Check: .context/*.md files exist for technologies in the feature brief?
4. Check: .research/*/report.md exists for the feature's domain?
```

### Step 2: Evaluate Gate

```
IF any research artifact exists:
  → R→P gate: PASS
  → Log: "R→P gate passed — {list artifacts found}"
  → Proceed to Plan sub-stage

IF no research artifacts exist:
  → R→P gate: FAIL
  → Message to user:
    "R→P gate blocked: No research artifacts found for phase {NN}-{name}.
     Missing: technology briefs (.context/), research reports (.research/),
     or feature research ({NN}-RESEARCH.md).
     Run: /cks:context '{technology}' or /cks:research '{topic}'"
  → Do NOT proceed to Plan
```

### Skip Condition

If the feature involves only internal refactoring with no external technologies:
```
→ R→P gate: SKIP:trivial
→ Log: "R→P gate skipped — no external technologies involved"
→ Justification must be documented in PLAN.md header
```

### Concrete Example: R→P Gate Check

**Scenario:** Phase 03 — "Add Stripe Payment Integration"

**Check:**
```
.prd/phases/03-stripe-payments/03-RESEARCH.md  → NOT FOUND
.context/stripe.md                              → NOT FOUND
.context/webhooks.md                            → FOUND (from prior feature)
.research/payment-providers/report.md           → NOT FOUND
```

**Result:** FAIL — `.context/webhooks.md` exists but is not specific to Stripe. No Stripe-specific research found.

**Message:**
```
R→P gate blocked: No research artifacts found for Stripe integration.
Run: /cks:context "stripe" to research the Stripe API.
```

**After user runs `/cks:context "stripe"`:**
```
.context/stripe.md  → FOUND
```

**Re-check result:** PASS — technology brief exists for Stripe.

---

## Gate Check Procedure: P→I (Plan → Implement)

### Step 1: Scan for Plan Artifacts

```
1. Read .prd/PRD-STATE.md → extract {NN} and {name}
2. Check: .prd/phases/{NN}-{name}/{NN}-PLAN.md exists?
3. If exists, check: PLAN.md contains "### Task" sections?
4. If exists, check: PLAN.md contains "## Acceptance Criteria" with items?
```

### Step 2: Evaluate Gate

```
IF PLAN.md exists AND has tasks AND has acceptance criteria:
  → P→I gate: PASS
  → Log: "P→I gate passed — {N} tasks, {N} acceptance criteria"
  → Proceed to Implement sub-stage

IF PLAN.md missing:
  → P→I gate: FAIL
  → Message: "P→I gate blocked: No execution plan found.
     Run /cks:sprint to generate the execution plan."

IF PLAN.md exists but has no tasks:
  → P→I gate: FAIL
  → Message: "P→I gate blocked: PLAN.md has no task sections.
     The plan needs at least one ### Task with file scopes."

IF PLAN.md exists but has no acceptance criteria:
  → P→I gate: FAIL
  → Message: "P→I gate blocked: PLAN.md has no acceptance criteria.
     Add an ## Acceptance Criteria section with testable criteria."
```

---

## Iteration Refresh Logic

When `iteration_count > 0` in PRD-STATE.md:

### Step 1: Detect Iteration Context

```
1. Read .prd/PRD-STATE.md → check iteration_count
2. If iteration_count = 0 → skip (first pass, no refresh needed)
3. If iteration_count > 0 → enter refresh mode
4. Read .prd/phases/{NN}-{name}/{NN}-REVIEW.md for iteration feedback
```

### Step 2: Refresh Research Artifacts

```
1. Re-run context research for ALL technologies (even if .context/ briefs exist)
   → This overwrites stale briefs with fresh data
2. If REVIEW.md feedback mentions technology issues:
   → Flag .research/ reports for that technology as "needs manual refresh"
   → Suggest: /cks:research "{topic}" --refresh
3. If {NN}-RESEARCH.md exists:
   → Mark as stale, dispatch prd-researcher to update
```

### Step 3: Re-evaluate Gates

Both R→P and P→I gates re-run against refreshed artifacts before the iteration plan is created.

---

## Status Display Format

When `/cks:rpi` is invoked, display:

```
R-P-I Sub-Cycle Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Phase:     {NN} — {name}
  Lifecycle: {phase_status} (Phase {1-5})

  Research:  {done|pending|refresh-needed}
    {list artifacts found, or "none"}

  R→P Gate:  {PASS|FAIL|SKIP:trivial}
    {if FAIL: what's missing}

  Plan:      {done|pending}
    {list artifacts found, or "none"}

  P→I Gate:  {PASS|FAIL}
    {if FAIL: what's missing}

  Implement: {done|pending|in-progress}
    {list artifacts found, or "none"}

  Sub-Stage: {Research|Plan|Implement|Complete}
  Next:      {suggested action}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Status Derivation Logic

```
1. Scan .prd/phases/{NN}-{name}/ for:
   - {NN}-RESEARCH.md, .context/*.md, .research/*/report.md → Research status
   - {NN}-PLAN.md with tasks + acceptance criteria         → Plan status
   - {NN}-VERIFICATION.md with PASS verdict                → Implement status

2. Determine current sub-stage:
   - No research artifacts → "Research" (suggest /cks:context or /cks:research)
   - Research done, no plan → "Plan" (suggest /cks:sprint)
   - Plan done, no verification → "Implement" (suggest /cks:sprint)
   - Verification PASS → "Complete" (suggest /cks:review or /cks:release)

3. Check iteration_count:
   - If > 0 and research artifacts are from before the iteration → "refresh-needed"
```
