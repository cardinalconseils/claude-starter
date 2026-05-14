# Eval Tiers Reference Card

## Canonical Tier Definitions

| Tier | Cases | Runtime | Cadence | Gate |
|---|---|---|---|---|
| **Smoke** | 3–5 | <2 min | Every commit (CI) | Block merge on failure |
| **Standard** | 15–25 | 5–10 min | Pre-merge (PR check) | Block merge on failure |
| **Comprehensive** | 50–100+ | 30+ min | Nightly + pre-release | Block release on failure |

## Recommended Case Counts by Eval Type

| Eval Type | Smoke | Standard | Comprehensive |
|---|---|---|---|
| Memory / RAG | 3 | 15–20 | 50–75 |
| API Response | 3–5 | 15–25 | 50–100 |
| Tool-Use | 3 | 15–20 | 50–80 |
| Prompt Regression | 3–5 (must-not-break) | 15–25 | 50–100+ |
| Safety / Guardrails | 3 | 15–20 | 75–100+ |
| Structured Output | 3 | 10–15 | 40–60 |

## Signs You're in the Wrong Tier

**Smoke is too big:**
- Smoke suite takes >5 min → trim to critical path only; move rest to standard
- Smoke has >10 cases → too many; pick the 3–5 that are truly load-bearing
- Smoke evals require external services → decouple from external deps or mock them

**Standard is miscalibrated:**
- Standard has <8 cases → not enough coverage; add edge cases from past bugs
- Standard never catches anything smoke didn't → redundant; rethink what "edge case" means
- Standard takes >20 min → too large; move slowest cases to comprehensive

**Comprehensive is useless:**
- Comprehensive never runs → fix the cadence; schedule it nightly
- Comprehensive has <20 cases → not comprehensive; build out the library
- Comprehensive always passes immediately → either quality is perfect (unlikely) or cases aren't adversarial enough

## How to Build Up a Tier

### Start: Smoke (Day 1)
Pick the 3 behaviors that, if broken, would be immediately visible to users. Write cases for those. That's your smoke suite.

### Grow to Standard (After first sprint)
Add one case per:
- Major edge case discovered during development
- Bug found in testing that wasn't caught by smoke
- Format/constraint requirement in the feature spec

Target 15+ before first merge of an AI feature.

### Build Comprehensive (Ongoing)
Add a case every time:
- A production bug is fixed
- A user reports unexpected behavior
- A security probe reveals a gap
- A model upgrade changes behavior

Comprehensive is never "done." It grows with the product.

## Pass/Fail Thresholds

| Tier | Minimum pass rate |
|---|---|
| Smoke | 100% — all cases must pass |
| Standard | ≥ 95% — one or two edge cases may flap |
| Comprehensive | ≥ 90% — larger suite, some acceptable variance |

When a case drops below threshold: **investigate before dismissing.** Do not raise the threshold to make the tier pass.

## Tier Promotion

When a case catches a real bug at one tier, consider promoting it to the tier above:
- Case catches bug in standard but not smoke → add a smoke variant
- Case catches bug in comprehensive but not standard → add to standard

Direction: critical bugs propagate up toward smoke. Cases never get demoted (they only get marked `"active": false` if obsolete).
