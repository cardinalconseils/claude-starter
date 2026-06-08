<!-- Source: phuryn/pm-skills lean-canvas (MIT) — adapted for CKS -->

# Lean Canvas — Facilitation Workflow

Read `skills/strategic-frameworks/workflows/lean-canvas.yaml` for section field definitions and good-answer criteria before starting.

Read `skills/strategic-frameworks/output-schemas.yaml` for the `lean_canvas` output schema.

## Purpose

Fill a one-page business model. 9 sections. Output: `.strategic-frameworks/lean-canvas-{date}.yaml`. Patch CONTEXT.md `section_1i_assumptions` and append PRD-STATE.md Working Notes row.

## Facilitation Steps

### Step 1 — Problem

Use AskUserQuestion:
- Ask: "What are the top 3 problems your target customers face? Describe observed behaviors, not assumed pain."
- Options: user describes or selects "I need help defining the problem" to trigger 5-Whys probing.
- Probe: if answer is vague or solution-framed, push back: "That sounds like a solution. What's the underlying friction the customer experiences?"

### Step 2 — Customer Segments

Use AskUserQuestion:
- Ask: "Who are your early adopters? Name a specific persona — job title, company size, observable behavior."
- Good answer: "Series A SaaS founder, 10-50 employees, currently tracks churn in spreadsheets."
- If generic ("small businesses"), ask: "Which type of small business? What do they do on a Tuesday when this problem hits?"

### Step 3 — Unique Value Proposition

Use AskUserQuestion:
- Ask: "In one sentence, why is your solution different and worth switching to?"
- Criterion: must be in customer language, not feature language. "Faster" is not a UVP without a number.

### Step 4 — Solution

Use AskUserQuestion:
- Ask: "What are the top 3 features that solve each of the 3 problems?"
- Constrain: minimum viable only. If list exceeds 3 items, force prioritization.

### Step 5 — Channels

Use AskUserQuestion:
- Ask: "How do you reach your early adopters? Name the specific channel and estimate acquisition cost."
- Options: direct sales, content/SEO, paid ads, product-led, partnerships, community, other.

### Step 6 — Revenue Streams

Use AskUserQuestion:
- Ask: "How do you make money? What's the pricing model and estimated LTV per customer?"
- Probe: if pricing is unclear, ask "What would a customer pay today to have this problem solved?"

### Step 7 — Cost Structure

Use AskUserQuestion:
- Ask: "What are your fixed and variable costs? Estimate monthly burn at launch."
- Categories: infra, salaries, marketing, tooling, support.

### Step 8 — Key Metrics

Use AskUserQuestion:
- Ask: "What 1-3 numbers tell you the business is working? These should be leading indicators, not vanity metrics."
- Red flags: page views, signups without activation. Good: activated users, revenue, retention week 4.

### Step 9 — Unfair Advantage

Use AskUserQuestion:
- Ask: "What do you have that competitors cannot easily copy or buy?"
- Options: proprietary data, network effects, community, founder insight, IP, exclusive partnerships, other.
- If answer is "we're faster to market" — that is NOT an unfair advantage. Push back.

## Output

Write to `.strategic-frameworks/lean-canvas-{YYYY-MM-DD}.yaml`:

```yaml
framework: lean_canvas
date: {YYYY-MM-DD}
problem: []
solution: []
uvp: ""
unfair_advantage: ""
customer_segments: []
channels: []
revenue_streams: []
cost_structure: {}
key_metrics: []
```

Append to `.prd/PRD-STATE.md` Working Notes:
```
| lean_canvas_run | {YYYY-MM-DD} | .strategic-frameworks/lean-canvas-{YYYY-MM-DD}.yaml |
```

If CONTEXT.md exists, append Lean Canvas summary to `section_1i_assumptions`.
