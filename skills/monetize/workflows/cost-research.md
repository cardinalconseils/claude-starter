# Workflow: Cost Research — real-world provider pricing for the stack (market side)

Gather actual pricing for every component of the product's stack — AI inference, voice,
infrastructure, third-party SaaS, communication, orchestration, data, media — from provider
pricing pages. Output is raw data in `.monetize/cost-research-raw.md`; building unit
economics from it is the finops role's job (`cost-analysis.md`).

## Prerequisites

- `.monetize/context.md` (stack detection) — required
- `.monetize/research.md` (competitor pricing context) — helpful, not required

## 1. Detect cost categories

Read `.monetize/context.md` and keep only the categories with signals:

| Category | Signals |
|---|---|
| AI/ML inference | LLM, GPT, Claude, embeddings, AI, ML, model, inference, NLP |
| Speech/voice | TTS, STT, speech, voice, transcription, dictation, voice agent |
| Infrastructure | hosting, compute, server, database, storage, CDN, bandwidth |
| Third-party SaaS | auth (Clerk, Auth0), payments (Stripe), monitoring, analytics |
| Communication | telephony, Twilio, Telnyx, SMS, email, push |
| Orchestration/agent | Vapi, Bland, Retell, LiveKit, agent platform, workflow engine |
| Data/storage | vector DB, pgvector, Redis, S3, data pipeline |
| Media | image generation, video processing, streaming |

Skip categories with no signals and list them as skipped with the reason.

## 2. Research each category — top 3–5 providers

Per provider: `WebSearch` "{provider} pricing {year}" → `WebFetch` the pricing page →
extract billing unit, tiers, free tier limits, volume discounts. Real pricing pages, not
blog posts about pricing. Gated or unavailable page → note the gap, use the best available
data.

Example query sets:
- AI/ML: "OpenAI API pricing per token", "Anthropic API pricing per token", "Google AI
  API pricing", "open source LLM hosting cost per token", "embedding API pricing"
- Voice: "TTS API pricing per character", "STT API pricing per minute", "real-time voice
  AI pricing per minute"
- Infra: "cloud hosting pricing comparison", "managed Postgres pricing per GB", "CDN
  pricing per GB"
- Communication: "Twilio pricing per minute", "Telnyx pricing per minute", "transactional
  email pricing"
- SaaS: "Stripe fees", "auth pricing per MAU", "monitoring pricing per event"

## 3. Capture per provider

```markdown
### {Provider}
- **Service:** {what it provides}
- **Billing Unit:** {per token / minute / request / GB / MAU}
- **Free Tier:** {limits or "none"}
- **Pricing Tiers:**
  | Tier | Price | Included | Overage |
  |------|-------|----------|---------|
- **Volume Discounts:** {details or "none published"}
- **Source:** {URL}
- **Date Verified:** {date}
```

## 4. Save

`.monetize/cost-research-raw.md` when `.monetize/` is in the running role's write scope;
otherwise `.research/cost-research/raw.md`, returning the path so the strategist can place
it under `.monetize/`. Contents:

```markdown
# Cost Research — Raw Provider Pricing

**Generated:** {date}
**Source:** WebSearch + WebFetch (provider pricing pages)
**Categories Researched:** {list}
**Categories Skipped:** {list with reason}

## Category: {name}
{provider entries}
```

## Constraints

- Autonomous — no questions to the user.
- Always cite the URL and the date verified; pricing has a shelf life.
- No cost models, no monetization verdicts — those belong to finops and the strategist.
