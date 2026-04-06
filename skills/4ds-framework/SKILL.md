---
name: 4ds-framework
description: >
  4Ds quality framework — Delegation, Description, Discernment, Diligence.
  Use when: auditing project quality, scoring features, reviewing agent decisions,
  checking delegation chains, surfacing trade-offs, logging decisions, running
  complexity gates, or when the user asks about quality dimensions, "audit",
  "quality score", "what was skipped", "why was this decision made",
  "delegation chain", "trade-off", or "4Ds".
allowed-tools: Read, Grep, Glob, Write, Edit, AskUserQuestion
---

# 4Ds Framework — Delegation, Description, Discernment, Diligence

## Purpose

Score and improve project quality across four dimensions. Each D can be delivered
through Automation, Augmentation, or Agency.

## The Four Dimensions

### 1. Delegation — "Who does what?"

Measures how cleanly work is distributed between humans, agents, and automation.

| Signal | Good | Bad |
|--------|------|-----|
| Command length | <60 lines, thin dispatcher | Inline workflow logic |
| Agent scope | Single responsibility | Multi-concern agent |
| Skill loading | Via frontmatter `skills:` | Hardcoded paths |
| Human role | Decides via AskUserQuestion | Reads wall of text |

### 2. Description — "How clearly is work specified?"

Measures specification quality — can agents and humans understand what to build?

| Signal | Good | Bad |
|--------|------|-----|
| Discovery | 11 Elements complete | Missing user stories |
| Agent frontmatter | All fields declared | Missing tools/skills |
| State file | Updated after every step | Stale or missing |
| Acceptance criteria | Measurable, per-story | Vague "it works" |

### 3. Discernment — "What's the right call?"

Measures judgment quality — are trade-offs explicit and quality bars respected?

| Signal | Good | Bad |
|--------|------|-----|
| Maturity alignment | Gates match stage | Production gates on prototype |
| Iteration routing | Routes to correct phase | Always "just fix it" |
| Trade-off logging | Explicit skip + reason | Silent omission |
| Pushback | Agent refuses bad input | Agent builds on shaky foundation |

### 4. Diligence — "Is the work done right?"

Measures verification depth — are quality checks actually running?

| Signal | Good | Bad |
|--------|------|-----|
| Pre-commit guard | Blocks secrets, debug code | Bypassed with --no-verify |
| Confidence ledger | All gates pass with evidence | Missing or incomplete |
| Test coverage | Tests exist for acceptance criteria | No tests |
| Lint/type checks | Run after every edit | Run only at sprint end |

## Scoring Model

Each dimension is scored 0-3 per feature:

| Score | Meaning |
|-------|---------|
| 0 | Not present — no evidence of this dimension |
| 1 | Partial — some signals present, gaps remain |
| 2 | Solid — most signals present, minor gaps |
| 3 | Exemplary — all signals present with evidence |

**Feature score** = sum of 4 Ds (max 12)
**Project score** = average across features (max 12)

## Audit Workflow

See `workflows/audit.md` for the step-by-step audit process.

## Decision Log

See `workflows/decision-log.md` for the structured decision logging protocol.

## Complexity Gate

See `workflows/complexity-gate.md` for the pre-sprint complexity check.

## Trade-Off Surfacing

See `workflows/trade-off-surfacing.md` for the explicit trade-off protocol.

## Pushback Protocol

See `references/pushback-protocol.md` for agent precondition checks.

## Integration Points

- **`/cks:audit`** — Runs the full audit workflow, produces scored report
- **Sprint Phase** — Complexity gate runs before planning (Step 0)
- **All agents** — Decision log appended after every significant choice
- **All agents** — Pushback protocol checked at agent startup
- **Review Phase** — Trade-off summary included in review

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We don't need an audit — the tests pass" | Tests verify code, not process. A passing test suite with no discovery docs means you built the wrong thing correctly. |
| "Logging decisions slows us down" | Writing one JSON line takes 2 seconds. Debugging an unexplained decision 3 sprints later takes hours. |
| "Complexity gates are overkill for small features" | Small features in large codebases cause the most subtle bugs. The gate takes 10 seconds. |
| "Trade-offs are obvious — no need to log them" | Obvious to you today, mysterious to the next developer (or your future self). |

## Verification

- [ ] Every feature has a 4Ds score in `.prd/logs/audit.jsonl`
- [ ] Decision log has entries for every sprint
- [ ] Complexity gate ran before every sprint start
- [ ] Trade-offs surfaced for every skipped quality step
- [ ] Pushback protocol triggered at least once (proving it works)
