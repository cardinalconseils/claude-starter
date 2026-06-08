<!-- Source: phuryn/pm-skills pestle-analysis (MIT) — adapted for CKS -->

# PESTLE Analysis — Facilitation Workflow

Read `skills/strategic-frameworks/workflows/pestle-analysis.yaml` for all 6 dimensions, sub-factors, and impact/probability schema.

Read `skills/strategic-frameworks/output-schemas.yaml` for the `pestle_analysis` output schema.

## Purpose

Macro-environment scan. 6 dimensions. 3-5 factors each. Assess impact × probability. Derive strategic responses. Output: `.strategic-frameworks/pestle-{date}.yaml`. Patch CONTEXT.md `section_1e_constraints`.

## Facilitation Steps

Walk each dimension in order. For each: surface 3-5 relevant factors, assess impact (high/medium/low) and probability (likely/possible/unlikely), prioritize top factors.

### Step 1 — Political

Use AskUserQuestion:
- Ask: "Which political factors affect your market? Consider: government policies, tax structures, political stability, trade agreements, licensing requirements."
- For each factor named, ask: "Impact: high/medium/low? Probability: likely/possible/unlikely?"
- Probe: "Are there regulatory changes pending that could block or accelerate your go-to-market?"

### Step 2 — Economic

Use AskUserQuestion:
- Ask: "Which economic conditions affect your target customers' willingness or ability to buy? Consider: GDP trends, inflation, interest rates, consumer spending patterns."
- Probe: "If inflation rises 3%, does your price point survive? If budget freezes hit, which segment still buys?"

### Step 3 — Social

Use AskUserQuestion:
- Ask: "Which social trends affect adoption? Consider: demographics, cultural attitudes, digital adoption rates, education levels, wellness or behavioral shifts."
- Probe: "Are your early adopters leading or lagging a broader social shift?"

### Step 4 — Technological

Use AskUserQuestion:
- Ask: "Which technology trends are tailwinds or headwinds? Consider: emerging tech adoption, cybersecurity threats, automation, platform shifts, R&D investment in adjacent spaces."
- Probe: "Is there a technology that could make your solution obsolete in 3 years? Or one that will make it 10x cheaper to build?"

### Step 5 — Legal

Use AskUserQuestion:
- Ask: "Which legal requirements apply? Consider: data protection (GDPR, CCPA), employment law, IP protection, consumer safeguards, industry-specific compliance."
- Probe: "What's the compliance cost to enter your target market? Any pending legislation that changes the game?"

### Step 6 — Environmental

Use AskUserQuestion:
- Ask: "Which environmental factors are relevant? Consider: climate regulations, emissions standards, resource scarcity, waste management, ESG investor pressure."
- Probe: "Do your customers have ESG commitments that affect procurement decisions?"

### Step 7 — Prioritize and Respond

After all 6 dimensions:
- Rank top 5 factors by impact × probability.
- Use AskUserQuestion for each top factor: "What is the strategic response? Adapt, mitigate, exploit, or monitor?"

## Output

Write to `.strategic-frameworks/pestle-{YYYY-MM-DD}.yaml`:

```yaml
framework: pestle_analysis
date: {YYYY-MM-DD}
political:
  - factor: ""
    impact: high|medium|low
    probability: likely|possible|unlikely
    response: ""
economic:
  - factor: ""
    impact: high|medium|low
    probability: likely|possible|unlikely
    response: ""
social:
  - factor: ""
    impact: high|medium|low
    probability: likely|possible|unlikely
    response: ""
technological:
  - factor: ""
    impact: high|medium|low
    probability: likely|possible|unlikely
    response: ""
legal:
  - factor: ""
    impact: high|medium|low
    probability: likely|possible|unlikely
    response: ""
environmental:
  - factor: ""
    impact: high|medium|low
    probability: likely|possible|unlikely
    response: ""
top_priority_factors: []
```

Append to `.prd/PRD-STATE.md` Working Notes:
```
| pestle_run | {YYYY-MM-DD} | .strategic-frameworks/pestle-{YYYY-MM-DD}.yaml |
```

If CONTEXT.md exists, append top-priority factors and strategic responses to `section_1e_constraints`.
