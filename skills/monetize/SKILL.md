---
name: monetize
description: >
  Business monetization evaluation and strategy — analyzes projects or business descriptions
  using evidence-based tier evaluation (Strong/Possible/Weak) with explicit assumption chains,
  legal/compliance gating, and user-reviewed market research. Produces an honest business case
  where every revenue figure traces back to cited sources and stated assumptions. Use this skill
  whenever: evaluating monetization options, pricing strategy, revenue models, business model
  analysis, or when the user says "monetize", "revenue model", "pricing strategy",
  "how to make money", "business model", "open source monetization", "SaaS pricing",
  "freemium strategy", or any variation of business monetization planning. Also trigger
  when the user asks about competitor pricing, market sizing, or go-to-market strategy.
allowed-tools: Read, Write, Grep, Glob, Agent, WebSearch, WebFetch, Bash, AskUserQuestion
---

# Monetize — Business Monetization Evaluation & Strategy

This skill evaluates monetization models for projects and businesses using evidence-based
tier evaluation — not numeric scores. Revenue projections are explicit assumption chains
where every variable cites its source. Research is user-reviewed before evaluation.
Legal/compliance constraints are first-class filters that can block models before scoring.
The output is an honest business case designed to surface the right questions, not just
polished answers.

## Flow

```
/monetize → discover → research → cost-analysis → evaluate → report → roadmap → /cks:new handoff
```

Each phase is independently invokable via `/monetize:{phase}`.

## Agents

Each phase dispatches a dedicated agent:

| Phase | Agent | Role |
|-------|-------|------|
| discover | `monetize-discoverer` | Scans codebase, asks business context questions |
| research | `monetize-researcher` | Queries Perplexity/WebSearch for market intelligence |
| cost-analysis | `cost-researcher` → `cost-analyzer` | Researches tech stack costs, builds unit economics |
| evaluate | `monetize-evaluator` | Evidence-based tier evaluation with assumption chains |
| report | `monetize-reporter` | Combines all artifacts into business case |
| roadmap | *(inline)* | Creates phase briefs and updates ROADMAP.md |

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
3. **Discover** → Dispatch `monetize-discoverer` agent (workflow: `workflows/discover.md`)
4. **Research** → Dispatch `monetize-researcher` agent (workflow: `workflows/research.md`)
5. **Cost Analysis** → Dispatch `cost-researcher` then `cost-analyzer` agents (workflow: `workflows/cost-analysis.md`)
6. **Evaluate** → Dispatch `monetize-evaluator` agent (workflow: `workflows/evaluate.md`)
7. **Report** → Dispatch `monetize-reporter` agent (workflow: `workflows/report.md`)
8. **Roadmap** → Read workflow: `workflows/roadmap.md`

Each phase saves its output. If interrupted, the next `/monetize` invocation detects
existing artifacts and resumes from the last incomplete phase.

## Phase Validation

Before starting any phase, verify its prerequisites exist:

| Phase | Requires |
|-------|----------|
| Research | `.monetize/context.md` |
| Cost Analysis | `.monetize/context.md` (+ `.monetize/research.md` recommended) |
| Evaluate | `.monetize/context.md` + `.monetize/research.md` + `.monetize/cost-analysis.md` |
| Report | `.monetize/evaluation.md` |
| Roadmap | `docs/monetization-assessment.md` |

If missing, prompt: "Run `/monetize:{missing_phase}` first."

## Reference Files

| File | When to Read |
|------|-------------|
| `references/models-catalog.md` | During evaluate phase — contains the 12 models with criteria |
| `references/cost-categories.md` | During cost-analysis phase — cost category detection and provider reference |
| `references/report-template.md` | During report phase — template for the assessment document |

## Error Handling

| Failure | Behavior |
|---------|----------|
| `PERPLEXITY_API_KEY` missing | Fall back to WebSearch-based research (no API key needed). Note "Source: WebSearch" in research output |
| Perplexity rate limit / timeout | Retry once after 5s. On 2nd failure, save partial results, flag gaps in report |
| Codebase scan finds nothing (A/B) | Fall back to Mode C behavior — full questionnaire |
| User abandons mid-questionnaire | Save partial context. Next run offers to resume or restart |

## Customization

This skill ships with opinionated defaults. Review and adapt to your needs:

- **Revenue model catalog**: Available models for evaluation — edit `references/models-catalog.md`
- **Cost categories**: Tech stack cost breakdown structure — edit `references/cost-categories.md`
- **Report template**: Assessment report format — edit `workflows/report.md`
- **Evaluation tiers**: Strong/Possible/Weak criteria — edit `workflows/evaluate.md`
- **allowed-tools**: Currently `Read, Write, Grep, Glob, Agent, WebSearch, WebFetch, Bash, AskUserQuestion`.

## Output Artifacts

| File | Purpose |
|------|---------|
| `.monetize/context.md` | Discovery context |
| `.monetize/research.md` | Perplexity research with citations |
| `.monetize/cost-research-raw.md` | Raw provider pricing data |
| `.monetize/cost-analysis.md` | Unit economics, margins, scaling curves |
| `.monetize/evaluation.md` | Evidence-based tier evaluation + stack recommendation |
| `docs/monetization-assessment.md` | Final business case report |
| `docs/ROADMAP.md` | Updated with monetization phases (preview entries) |
| `.monetize/phases/*.md` | PRD-ready phase briefs for `/cks:new` |
