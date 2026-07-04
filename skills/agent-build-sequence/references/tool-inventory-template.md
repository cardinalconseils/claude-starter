# Tool Inventory / Capability Matrix Template

Used at Stage 5 of the Agentic System Build Sequence. One row per tool, function, external
API, or sub-agent the agent system can invoke. Fill this in before Stage 6 (Architecture) —
architecture decisions made without this table are guesses about latency, cost, and failure
behavior.

## Columns

| Column | What to record |
|---|---|
| Tool name | The exact callable name (function name, MCP tool name, API endpoint) |
| Capability | One line — what it does |
| Required inputs / output shape | Parameter names + types in, return shape out |
| Latency (p50/p95, rough) | Order-of-magnitude estimate — measure later, guess now |
| Cost per call (if applicable) | $ per call, or "free" / "internal — no marginal cost" |
| Failure modes | timeout / error / garbage output / rate-limited / auth-expired |
| Fallback | What the agent does when this tool fails — retry, alternate tool, degrade, abort |

## Filled-In Example

| Tool name | Capability | Required inputs / output shape | Latency (p50/p95) | Cost per call | Failure modes | Fallback |
|---|---|---|---|---|---|---|
| `search_knowledge_base` | Semantic search over the internal docs corpus | in: `{query: string, top_k: int}` — out: `{results: [{text, score, source}]}` | 300ms / 900ms | $0.0001 (embedding call) | timeout (>5s), empty results, garbage-score results | Retry once with `top_k` halved; if still empty, fall back to keyword search |
| `send_email` | Sends a transactional email via provider API | in: `{to, subject, body}` — out: `{message_id, status}` | 400ms / 1.2s | $0.001/email | rate-limited (429), invalid recipient, provider outage | Queue for retry (exponential backoff); after 3 failures, escalate to human review queue |
| `call_llm_summarize` | Summarizes a document chunk via Claude API | in: `{text, max_tokens}` — out: `{summary}` | 1.5s / 4s | ~$0.003/call (model-dependent) | timeout, context-length exceeded, refusal | Truncate input and retry once; on refusal, skip chunk and log for manual review |

## Notes

- Fill this in per-tool, not per-integration — a single integration (e.g., "Stripe") may expose
  several distinct tools (create_charge, refund, list_invoices) each with different failure
  profiles and costs.
- Latency and cost estimates are deliberately "rough" at this stage — Stage 9 (Observability)
  is where real measurements replace these guesses.
- This table is the direct input to Stage 12 (API Contract Design) when the contract format is
  MCP Tool Definitions — each row becomes one tool's input schema and description.
