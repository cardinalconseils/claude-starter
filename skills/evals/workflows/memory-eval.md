# Memory / RAG Eval Workflow

Evaluate retrieval-augmented generation and memory systems. Tests two layers: retrieval quality (right chunks?) and generation quality (answer grounded in retrieved context?).

## What to Measure

- **Retrieval accuracy** — did the correct chunks come back for the query?
- **Context relevance** — are retrieved chunks actually relevant to the question asked?
- **Answer groundedness** — does the final answer use retrieved context, not model memory?
- **Recency bias** — are recent memories weighted appropriately over stale ones?
- **Hallucination detection** — did the model invent facts not present in retrieved context?

## Smoke Tier (3–5 cases)

Run every commit. <2 min.

1. **Factual recall** — ask for a specific stored fact; assert exact or paraphrase match
2. **Multi-hop retrieval** — query requiring two chunks to answer; assert both referenced
3. **"Not in memory" rejection** — ask for fact that was never stored; assert model says it doesn't know (no hallucination)

Score: binary pass/fail per case. All 3 must pass.

## Standard Tier (15–25 cases)

Run pre-merge.

Add to smoke cases:
- **Recency tests** — same fact stored twice (old + new version); assert new version wins
- **Partial match** — query with synonym or paraphrase of stored key; assert correct retrieval
- **Ambiguous query** — query matches multiple chunks; assert most relevant wins
- **Context window edge case** — query where retrieved chunks fill most of context window; assert no truncation artifacts
- **Empty memory** — query against empty store; assert graceful "no information" response
- **Cross-document reasoning** — answer requires combining two stored documents

## Comprehensive Tier (50–100+ cases)

Run nightly or pre-release.

Add:
- **Adversarial queries** — trick queries designed to retrieve wrong chunks
- **Poisoned memory** — store deliberately misleading fact; assert model handles conflicting evidence
- **Large corpus** — 10k+ chunks in store; assert latency and accuracy hold
- **Conflicting memories** — two stored facts contradict; assert model surfaces the conflict
- **Temporal ordering** — sequence of events stored; assert correct ordering in recall
- **Language mismatch** — query in different language than stored content

## Scoring Approach

**Retrieval layer** (binary):
- Retrieved chunk IDs match expected chunk IDs → pass
- Wrong chunk retrieved → fail

**Generation layer** (LLM-as-judge, 0–1 scale):
- Groundedness: does the answer cite / use retrieved context? Score 0–1
- Hallucination: does the answer contain facts not in retrieved context? Score 0 = hallucinated, 1 = grounded

**Thresholds:**
- Standard tier: groundedness ≥ 0.80, hallucination score ≥ 0.85
- Production gate: groundedness ≥ 0.90, hallucination score ≥ 0.95

## Common Gotchas

- **Embedding model drift** — if you swap embedding models, old vectors become misaligned. Run full comprehensive eval after any embedding model change.
- **Chunking strategy changes** — smaller or larger chunks silently break recall for certain query types. Treat chunking changes as breaking changes requiring standard eval.
- **Recency window off-by-one** — edge case: fact stored exactly at recency cutoff. Include this as a standard case.
- **Retrieval top-k too low** — if top-k=3 but answer needs chunk 4, eval fails. Tune k as part of eval setup.
- **Judge model knows the answer** — judge LLM may have training knowledge of facts in your memory store. Use synthetic or domain-specific facts in evals to avoid this.

## Output Format

Per case:
```
case_id: mem-001
query: "What is the user's preferred language?"
expected_chunk: chunk-42
retrieved_chunks: [chunk-42, chunk-17]
retrieval_pass: true
answer: "The user prefers French."
groundedness_score: 0.94
hallucination_score: 0.98
case_pass: true
```

Aggregate: `{passed}/{total} cases | groundedness avg: X.XX | hallucination avg: X.XX | tier: PASS/FAIL`
