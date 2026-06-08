<!-- Source: phuryn/pm-skills porters-five-forces (MIT) — adapted for CKS -->

# Porter's Five Forces — Facilitation Workflow

Read `skills/strategic-frameworks/workflows/porters-five-forces.yaml` for all 5 forces, assessment factors, and rating schema.

Read `skills/strategic-frameworks/output-schemas.yaml` for the `porters_five_forces` output schema.

## Purpose

Assess competitive intensity across 5 forces. Rate each High/Med/Low. Identify top 2-3 critical forces. Derive positioning opportunities. Output: `.strategic-frameworks/porters-{date}.yaml`. Patch CONTEXT.md `section_1e_constraints`.

## Facilitation Steps

Walk each force. For each: assess relevant factors, rate intensity (high/medium/low), note the implication.

### Step 1 — Competitive Rivalry

Use AskUserQuestion:
- Ask: "How intense is direct competition in your market? Consider: number of competitors, market growth rate, how differentiated products are, and switching costs for customers."
- Rate: high (many competitors, low differentiation, stagnant market) / medium / low (few competitors, high differentiation, growing market).
- Implication: high rivalry = price pressure, high marketing spend required.

### Step 2 — Supplier Power

Use AskUserQuestion:
- Ask: "How much leverage do your key suppliers have? Consider: are there few suppliers you depend on? High switching costs? Can they integrate forward and compete with you?"
- Rate: high (few suppliers, high dependency) / medium / low (many substitutes, easy switching).
- Implication: high supplier power = margin risk, lock-in risk.

### Step 3 — Buyer Power

Use AskUserQuestion:
- Ask: "How much leverage do your customers have? Consider: buyer concentration (a few big accounts vs many small), purchase volume, how price-sensitive they are, and how easily they switch."
- Rate: high (concentrated buyers, high price sensitivity) / medium / low (fragmented buyers, sticky product).
- Implication: high buyer power = pricing pressure, churn risk.

### Step 4 — Threat of Substitutes

Use AskUserQuestion:
- Ask: "Can customers solve the same problem without buying from you? What substitutes exist — different product categories, workarounds, manual processes?"
- Rate: high (many cheap substitutes available) / medium / low (no viable alternative).
- Implication: high substitute threat = ceiling on pricing, need for strong differentiation.

### Step 5 — Threat of New Entrants

Use AskUserQuestion:
- Ask: "How easy is it for a new competitor to enter your market? Consider: capital requirements, regulatory barriers, economies of scale, brand loyalty required."
- Rate: high (low barriers, cheap to enter) / medium / low (high capital, regulation, or brand moat required).
- Implication: high entrant threat = market share at risk, need for defensible moat.

### Step 6 — Critical Forces and Positioning

After all 5 forces:
- Use AskUserQuestion: "Which 2-3 forces pose the greatest risk to your business today?"
- For each critical force: "What is your positioning move to reduce exposure? Differentiation, niche focus, vertical integration, switching cost creation?"
- Derive overall attractiveness: count of High forces = low attractiveness, count of Low forces = high attractiveness.

## Output

Write to `.strategic-frameworks/porters-{YYYY-MM-DD}.yaml`:

```yaml
framework: porters_five_forces
date: {YYYY-MM-DD}
competitive_rivalry:
  rating: high|medium|low
  key_factors: []
  implication: ""
supplier_power:
  rating: high|medium|low
  key_factors: []
  implication: ""
buyer_power:
  rating: high|medium|low
  key_factors: []
  implication: ""
threat_substitutes:
  rating: high|medium|low
  key_factors: []
  implication: ""
threat_entrants:
  rating: high|medium|low
  key_factors: []
  implication: ""
overall_attractiveness: high|medium|low
critical_forces: []
positioning_opportunities: []
```

Append to `.prd/PRD-STATE.md` Working Notes:
```
| porters_run | {YYYY-MM-DD} | .strategic-frameworks/porters-{YYYY-MM-DD}.yaml |
```

If CONTEXT.md exists, append critical forces and positioning opportunities to `section_1e_constraints`.
