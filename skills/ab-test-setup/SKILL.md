---
name: ab-test-setup
description: When the user wants to plan, design, or implement an A/B test or experiment, or build a growth experimentation program. Also use when the user mentions 'A/B test,' 'split test,' 'experiment,' 'conversion test,' or 'growth experiment.'
allowed-tools: Read, Write, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# A/B Testing & Experimentation

Expert knowledge for designing statistically valid experiments that produce trustworthy, actionable results.

## Core Framework: The Experimentation Stack

```
1. Hypothesis → 2. Metric Selection → 3. Sample Size → 4. Test Design → 5. Run → 6. Interpret → 7. Act
```

Every step must be completed before the next. Skipping hypothesis formation produces uninterpretable results.

## 1. Hypothesis Formation

**Template:** "Because [evidence/observation], we believe [change] will [metric direction] for [audience segment], measured by [primary metric]."

**Example:** "Because our heatmaps show 60% of users ignore our hero CTA, we believe moving it above the fold will increase free trial signups for new visitors, measured by signup rate."

Good hypotheses have:
- A root cause (not just "let's try X")
- A directional prediction (increase/decrease, not just "improve")
- A named primary metric
- An audience segment

Bad hypothesis signals: "Let's test a new headline," "Maybe color X converts better," "Users might prefer Y."

## 2. Metric Selection

**Primary metric:** One metric that defines success. The test either wins or loses on this.

**Secondary metrics:** Supporting signals that explain why the primary moved.

**Guardrail metrics:** Metrics that must not regress. If they do, the test fails regardless of primary metric lift.

| Metric Type | Example | Purpose |
|---|---|---|
| Primary | Trial signup rate | Win/loss decision |
| Secondary | CTA click rate, page scroll depth | Diagnose cause |
| Guardrail | Bounce rate, page load time | Prevent regressions |

**Avoid:** Multiple primary metrics. If both need to improve, run two tests.

## 3. Sample Size Calculation

**Required inputs:**
- Baseline conversion rate (current)
- Minimum Detectable Effect (MDE) — smallest improvement that justifies the change
- Statistical significance threshold (α) — typically 0.05
- Statistical power (1-β) — typically 0.80

**Rule of thumb formula:**
```
n = (16 × σ²) / δ²
```
Where σ = standard deviation, δ = minimum detectable difference.

**Online calculators:** Evan Miller's A/B test calculator, Optimizely's calculator.

**Typical sample sizes for conversion rate tests:**
- Baseline 2%, MDE 20% relative → ~10,000 visitors per variant
- Baseline 5%, MDE 10% relative → ~20,000 visitors per variant
- Baseline 10%, MDE 5% relative → ~50,000 visitors per variant

**Critical:** Calculate sample size BEFORE running. Post-hoc power analysis is invalid.

## 4. Test Design Decisions

### Frequentist vs Bayesian

**Frequentist (Classical):**
- Fixed sample size, binary decision at end
- Uses p-values and confidence intervals
- Best for: regulated industries, teams that need clear "yes/no"
- Risk: peeking at results invalidates the test

**Bayesian:**
- Continuous probability updates
- Uses probability of being best / expected loss
- Best for: fast-moving teams, partial rollouts
- Allows stopping early without inflating false positive rate

**Recommendation:** Use Bayesian when traffic is limited or you need to stop early. Use frequentist when stakes are high and you can commit to the full run.

### A/B vs Multivariate vs Multi-Armed Bandit

**A/B (or A/B/n):** Test one variable across 2+ variants.
- Use when: you have a clear hypothesis about one element
- Traffic split: even across all variants

**Multivariate (MVT):** Test multiple variables simultaneously in combinations.
- Use when: you want to understand interaction effects
- Requires: significantly more traffic (n × m variants)
- Risk: very few teams have enough traffic for valid MVT

**Multi-Armed Bandit:** Adaptive allocation — more traffic to better-performing variants over time.
- Use when: you cannot afford to run a losing variant for long
- Trade-off: explores less, so may miss global optimum

