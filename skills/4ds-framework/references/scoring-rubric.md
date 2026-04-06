# 4Ds Scoring Rubric

## Per-Feature Scoring

### Delegation (0-3)

| Score | Criteria |
|-------|----------|
| 0 | No agent dispatch — work done inline or manually |
| 1 | Agent dispatched but scope unclear, or command embeds logic |
| 2 | Clean dispatch chain, agents stay in lane, AskUserQuestion used |
| 3 | Full chain verified: command → agent → skill → workflow, no leaks |

**Evidence:** Check command files (<60 lines?), agent frontmatter complete, skill loading via `skills:` not paths.

### Description (0-3)

| Score | Criteria |
|-------|----------|
| 0 | No CONTEXT.md or discovery artifacts |
| 1 | Partial discovery — some elements missing, no acceptance criteria |
| 2 | CONTEXT.md exists with most elements, acceptance criteria defined |
| 3 | All 11 Elements complete, criteria measurable, state file current |

**Evidence:** Count elements in CONTEXT.md, check acceptance criteria format, verify STATE.md freshness.

### Discernment (0-3)

| Score | Criteria |
|-------|----------|
| 0 | No quality gates applied, no maturity stage set |
| 1 | Maturity stage set but gates not matched, no trade-off logs |
| 2 | Gates match maturity, some trade-offs logged, iteration loop used |
| 3 | All trade-offs explicit, pushback triggered when needed, decisions logged |

**Evidence:** Check `.prd/logs/decisions.jsonl`, verify maturity in config, scan for skipped gates.

### Diligence (0-3)

| Score | Criteria |
|-------|----------|
| 0 | No tests, no lint, no verification |
| 1 | Some tests exist but gaps, CONFIDENCE.md incomplete |
| 2 | Tests cover acceptance criteria, CONFIDENCE.md gates mostly pass |
| 3 | All gates pass with evidence, lint clean, types clean, security scanned |

**Evidence:** Read CONFIDENCE.md, run test suite, check pre-commit guard results.

## Project-Level Score

```
Project 4Ds Score: {avg}/12
━━━━━━━━━━━━━━━━━━━━━━━━━━
  Delegation:   {avg}/3
  Description:  {avg}/3
  Discernment:  {avg}/3
  Diligence:    {avg}/3
━━━━━━━━━━━━━━━━━━━━━━━━━━

Rating:
  10-12  Exemplary — production-ready discipline
  7-9    Solid — minor gaps, safe for pilot
  4-6    Developing — significant gaps, prototype only
  0-3    Minimal — needs immediate attention
```
