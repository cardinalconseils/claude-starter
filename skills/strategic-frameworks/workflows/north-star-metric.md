<!-- Source: phuryn/pm-skills north-star-metric (MIT) — adapted for CKS -->

# North Star Metric — Facilitation Workflow

Read `skills/strategic-frameworks/workflows/north-star-metric.yaml` for business game types, 7 NSM criteria, and input metric template.

Read `skills/strategic-frameworks/output-schemas.yaml` for the `north_star_metric` output schema.

## Purpose

Identify one metric that best captures product value delivery to customers. Pair with 3-5 input metrics. Output: `.strategic-frameworks/north-star-{date}.yaml`. Patch CONTEXT.md `section_1h_success_metrics`.

## Facilitation Steps

### Step 1 — Business Game Type

Use AskUserQuestion:
- Options: Attention (time/engagement), Transaction (platform transactions), Productivity (work completion).
- Ask: "Which game does your product play? Where does core value get delivered?"
- Show examples from `north-star-metric.yaml` for each type.
- If unclear: "When a user succeeds with your product, what happened? Did they spend time, complete a transaction, or finish a task?"

### Step 2 — NSM Candidate Generation

Use AskUserQuestion:
- Ask: "Propose 2-3 candidate North Star Metrics. Each should follow the pattern for your game type."
- Attention pattern: "Daily/monthly active [behavior] sessions"
- Transaction pattern: "Transactions completed per [period]"
- Productivity pattern: "[Units of work] completed per user"

### Step 3 — Validate Against 7 Criteria

For the top candidate, use AskUserQuestion for each criterion:

1. **Easy to understand** — "Can a new team member grasp this metric in 30 seconds?"
2. **Customer centric** — "Does this measure value delivered to the customer, not internal efficiency?"
3. **Sustainable value** — "Does a higher number mean genuine long-term value, or could it be gamed?"
4. **Vision alignment** — "Does optimizing this move the product toward the stated vision?"
5. **Quantitative** — "Is this a single number, not a composite or ratio that obscures movement?"
6. **Actionable** — "Can teams run experiments that would move this number up or down?"
7. **Leading indicator** — "Does this predict revenue and retention, or lag them?"

Score: pass/fail per criterion. NSM must pass all 7 or be revised.

### Step 4 — Define Input Metrics

Use AskUserQuestion (repeat for 3-5 metrics):
- Ask: "Name an input metric that, if improved, would move the NSM. Assign a team owner."
- Template fields: metric_name, team_owner, current_value, target_value, measurement_cadence.
- Input metrics should collectively explain most NSM movement when summed.

### Step 5 — Confirm

Use AskUserQuestion:
- Show the complete NSM + input metric tree.
- Ask: "Does this accurately represent how your product creates value? Any metric missing or misattributed?"

## Output

Write to `.strategic-frameworks/north-star-{YYYY-MM-DD}.yaml`:

```yaml
framework: north_star_metric
date: {YYYY-MM-DD}
business_game_type: ""
north_star_metric: ""
north_star_definition: ""
criteria_validation:
  easy_to_understand: pass
  customer_centric: pass
  sustainable_value: pass
  vision_alignment: pass
  quantitative: pass
  actionable: pass
  leading_indicator: pass
input_metrics:
  - metric_name: ""
    team_owner: ""
    current_value: null
    target_value: null
    measurement_cadence: ""
```

Append to `.prd/PRD-STATE.md` Working Notes:
```
| north_star_run | {YYYY-MM-DD} | .strategic-frameworks/north-star-{YYYY-MM-DD}.yaml |
```

If CONTEXT.md exists, append NSM + input metrics to `section_1h_success_metrics`.
