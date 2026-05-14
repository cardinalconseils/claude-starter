# API Response Eval Workflow

Evaluate general LLM API responses for prose quality, accuracy, and format adherence.

## What to Measure

- **Faithfulness** — response sticks to what was asked; no invented scope or instructions
- **Groundedness** — claims supported by provided context, documents, or tool results
- **Answer relevance** — response actually answers the question (not just related)
- **Coherence** — logical flow, no internal contradictions, consistent tone
- **Completeness** — all required aspects of the question addressed

## LLM-as-Judge Implementation

Use a separate judge call. Never use the same prompt as the feature.

**Judge system prompt pattern:**
```
You are an impartial evaluator. Score the following response on the rubric below.
Return JSON: {"score": 0.0-1.0, "explanation": "one sentence"}.
Use temperature=0. Do not consider your own knowledge — only evaluate against the rubric.

Rubric: {rubric}
Input: {input}
Response: {response}
Expected behavior: {expected_behavior}
```

**Rubric examples:**
- Faithfulness: "Does the response only address what was asked? Penalize scope creep."
- Groundedness: "Are all factual claims present in the provided context? Penalize hallucination."
- Completeness: "Does the response cover all required aspects listed in the expected behavior?"

Score 1.0 = fully meets rubric. 0.0 = fails rubric entirely. Use full range, not just 0 and 1.

**Reproducibility**: always temperature=0 for judge. Same input → same score.

## Smoke Tier (3–5 cases)

Run every commit. <2 min.

1. **Happy path** — typical input, well-formed context; assert score ≥ 0.85 on faithfulness + relevance
2. **Edge case input** — unusual but valid input; assert no hallucination, score ≥ 0.75
3. **Refusal case** — out-of-scope or unsafe input; assert model refuses appropriately

## Standard Tier (15–25 cases)

Run pre-merge for any AI feature.

Add to smoke:
- **Hallucination probe** — input with tempting but absent facts in context; assert groundedness ≥ 0.85
- **Length adherence** — prompt specifies response length; assert actual length within ±20%
- **Tone/format requirements** — prompt specifies format (bullets, JSON, specific style); assert format followed
- **Partial context** — context missing some expected facts; assert model says so vs hallucinating
- **Multilingual** (if applicable) — query in non-English language; assert coherent response
- **Contradictory context** — two provided documents disagree; assert model surfaces conflict
- **Long context** — context near token limit; assert no truncation artifacts in response

## Comprehensive Tier (50–100+ cases)

Run nightly or pre-release.

Add:
- **Adversarial inputs** — inputs designed to confuse or derail the model
- **Domain boundary tests** — inputs at the edge of what the system is designed to handle
- **Regression set** — every past failure converted to a case; never remove these
- **Prompt injection probes** — user inputs trying to override system prompt
- **Consistency tests** — same question asked multiple ways; assert consistent answers

## Scoring Thresholds

| Metric | Standard tier | Production gate |
|---|---|---|
| Faithfulness | ≥ 0.85 | ≥ 0.92 |
| Groundedness | ≥ 0.80 | ≥ 0.90 |
| Answer relevance | ≥ 0.85 | ≥ 0.90 |
| Coherence | ≥ 0.80 | ≥ 0.88 |
| Completeness | ≥ 0.75 | ≥ 0.85 |

Tier passes if ALL metrics meet threshold AND ≥ 90% of individual cases pass.

## Golden Set Management

- Store golden cases in `.evals/golden/{feature-name}/`
- Per case: `input.json`, `expected.md` (prose) or `expected.json` (structured), `metadata.json`
- `metadata.json` fields: `tier`, `eval_type`, `tags`, `added_date`, `added_reason`
- Commit `.evals/golden/` to git — regressions are trackable across PRs
- Add a case every time a production bug is fixed
- Review and prune annually — remove cases made obsolete by product changes

**Golden set must not be auto-updated.** Only humans decide when expected behavior changes.

## Output Format

Per case:
```
case_id: api-001
input: "Summarize the attached document in 3 bullets."
faithfulness: 0.92
groundedness: 0.88
relevance: 0.95
coherence: 0.90
completeness: 0.85
case_pass: true
```

Aggregate: `{passed}/{total} | avg faithfulness: X.XX | tier: PASS/FAIL`
