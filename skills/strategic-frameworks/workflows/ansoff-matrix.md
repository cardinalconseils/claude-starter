<!-- Source: phuryn/pm-skills ansoff-matrix (MIT) — adapted for CKS -->

# Ansoff Matrix — Facilitation Workflow

Read `skills/strategic-frameworks/workflows/ansoff-matrix.yaml` for 4 quadrant definitions, risk levels, timelines, and tactic lists.

Read `skills/strategic-frameworks/output-schemas.yaml` for the `ansoff_matrix` output schema.

## Purpose

Identify growth quadrant, map tactics to timeline. One quadrant at a time — principle: excel before expanding. Output: `.strategic-frameworks/ansoff-{date}.yaml`. Patch CONTEXT.md `section_1i_assumptions`.

## Facilitation Steps

### Step 1 — Current Position

Use AskUserQuestion:
- Ask: "Describe your current product and your current market. Be specific: what product, which customer segment, what geography?"
- This anchors the 2×2 grid before presenting quadrant choices.

### Step 2 — Choose Growth Quadrant

Use AskUserQuestion with 4 options:
1. **Market Penetration** — same product, same market. Low risk, 6-12 months. Grow share from existing customers and competitors.
2. **Market Development** — same product, new market. Medium risk, 12-24 months. New geography, segment, or channel.
3. **Product Development** — new product, same market. Medium risk, 12-18 months. New features, adjacent product, bundles.
4. **Diversification** — new product, new market. High risk, 24+ months. Acquisition or new business unit.

Ask: "Which quadrant best describes your intended growth move?"

### Step 3 — Validate the Choice

Use AskUserQuestion:
- Ask: "Before committing: have you fully saturated the lower-risk quadrants? What evidence do you have?"
- Market Penetration should be exhausted before Market Development or Product Development.
- Diversification should only follow demonstrated success in at least two other quadrants.
- If premature: surface the concern. Let the user decide — do not override.

### Step 4 — Map Tactics to Timeline

For the chosen quadrant, use AskUserQuestion (reference `ansoff-matrix.yaml` for tactic list):
- Ask: "Which tactics from the [quadrant] playbook apply to your situation? Select 2-4."
- Show tactic list from YAML.
- Ask: "For each selected tactic, what's the first concrete action in the next 30 days?"

### Step 5 — Risk Acceptance

Use AskUserQuestion:
- Show risk level and timeline from YAML.
- Ask: "Given the risk level ([low/medium/high]) and timeline ([N] months), is this the right quadrant given your current resources and runway?"
- If mismatch: surface. Let user decide to proceed or reconsider.

## Output

Write to `.strategic-frameworks/ansoff-{YYYY-MM-DD}.yaml`:

```yaml
framework: ansoff_matrix
date: {YYYY-MM-DD}
current_product: ""
current_market: ""
chosen_quadrant: market_penetration|market_development|product_development|diversification
risk_level: low|medium|high
timeline: ""
tactics:
  - tactic: ""
    first_action_30d: ""
rationale: ""
```

Append to `.prd/PRD-STATE.md` Working Notes:
```
| ansoff_run | {YYYY-MM-DD} | .strategic-frameworks/ansoff-{YYYY-MM-DD}.yaml |
```

If CONTEXT.md exists, append chosen quadrant and rationale to `section_1i_assumptions`.
