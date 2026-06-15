# Source: https://github.com/phuryn/pm-skills (MIT) — adapted for CKS

# Business Model Canvas — Facilitation Workflow

Read `skills/strategic-frameworks/workflows/business-model-canvas.yaml` for block field definitions and good-answer criteria before starting.

Read `skills/strategic-frameworks/output-schemas.yaml` for the `business_model_canvas` output schema.

## Purpose

Map all 9 building blocks of a business model. Use when Lean Canvas is too narrow — BMC fits established products, scaling businesses, or multi-sided platforms. Output: `.strategic-frameworks/business-model-canvas-{date}.yaml`. Patch CONTEXT.md `section_1i_assumptions` and append PRD-STATE.md Working Notes row.

## When to Use BMC vs Lean Canvas

- **Lean Canvas**: early-stage startup, first idea validation, single problem/solution pair
- **BMC**: established product, scaling model, multi-sided platforms, when partnerships and key activities matter

## Facilitation Steps

### Block 1 — Customer Segments

Use AskUserQuestion:
- Ask: "Who are the customers? Name each segment — be specific about who they are and how they differ."
- Multi-sided: if the model serves multiple groups (e.g., buyers + sellers, advertisers + users), list all.
- Good answer: named segments with distinguishable behaviors or willingness-to-pay.

### Block 2 — Value Propositions

Use AskUserQuestion:
- Ask: "What value do you deliver to each customer segment? Which problem do you solve, and what job do you help them get done?"
- Per segment: one value proposition each. Not feature lists — outcomes.
- Good answer: "Helps [segment] achieve [outcome] without [friction]."

### Block 3 — Channels

Use AskUserQuestion:
- Ask: "How do you reach and deliver value to your customer segments? Map the channel to each segment."
- Phases: awareness → evaluation → purchase → delivery → after-sales.
- Good answer: specific channel per phase, not "social media."

### Block 4 — Customer Relationships

Use AskUserQuestion:
- Ask: "What type of relationship do you establish with each segment — self-serve, dedicated personal, community, automated?"
- Cost implications matter: high-touch is expensive. Match relationship type to segment LTV.

### Block 5 — Revenue Streams

Use AskUserQuestion:
- Ask: "How does each customer segment pay? What's the pricing mechanism?"
- Types: subscription, usage, licensing, transaction fee, advertising, freemium upsell.
- Good answer: mechanism + price point per segment.

### Block 6 — Key Resources

Use AskUserQuestion:
- Ask: "What assets are required to deliver your value propositions? Physical, intellectual, human, financial."
- Focus on what you must have — not what would be nice to have.

### Block 7 — Key Activities

Use AskUserQuestion:
- Ask: "What are the most important things the business must do to make the model work?"
- Types: production, problem-solving, platform/network management.

### Block 8 — Key Partnerships

Use AskUserQuestion:
- Ask: "Who are your key partners and suppliers? Why do you need them — to reduce risk, acquire resources, or perform activities?"
- Types: strategic alliances, joint ventures, buyer-supplier, co-opetition.

### Block 9 — Cost Structure

Use AskUserQuestion:
- Ask: "What are the most significant costs in this model? Which key resources and activities drive the most cost?"
- Types: fixed costs, variable costs, economies of scale, economies of scope.
- Is the model cost-driven (low price) or value-driven (premium)?

## Output

Write to `.strategic-frameworks/business-model-canvas-{YYYY-MM-DD}.yaml`:

```yaml
framework: business_model_canvas
date: {YYYY-MM-DD}
customer_segments: []
value_propositions: {}
channels: {}
customer_relationships: {}
revenue_streams: []
key_resources: []
key_activities: []
key_partnerships: []
cost_structure: {}
```

Append to `.prd/PRD-STATE.md` Working Notes:
```
| bmc_run | {YYYY-MM-DD} | .strategic-frameworks/business-model-canvas-{YYYY-MM-DD}.yaml |
```

If CONTEXT.md exists, append BMC summary to `section_1i_assumptions`.
