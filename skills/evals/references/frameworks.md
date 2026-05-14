# Eval Frameworks Reference

Comparison grid for the main LLM eval frameworks as of 2026.

## Comparison Table

| Framework | What It Does | Best For | Setup Complexity | Cost Model | Claude-Native | Eval Types |
|---|---|---|---|---|---|---|
| **Braintrust** | Hosted eval platform — run evals, log traces, track scores over time | Production monitoring + prompt iteration | Low (hosted, SDK) | API-priced (usage-based) | Partial (Anthropic SDK supported) | All types |
| **RAGAS** | Python library of RAG-specific metrics — faithfulness, context recall, answer relevance | RAG/memory apps with retrieval pipelines | Medium (Python, local) | Open source | No (provider-agnostic, works with Claude) | Memory/RAG, API response |
| **promptfoo** | YAML-driven CLI eval runner — define cases and assertions in YAML, run locally | Prompt regression testing without infra | Low (CLI, YAML) | Open source | Partial (Claude provider supported) | Prompt regression, API response, safety |
| **LangSmith Evals** | LangChain's hosted eval + tracing platform | Teams already using LangChain/LangGraph | Medium (tied to LangChain ecosystem) | Hosted (free tier + paid) | Partial (works via LiteLLM or direct) | All types |
| **Inspect AI** | UK AISI's open-source eval framework, designed for safety and capability evaluations | Security/safety red teaming, capability benchmarks | High (requires Python, eval design expertise) | Open source | No (provider-agnostic) | Safety/guardrails, capability evals |

## Capability Detail

### Braintrust
- Tracing: yes — full LLM call traces with token costs
- Dataset versioning: yes
- LLM-as-judge: built-in (many pre-built scorers)
- CI integration: GitHub Actions native
- Logging: production eval logging with dashboards

### RAGAS
- RAG-specific metrics: faithfulness, answer relevance, context recall, context precision
- Works with any LLM as the evaluator
- No hosted infra — runs in your Python environment
- Metrics are well-cited in academic literature

### promptfoo
- Zero infra: single CLI command
- YAML config: define inputs, expected patterns, LLM-as-judge rubrics
- Built-in providers: OpenAI, Anthropic, Bedrock, local models
- Red-teaming mode: automated adversarial input generation
- Fast: runs evals in parallel

### LangSmith Evals
- Deep LangChain integration: traces every chain step
- Dataset hub: shared eval datasets
- Human annotation: annotation queues for labeling
- Comparison mode: A/B test two prompts on same dataset

### Inspect AI
- Purpose-built for safety evaluation and capability benchmarks
- Task-based eval design (sandboxed environments)
- Used by UK AISI for frontier model evaluations
- Steep learning curve; overkill for most product evals
- Strong for: jailbreak cataloging, capability probing, systematic red-teaming

## Quick Picks

| Need | Recommendation | Why |
|---|---|---|
| Just need prompt regression fast | **promptfoo** | YAML-driven, zero infra, Claude provider built-in |
| RAG/memory app | **RAGAS** | Purpose-built metrics, academic-grade scoring |
| Production monitoring + evals | **Braintrust** or **LangSmith** | Tracing + eval in one platform |
| Security / red teaming | **Inspect AI** | Systematic adversarial eval framework |
| Already using LangChain | **LangSmith** | Native integration, no adapter needed |

## Notes

- None of these replace a golden set. All frameworks are runners — you still define the cases.
- LLM-as-judge is available in all frameworks; the judge prompt is your responsibility.
- Cost: open-source frameworks shift cost to your LLM API calls for judge. Hosted platforms add platform fees.
- Mix is fine: use promptfoo for regression CI + Braintrust for production monitoring.