### Segmentation & Personalization Tests

Segment-level analysis is fine AFTER a test completes. But do not start a test with the goal of "finding the best variant for segment X" unless you've pre-specified that segment and sized accordingly (Bonferroni correction applies).

## 5. Test Duration

**Never stop early based on results.** Run for:
- At least the calculated sample size
- At minimum 2 full business cycles (usually 2 weeks) to account for day-of-week effects
- Until weekly variation stabilizes

**Business cycle effects to account for:**
- Day-of-week (B2B traffic often drops on weekends)
- Payday effects (consumer purchases spike)
- Seasonal events
- Paid campaign start/end dates

## 6. Result Interpretation

### Statistical Significance ≠ Practical Significance

A result can be statistically significant (p < 0.05) but practically meaningless (0.1% lift). Always check:
1. Is the p-value below your threshold?
2. Is the confidence interval entirely above your MDE?
3. Did guardrail metrics hold?

### The Novelty Effect

New variants often see an initial uplift from curiosity, then regress. If your test duration is short, results may not hold post-launch. Prefer tests that run for 4+ weeks.

### Peeking Problem

Checking results during a test and stopping when you see p < 0.05 inflates false positive rate dramatically. With α = 0.05, checking at every 10% of collected data gives an actual false positive rate of ~40%.

**Solutions:**
- Pre-commit to sample size before starting
- Use sequential testing / always-valid p-values (Johari et al.)
- Use Bayesian methods with proper stopping rules

### Common Result Scenarios

| Scenario | What It Means | Action |
|---|---|---|
| Winner, practical significance | Test worked | Ship variant, document learnings |
| Winner, no practical significance | Stat artifact or tiny effect | Do not ship unless free; learn from it |
| No winner | No effect detected | Bigger change needed, or hypothesis wrong |
| Variant loses | Baseline is better | Keep control, investigate why |
| Guardrail violated | Variant causes harm | Stop test, keep control |

## 7. Building an Experimentation Program

### Test Prioritization: PIE Framework

Score each test idea on 3 dimensions (1-10):
- **P**otential: How much improvement is possible?
- **I**mportance: How important is the page/flow?
- **E**ase: How easy is it to implement?

PIE score = (P + I + E) / 3. Run highest scores first.

### Velocity Targets

- Prototype stage: 1-2 tests/month is fine
- Pilot stage: 2-4 tests/month
- Candidate/Production: 5+ concurrent tests if traffic allows

### Test Taxonomy (track in a log)

For every test, record:
- Hypothesis
- Variants
- Primary metric + result
- Secondary metrics
- Duration + sample size
- Decision made
- Learning extracted

### Winning Variants Compounding

Each winning test locks in. Subsequent tests build on previous winners. This is the compound growth engine of CRO.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We don't have enough traffic — let's just run it for a week" | Underpowered tests produce noise, not signal. Calculate the required duration first. |
| "The results look good at day 3, let's stop early" | Early stopping with p < 0.05 produces a ~40% false positive rate. Run to completion. |
| "We're testing 5 things at once on this page" | Multivariate tests need 5–10× more traffic. You almost certainly don't have it. |
| "Statistical significance is all we need" | Stat sig tells you the effect is real. Practical significance tells you if it matters. Check both. |
| "Let's test everything and see what works" | No hypothesis = no learning. Even a negative result teaches nothing without a hypothesis. |
| "Our audience is different — 80% confidence is fine" | Lowering your threshold increases false positive rate proportionally. There are no free lunches. |

## Verification

- [ ] Hypothesis written using the template (evidence → change → metric direction → audience → measurement)
- [ ] Primary metric defined (singular)
- [ ] Guardrail metrics defined
- [ ] Sample size calculated before test launch with baseline rate and MDE specified
- [ ] Test duration set to cover minimum 2 business cycles
- [ ] No mid-test peeking protocol agreed upon
- [ ] Result interpretation includes practical significance check (not just p-value)
- [ ] Test logged with hypothesis, result, and learning extracted
