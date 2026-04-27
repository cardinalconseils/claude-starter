---
name: openrouter
description: >
  OpenRouter AI gateway for target projects. Use when: the project calls AI APIs,
  needs model selection advice, wants cost optimization across providers, requires
  fallback reliability, or is deciding between OpenRouter vs direct frontier APIs.
  Covers live model research, human-in-the-loop selection, routing config, and
  .env setup.
allowed-tools: Read, Write, Edit, WebFetch, AskUserQuestion, Glob, Grep
---

# OpenRouter — AI Gateway for Target Projects

## What OpenRouter Is

A unified API gateway that routes requests to 300+ models (Anthropic, OpenAI, Google, Meta, Mistral, etc.) through a single endpoint. One API key, one billing account, automatic fallbacks.

**This skill is for target projects built with CKS — not for CKS's own agents**, which run inside Claude Code and use its model routing.

## When to Use OpenRouter vs Direct Frontier API

| Scenario | Use Direct API | Use OpenRouter |
|---|---|---|
| Single model, simple usage, prototype stage | ✅ Simpler | — |
| Need Anthropic-native features (prompt caching, extended thinking) | ✅ Native support | ✗ May not pass through |
| Varied workloads (cheap tasks + expensive tasks) | ✗ Pay frontier price for everything | ✅ Route by task type |
| Need reliability / failover | ✗ Single point of failure | ✅ Automatic fallbacks |
| Calling 3+ different providers | ✗ 3 keys, 3 SDKs, 3 bills | ✅ One of each |
| Cost cap required | ✗ No ceiling | ✅ `maxPrice` per request |
| Privacy / no data retention required | — | ✅ `dataCollection: 'deny'` |

**Rule of thumb**: Start direct for prototypes. Switch to OpenRouter when you have more than one task type, need reliability, or costs start mattering.

## Integration Pattern — Drop-in OpenAI SDK Replacement

No rewrite required if already using the OpenAI SDK:

```typescript
import OpenAI from 'openai';
const ai = new OpenAI({
  baseURL: 'https://openrouter.ai/api/v1',
  apiKey: process.env.OPENROUTER_API_KEY,
});
```

Or use the native OpenRouter SDK:
```bash
npm install @openrouter/sdk
```
```typescript
import OpenRouter from '@openrouter/sdk';
const client = new OpenRouter({ apiKey: process.env.OPENROUTER_API_KEY });
```

## Model Selection Workflow

When a target project needs AI model selection, trigger the model research workflow:
`skills/openrouter/workflows/model-research.md`

The workflow:
1. Identifies the task type from context
2. Fetches live model catalog from OpenRouter API
3. Ranks candidates against task-profile criteria
4. Presents top 3–5 to the human with price, pros/cons, and URL
5. Writes human's selection to `.env.example`

## Routing Configuration Reference

```typescript
// Sort by priority
provider: { sort: 'price' }       // cheapest
provider: { sort: 'throughput' }  // fastest tokens/sec
provider: { sort: 'latency' }     // lowest time-to-first-token

// Model name shortcuts (append to model string)
'anthropic/claude-haiku-4-5:nitro'  // sort by throughput
'anthropic/claude-haiku-4-5:floor'  // sort by lowest price

// Fallback chain (try in order, bill at winner's rate)
models: ['anthropic/claude-sonnet-4-6', 'google/gemini-flash-1.5']

// Pin or block providers
provider: { only: ['anthropic'] }
provider: { ignore: ['deepinfra'] }

// Cost ceiling ($/M tokens)
provider: { maxPrice: { prompt: 1, completion: 2 } }

// Privacy
provider: { dataCollection: 'deny' }  // non-logging providers only
provider: { zdr: true }               // zero data retention

// Caching (free repeated calls)
headers: { 'X-OpenRouter-Cache': 'true', 'X-OpenRouter-Cache-TTL': '600' }
```

## Environment Variables Template

```bash
# AI Gateway
OPENROUTER_API_KEY=sk-or-...        # Required — from https://openrouter.ai/keys

# Model assignments by task type (set by /cks:openrouter or kickstart)
OPENROUTER_MODEL_FAST=              # e.g. google/gemini-flash-2.0
OPENROUTER_MODEL_REASON=            # e.g. anthropic/claude-sonnet-4-6
OPENROUTER_MODEL_HEAVY=             # e.g. anthropic/claude-opus-4-7
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll just use claude-sonnet for everything" | Simple tasks (summarization, extraction) cost 10–50x more than necessary on frontier models |
| "OpenRouter adds latency" | Overhead is ~50ms per request — negligible vs model inference time |
| "Direct API is simpler" | True for one model, one provider. Breaks the moment you add a second model or need fallback |
| "I'll optimize costs later" | Routing is architectural — retrofitting it later requires touching every API call |
| "OpenRouter might go down" | So will Anthropic. Fallbacks protect against both — use `models: [...]` array |

## Verification

- [ ] `OPENROUTER_API_KEY` in `.env.example` with placeholder value
- [ ] `OPENROUTER_MODEL_*` vars documented for each task tier used
- [ ] At least one fallback model configured for critical paths
- [ ] Privacy setting matches project requirements (`dataCollection` if needed)
- [ ] Model URLs verified: `https://openrouter.ai/models/{provider}/{model}`
