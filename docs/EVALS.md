# LLM Evals — Concept Overview

Evals verify LLM output quality. They differ from unit/integration tests: you can't do `assert output == expected` on prose. Evals score outputs — binary for structured data, numeric rubric for prose, LLM-as-judge for semantics.

## Why Evals Exist

Three failure modes that code tests miss:
- **Silent prompt regression** — prompt "works" but quality quietly degraded
- **Model version drift** — new model, subtly different behavior
- **Edge case failures** — inputs not covered by happy-path tests

## Entry Point

```
/cks:evals [--type=TYPE] [--tier=TIER] "feature description"
```

Dispatches `cks:evals-runner` → reads `skills/evals/SKILL.md` + relevant workflow → runs cases → reports pass/fail table.

## 6 Eval Types

| Type | Tests |
|---|---|
| `memory` | RAG retrieval accuracy, groundedness, hallucination |
| `api` | Response faithfulness, coherence, relevance, completeness |
| `tool` | Tool selection, param correctness, call ordering |
| `regression` | Golden set pass rate after any prompt change |
| `safety` | Refusal rate, PII non-leakage, jailbreak resistance |
| `structured` | Schema adherence, required fields, type correctness |

## 3 Tiers

| Tier | Cases | Runtime | Cadence | Gate |
|---|---|---|---|---|
| Smoke | 3–5 | <2 min | Every commit / CI | Block merge on failure (100% required) |
| Standard | 15–25 | 5–10 min | Pre-merge PR check | Block merge on failure (≥95% required) |
| Comprehensive | 50–100+ | 30+ min | Nightly + pre-release | Block release (≥90% required) |

## Sprint Lifecycle Integration

Evals are mandatory at three gates for any AI feature:

| Sprint Phase | Tier | What Happens |
|---|---|---|
| [3c] Build | Smoke | Run before code review. Blocks if any smoke case fails. |
| [4a] Review | Standard | Show results in PR. Evidence required — "evals pass" is not evidence. |
| [5c] Release | Comprehensive | Production quality gate. Block release on fail. |

Bootstrap and adopt: if the project includes an LLM/AI component, scaffold `.evals/` during setup.

## File Layout

```
.evals/
├── golden/              ← Test cases (committed to git, version-controlled)
│   └── {feature}/
│       ├── case-001.json
│       └── judge-prompt.md
└── results/             ← Run outputs (gitignored)
    └── {timestamp}-{feature}-{tier}.json
```

## Scoring

- **Structured output / tool params:** exact match or schema validation (binary pass/fail)
- **Prose output:** LLM-as-judge at temperature=0 using a rubric prompt separate from the feature prompt

## Key Source Files

| File | Purpose |
|---|---|
| `commands/evals.md` | `/cks:evals` command — thin dispatcher |
| `agents/evals-runner.md` | Execution agent — runs cases, reports results, never auto-fixes |
| `skills/evals/SKILL.md` | Domain skill — eval types, tiers, LLM-as-judge pattern, metrics |
| `skills/evals/references/eval-tiers.md` | Tier definitions and pass/fail thresholds |
| `skills/evals/workflows/` | Per-type scoring criteria and case structure |

## What the Agent Never Does

- Auto-fix a failing eval by changing feature code
- Raise a score threshold to make a tier pass
- Declare "evals pass" without showing the results table
- Run cases on a scaffolded golden set without user confirmation
