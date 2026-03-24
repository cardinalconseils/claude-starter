---
name: monetize
description: >
  Business monetization evaluation and strategy — analyzes projects or business descriptions
  to score 12 monetization models, research competitors via Perplexity API, and produce a
  full business case with revenue projections and implementation roadmap. Use this skill
  whenever: evaluating monetization options, pricing strategy, revenue models, business model
  analysis, or when the user says "monetize", "revenue model", "pricing strategy",
  "how to make money", "business model", "open source monetization", "SaaS pricing",
  "freemium strategy", or any variation of business monetization planning. Also trigger
  when the user asks about competitor pricing, market sizing, or go-to-market strategy.
---

# Monetize — Business Monetization Evaluation & Strategy

This skill evaluates monetization models for projects and businesses, producing a full
business case with revenue projections, competitor benchmarking, and an implementation
roadmap that feeds into the PRD lifecycle.

## Flow

```
/monetize → discover → research → evaluate → report → roadmap → /prd:new handoff
```

Each phase is independently invokable via `/monetize:{phase}`.

## Mode Detection

Determine input mode from arguments:

| Condition | Mode | Behavior |
|-----------|------|----------|
| No arguments | **A — Self-analyze** | Scan current project codebase |
| Argument is a local directory path | **B — Analyze target** | Scan target project codebase |
| Argument is quoted text / description | **C — Business description** | Pure strategy, no code scan |

Mode B accepts **local paths only** (not URLs). For remote repos, the user should clone first.

## Re-run Check

Before starting, check if `.monetize/` exists:
- If yes → read `.monetize/context.md` for the date. Ask: "Previous assessment found (dated {date}). **Archive and start fresh**, or **update with new research**?"
  - Archive: `mkdir -p .monetize/archive/{date} && mv .monetize/*.md .monetize/archive/{date}/`
  - Update: skip discover, re-run research → evaluate → report → roadmap
- If no → fresh run

## Full Flow Execution

When `/monetize` is invoked (full flow):

1. **Detect mode** (from arguments)
2. **Re-run check** (above)
3. **Discover** → Read workflow: `workflows/discover.md`
4. **Research** → Read workflow: `workflows/research.md`
5. **Evaluate** → Read workflow: `workflows/evaluate.md`
6. **Report** → Read workflow: `workflows/report.md`
7. **Roadmap** → Read workflow: `workflows/roadmap.md`

Each phase saves its output. If interrupted, the next `/monetize` invocation detects
existing artifacts and resumes from the last incomplete phase.

## Phase Validation

Before starting any phase, verify its prerequisites exist:

| Phase | Requires |
|-------|----------|
| Research | `.monetize/context.md` |
| Evaluate | `.monetize/context.md` + `.monetize/research.md` |
| Report | `.monetize/evaluation.md` |
| Roadmap | `docs/monetization-assessment.md` |

If missing, prompt: "Run `/monetize:{missing_phase}` first."

## Reference Files

| File | When to Read |
|------|-------------|
| `references/models-catalog.md` | During evaluate phase — contains the 12 models with criteria |
| `references/report-template.md` | During report phase — template for the assessment document |

## Error Handling

| Failure | Behavior |
|---------|----------|
| `PERPLEXITY_API_KEY` missing | Halt research, prompt user to set the key, resume with `/monetize:research` |
| Perplexity rate limit / timeout | Retry once after 5s. On 2nd failure, save partial results, flag gaps in report |
| Codebase scan finds nothing (A/B) | Fall back to Mode C behavior — full questionnaire |
| User abandons mid-questionnaire | Save partial context. Next run offers to resume or restart |

## Output Artifacts

| File | Purpose |
|------|---------|
| `.monetize/context.md` | Discovery context |
| `.monetize/research.md` | Perplexity research with citations |
| `.monetize/evaluation.md` | Model scores + stack recommendation |
| `docs/monetization-assessment.md` | Final business case report |
| `docs/ROADMAP.md` | Updated with monetization phases (preview entries) |
| `.monetize/phases/*.md` | PRD-ready phase briefs for `/prd:new` |
