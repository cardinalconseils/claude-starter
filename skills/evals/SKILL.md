---
name: evals
description: >
  LLM output quality evaluation — memory/RAG evals, API response quality, tool-use correctness,
  prompt regression, safety/guardrails, and structured output validation. Use when: building any
  LLM feature, verifying AI output quality before shipping, running regression checks after prompt
  changes, or gating a release with quality evidence. Covers smoke/standard/comprehensive eval tiers.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# LLM Evals

## Overview

Evals verify LLM output quality. They differ from code tests: can't do `assert output == expected` on prose. Need scoring — binary for structured outputs, numeric rubric for prose, LLM-as-judge for semantics.

Three things evals catch that code tests miss:
- Silent prompt regression (prompt "works" but quality degraded)
- Model version drift (new model, subtly different behavior)
- Edge case failures (input not covered by happy-path tests)

## Eval Types

| Type | What It Tests | When to Use |
|---|---|---|
| Memory/RAG | Retrieval accuracy, context relevance, groundedness, hallucination | Any feature using vector search or memory store |
| API Response | Faithfulness, coherence, relevance, completeness | Any direct LLM API call producing prose |
| Tool-Use | Tool selection, param correctness, call ordering, graceful degradation | Any feature using Claude tool_use |
| Prompt Regression | Golden set pass rate after prompt change | Before merging any prompt edit |
| Safety/Guardrails | Refusal rate, PII non-leakage, scope adherence, jailbreak resistance | Any user-facing LLM feature |
| Structured Output | Schema adherence, required fields, type correctness | Any feature using JSON mode or response_format |

## Eval Tiers

### Smoke — 3–5 cases, <2 min, every commit
Critical path only. If these fail, something is fundamentally broken. Run in CI on every push.
- 1–2 happy path cases (must work)
- 1 edge case (known fragile input)
- 1 refusal or rejection case where applicable

### Standard — 15–25 cases, 5–10 min, pre-merge
Happy path + main edge cases. Run before every PR merge for AI features.
- All smoke cases
- Known edge cases from past bugs
- Format/length adherence
- Main adversarial input categories

### Comprehensive — 50–100+ cases, 30+ min, nightly or pre-release
Full adversarial coverage. Release quality gate.
- All standard cases
- Exhaustive edge case library
- Adversarial inputs
- Regression cases from every past failure

### Tier Selection Guide

| Phase | Tier | Gate |
|---|---|---|
| Every commit / CI | Smoke | Block merge if fails |
| PR review (AI feature) | Standard | Block merge if fails |
| Release gate | Comprehensive | Block release if fails |
| Nightly monitoring | Comprehensive | Alert on drop |

## Metrics Taxonomy

- **Faithfulness** — response sticks to what was asked, no invented scope
- **Groundedness** — claims supported by provided context or tool results
- **Relevance** — response actually answers the question asked
- **Recall** — how much of the required information was included
- **Precision** — how much of the response is relevant (vs noise)
- **Coherence** — logical flow, no internal contradictions
- **Refusal rate** — % of out-of-scope requests correctly refused

## LLM-as-Judge Pattern

Use a second LLM call to score outputs. Dominant technique for prose evals.

Pattern:
1. Call feature prompt → get output
2. Call judge prompt with: `{input, output, expected_behavior, rubric}` → get `{score: 0.0–1.0, explanation: "..."}`
3. Judge uses temperature=0 for reproducibility
4. Judge prompt is different from feature prompt (not circular)
5. Aggregate scores across cases → tier pass/fail

Judge prompt template lives in `.evals/judge-prompt.md`. Version it like code.

## Lifecycle Hooks

Evals slot into the CKS sprint lifecycle at three points:

- **Sprint [3c] build** → Smoke tier. Fast gate before code review. Run as part of build verification.
- **Sprint [4a] review** → Standard tier. Evidence requirement for any AI feature claim. Show output in PR.
- **Release [5c] production gate** → Comprehensive tier. Quality gate before production deploy.

Never skip the tier appropriate to the phase. Tier mismatch is a process bug.

## Workflow References

- `workflows/memory-eval.md` — Retrieval accuracy, context relevance, groundedness for RAG/memory systems
- `workflows/api-response-eval.md` — Faithfulness, coherence, relevance for general LLM API calls
- `workflows/tool-use-eval.md` — Tool selection, param correctness, call ordering for tool_use features
- `workflows/prompt-regression.md` — Golden set management and regression detection after prompt changes
- `workflows/safety-eval.md` — Refusal rates, PII non-leakage, guardrails, structured output schema checks

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Our prompts are stable, no need for regression evals" | Prompts drift. Model versions update. Evals catch silent degradation. |
| "LLM-as-judge is circular — you're using AI to grade AI" | Judge uses separate prompt, temperature=0, explicit rubric. Different from the feature prompt. |
| "Smoke evals are too few to be meaningful" | 3 well-chosen cases covering critical paths beat 100 random cases. Tier up as coverage needs grow. |
| "Comprehensive evals are too slow for CI" | Not for CI. Smoke is for CI. Comprehensive is for release gates. Match tier to phase. |
| "We'll add evals after launch" | Post-launch evals reveal what's already broken in production. Run standard evals pre-merge. |

## Verification

- [ ] Smoke suite runs in <2 min and blocks CI on failure
- [ ] Standard suite runs pre-merge for any AI feature PR
- [ ] Comprehensive suite gates releases (not skipped)
- [ ] LLM-as-judge prompt is versioned and stored in `.evals/`
- [ ] Golden set lives in `.evals/golden/` and is committed to git
- [ ] Eval results are reported inline in PRs (not just "evals pass")
- [ ] Score thresholds documented per eval type
