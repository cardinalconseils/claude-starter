# Task Profiles — Model Scoring Criteria

## Scoring Weights by Task Type

Use these weights when ranking model candidates. ★★★ = critical, ★★ = important, ★ = nice-to-have.

| Task Type | Speed | Reasoning | Price | Context | Min Context |
|---|---|---|---|---|---|
| Fast summarization | ★★★ | ★ | ★★★ | ★★ | 8K |
| Structured extraction / JSON | ★★ | ★★ | ★★★ | ★ | 4K |
| Complex reasoning / planning | ★ | ★★★ | ★ | ★★ | 32K |
| Code generation | ★★ | ★★★ | ★★ | ★★★ | 64K |
| Code review | ★ | ★★★ | ★★ | ★★★ | 64K |
| Long-context analysis | ★ | ★★ | ★★ | ★★★ | 128K |
| Conversational / chatbot | ★★ | ★★ | ★★ | ★★ | 16K |
| Image / multimodal | ★★ | ★★ | ★★ | ★★ | 8K |

## Task Type → Env Var Mapping

| Task Type | Env Var |
|---|---|
| Fast summarization | `OPENROUTER_MODEL_FAST` |
| Structured extraction | `OPENROUTER_MODEL_FAST` |
| Complex reasoning | `OPENROUTER_MODEL_REASON` |
| Code generation | `OPENROUTER_MODEL_CODE` |
| Code review | `OPENROUTER_MODEL_REASON` |
| Long-context analysis | `OPENROUTER_MODEL_HEAVY` |
| Conversational | `OPENROUTER_MODEL_CHAT` |
| Multimodal | `OPENROUTER_MODEL_VISION` |

## Known Models Fallback Catalog

Use this when `https://openrouter.ai/api/v1/models` is unreachable. Prices as of 2026-04 — verify via URL before presenting.

### Budget Tier (< $0.15/M input)

| Model ID | Input $/M | Output $/M | Context | URL |
|---|---|---|---|---|
| `google/gemini-flash-2.0` | ~$0.10 | ~$0.40 | 1M | https://openrouter.ai/models/google/gemini-flash-2.0 |
| `google/gemini-flash-1.5` | $0.075 | $0.30 | 1M | https://openrouter.ai/models/google/gemini-flash-1.5 |
| `meta-llama/llama-3.1-8b-instruct` | ~$0.05 | ~$0.05 | 128K | https://openrouter.ai/models/meta-llama/llama-3.1-8b-instruct |
| `anthropic/claude-haiku-4-5` | $0.80 | $4.00 | 200K | https://openrouter.ai/models/anthropic/claude-haiku-4-5 |

### Mid Tier ($0.15–$3/M input)

| Model ID | Input $/M | Output $/M | Context | URL |
|---|---|---|---|---|
| `openai/gpt-4o-mini` | $0.15 | $0.60 | 128K | https://openrouter.ai/models/openai/gpt-4o-mini |
| `anthropic/claude-sonnet-4-6` | $3.00 | $15.00 | 200K | https://openrouter.ai/models/anthropic/claude-sonnet-4-6 |
| `google/gemini-pro-1.5` | $1.25 | $5.00 | 2M | https://openrouter.ai/models/google/gemini-pro-1.5 |
| `meta-llama/llama-3.3-70b-instruct` | ~$0.40 | ~$0.40 | 128K | https://openrouter.ai/models/meta-llama/llama-3.3-70b-instruct |

### Frontier Tier (> $3/M input)

| Model ID | Input $/M | Output $/M | Context | URL |
|---|---|---|---|---|
| `openai/gpt-4o` | $5.00 | $15.00 | 128K | https://openrouter.ai/models/openai/gpt-4o |
| `anthropic/claude-opus-4-7` | $15.00 | $75.00 | 200K | https://openrouter.ai/models/anthropic/claude-opus-4-7 |
| `google/gemini-ultra-1.5` | $7.00 | $21.00 | 1M | https://openrouter.ai/models/google/gemini-ultra-1.5 |

## Quick Recommendations by Task

When time is short, these are strong defaults. Always verify current pricing at the URL.

| Task | Budget Pick | Balanced Pick | Quality Pick |
|---|---|---|---|
| Fast summarization | `google/gemini-flash-2.0` | `anthropic/claude-haiku-4-5` | `openai/gpt-4o-mini` |
| JSON extraction | `google/gemini-flash-2.0` | `openai/gpt-4o-mini` | `anthropic/claude-haiku-4-5` |
| Complex reasoning | `meta-llama/llama-3.3-70b-instruct` | `anthropic/claude-sonnet-4-6` | `anthropic/claude-opus-4-7` |
| Code generation | `meta-llama/llama-3.3-70b-instruct` | `anthropic/claude-sonnet-4-6` | `openai/gpt-4o` |
| Long-context | `google/gemini-flash-1.5` (1M ctx) | `google/gemini-pro-1.5` (2M ctx) | `anthropic/claude-sonnet-4-6` |
| Chatbot | `google/gemini-flash-2.0` | `openai/gpt-4o-mini` | `anthropic/claude-sonnet-4-6` |
