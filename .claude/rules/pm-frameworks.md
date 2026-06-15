# PM Frameworks Rules

## Mandatory Behavior

When a user description, CONTEXT.md draft, ideation pitch, or PLAN.md contains a PM framework signal, the running agent MUST engage the appropriate `strategic-frameworks` workflow. This is not a suggestion — trigger pattern match = mandatory engagement.

Two modes: **deterministic** (blocking, AskUserQuestion required before proceeding) and **indeterministic** (agent-guided, applies the best-fit framework from context without interrupting the user).

## Trigger Patterns

Match is case-insensitive. Any single match is sufficient to trigger.

**Business model**
- `business model canvas`, `BMC`, `customer segments`, `revenue streams`, `key partners`, `key activities`, `key resources`, `cost structure`
- `lean canvas`, `value proposition`, `unfair advantage`, `early adopters`

**Competitive analysis**
- `five forces`, `porter`, `competitive forces`, `industry analysis`, `buyer power`, `supplier power`, `market attractiveness`, `competitive moat`

**Market and macro environment**
- `PESTLE`, `PEST analysis`, `macro environment`, `external factors`, `regulatory landscape`, `market entry`, `political risk`, `economic factors`

**Growth strategy**
- `ansoff`, `growth strategy`, `market penetration`, `market development`, `product development`, `diversification`, `expansion options`

**Outcome-first discovery**
- `opportunity solution tree`, `OST`, `continuous discovery`, `opportunity space`, `outcome-first`, `desired outcome`

**Risk and assumptions**
- `assumption mapping`, `riskiest assumptions`, `assumption prioritization`, `validate assumptions`, `hypothesis map`, `leap of faith`, `pre-mortem`, `risk assumptions`

## Deterministic Behavior (Mandatory — Cannot Skip)

### Phase 1 [Discover] — Framework Selection Gate

**When:** prd-discoverer or kickstart-ideator detects a trigger pattern in the user's description or CONTEXT.md draft.

**What MUST happen:**
1. Identify which framework category matched (business model / competitive / market / growth / discovery / risk)
2. Call AskUserQuestion:

```
question: "A PM framework signal was detected. Apply a framework to structure this discovery?"
header: "PM Framework"
options:
  - label: "{Best-fit framework}" (Recommended)
    description: "{One-line rationale — why this framework fits this signal}"
  - label: "Apply multiple"
    description: "Run 2–3 frameworks in sequence (slower but more complete)"
  - label: "Skip framework"
    description: "Proceed with standard 11-element discovery"
```

3. If user selects a framework: read the corresponding workflow file from `skills/strategic-frameworks/workflows/` and execute it BEFORE writing CONTEXT.md
4. If user selects "Skip": proceed normally — do NOT loop back to the framework question
5. Framework output patches `section_1i_assumptions` in CONTEXT.md per the workflow's Output section

**Cannot skip:** if trigger matched and user has not been asked, the agent MUST ask before writing CONTEXT.md. Silent omission is a rule violation.

### Phase 2 [Plan] — Assumption Mapping Gate

**When:** prd-planner is about to write PLAN.md AND CONTEXT.md contains `assumption` or `hypothesis` at ≥2 distinct locations.

**What MUST happen:**
1. Read `skills/strategic-frameworks/workflows/assumption-mapping.md`
2. Execute the Assumption Mapping workflow — Step 1 through Step 5
3. Patch PLAN.md Risk Notes with the top 3 assumptions by Risk Score
4. Include Leap of Faith validation actions with owners and deadlines in Risk Notes
5. Append to `.prd/PRD-STATE.md` Working Notes

**Cannot skip:** PLAN.md Risk Notes must contain assumption mapping output. "We have assumptions but didn't map them" is not a valid plan.

## Indeterministic Behavior (Agent-Guided)

When no trigger pattern is detected but the agent's context suggests a framework would add value:

- **kickstart-ideator after ideation completes:** agent selects Lean Canvas (early-stage) or BMC (established/scaling) based on the refined pitch's maturity signal. No AskUserQuestion required — agent applies judgment and surfaces the output as a natural next step.
- **prd-researcher during competitive research:** agent applies Porter's Five Forces or PESTLE when competitive landscape or market entry is the research focus. No blocking gate — findings are included in the research report.
- **prd-discoverer during customer segment definition:** agent uses OST opportunity scoring (Importance × (1 − Satisfaction)) to rank discovered opportunities. Applied inline during Element 2 (User Stories) gathering.

## Framework → Workflow Reference

| Framework | Trigger category | Workflow file |
|---|---|---|
| Lean Canvas | business model | `skills/strategic-frameworks/workflows/lean-canvas.md` |
| Business Model Canvas | business model (scaling) | `skills/strategic-frameworks/workflows/business-model-canvas.md` |
| Opportunity Solution Tree | discovery | `skills/strategic-frameworks/workflows/opportunity-solution-tree.md` |
| Pre-Mortem | risk | `skills/strategic-frameworks/workflows/pre-mortem.md` |
| PESTLE | market/macro | `skills/strategic-frameworks/workflows/pestle-analysis.md` |
| Ansoff Matrix | growth | `skills/strategic-frameworks/workflows/ansoff-matrix.md` |
| Porter's Five Forces | competitive | `skills/strategic-frameworks/workflows/porters-five-forces.md` |
| North Star Metric | discovery | `skills/strategic-frameworks/workflows/north-star-metric.md` |
| Assumption Mapping | risk (mandatory at Phase 2) | `skills/strategic-frameworks/workflows/assumption-mapping.md` |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Discovery is going fine without a framework" | Trigger matched = framework required at Phase 1. AskUserQuestion costs 30 seconds; a wrong direction costs 3 weeks. |
| "Assumption mapping is for lean startups" | Every feature has assumptions. Surface them at planning, not post-launch when fixing them costs 10× more. |
| "Porter's Five Forces is too academic" | Structured buyer/supplier leverage analysis before contracts. 20 minutes now vs months of renegotiation. |
| "We'll do competitive analysis after we build" | PESTLE/Porter's at discovery reveals market blockers before build cost accumulates. Insight cost: zero. Fix cost: sprint. |
| "The user didn't ask for a framework" | Framework signals in descriptions are implicit requirements. Surface them — the user can skip. |
