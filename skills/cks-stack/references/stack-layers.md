# CKS Stack — Full Layer Reference

## GROUP A — Build & Design

**1. Design & Mockup**
Where the product takes visual shape before a line of code is written.
*Stack: Claude.ai (mockups, UI ideation, component design), v0.dev (React component generation), Canva (marketing assets, decks), shadcn/ui (component library — design system baseline)*
*Cost: Claude Pro flat rate. v0 free tier busts fast on complex components.*

**2. Frontend**
The UI the user sees.
*Stack: Next.js, TypeScript, Tailwind CSS, shadcn/ui*
*Cost: Free to build. Vercel hosting costs scale with traffic.*

**3. APIs & Backend Logic**
Where your actual business rules live.
*Stack: Next.js API routes, Supabase Edge Functions (Deno/TypeScript), n8n (orchestration + integrations), Python (scripts, data pipelines, ML tasks)*
*Cost: n8n self-hosted on Railway = flat cost. Supabase Edge Functions included in plan.*

**4. Database & Storage**
Where data persists. Schema decisions here are the ones you live with longest.
*Stack: Supabase/Postgres (primary relational DB), Supabase Storage (files and media)*
*Cost: Supabase free tier: 500MB DB, 1GB egress, 50K MAU. Pro = $25/mo. Egress is the bill-spike risk — cache aggressively.*

**5. Auth & Permissions**
Who can do what. Wrong here = locked users or data leaks.
*Stack: Supabase Auth (JWT, OAuth, magic links), RLS policies (row-level data isolation per user/tenant)*
*Cost: Included in Supabase plan. MAU limit on free tier — 50K users before you pay per MAU.*

---

## GROUP B — Infrastructure & Deployment

**6. Hosting & Deployment**
Where code runs in production.
*Stack: Vercel (Next.js frontend + edge functions), Railway (backend services, APIs, n8n, MCP servers, Python workers)*
*Cost: Vercel Pro $20/mo. Railway usage-based — estimate every new always-on service before deploying.*

**7. CI/CD & Version Control**
How code moves from laptop to production without breaking things.
*Stack: GitHub (source of truth), GitHub Actions (automated workflows, tests, builds), Vercel auto-deploy (push to main = deploy), Railway auto-deploy (linked to GitHub branch)*
*Cost: GitHub free for public repos. Actions minutes: generous free tier, watch on heavy build pipelines.*

**8. Cloud & Compute**
Infrastructure underneath hosting.
*Stack: Vercel Edge (serverless, global), Railway containers (persistent services), Google Cloud Platform (Google API access: Maps, Places, Sheets API, OAuth + API key management for all Google services)*
*Cost: GCP free tier per API. Set quotas in GCP Console — unprotected APIs will bill silently.*

**9. API Contracts & Testing**
How you define, document, and verify your APIs.
*Stack: Bruno (open source, lives in your GitHub repo, version-controlled, zero cost)*
*Cost: Free. Always.*

---

## GROUP C — Security & Reliability

**10. Security & RLS**
Beyond auth — the layer that protects you when auth is bypassed or misconfigured.
*Stack: Supabase RLS (mandatory on every table with user data), GitHub Secrets (env vars in CI), Vercel Environment Variables, manual API key rotation policy*
*Cost: No additional cost. Implement RLS at table creation — retrofitting it is painful.*

**11. Rate Limiting**
Two separate problems: (1) inbound — protect your app from abuse; (2) outbound — cap your LLM and API spend.
*Inbound: Upstash Redis (per-IP, per-user rate limiting on your API routes)*
*Outbound spend caps: managed per provider — Anthropic Console, OpenRouter spend limits, GCP Console API quotas.*
*Cost: Upstash free tier: 10K commands/day. One abuse incident costs more than a year of Upstash.*

**12. Caching & CDN**
Reduces DB reads, egress costs, and latency simultaneously.
*Stack: Vercel Edge Cache (automatic for static assets and ISR pages), Cloudflare (DNS + CDN + DDoS protection)*
*Cost: Cloudflare free tier covers most needs. Vercel caching included in plan.*

**13. Load Balancing & Scaling**
Auto-handled until you hit architecture limits.
*Stack: Vercel auto-scaling (serverless, no config), Railway horizontal scaling (manual config when needed), Fly.io (alternative for low-latency global edge)*
*Cost: Vercel scales automatically — costs scale with it. Set spend alerts before you need them.*

---

## GROUP D — Observability & Quality

**14. Error Tracking & Logs**
Knowing when things break before users tell you.
*Stack: Sentry (frontend + backend errors, performance monitoring, session replay, uptime monitoring — replaces need for a separate uptime tool), Railway built-in logs (service-level), Vercel logs (function-level)*
*Cost: Sentry free tier: 5K errors/mo. Pro = $26/mo. Activate uptime checks in Sentry Pro — one less tool.*

**15. Observability & AI Tracing**
Two scopes: general app performance + AI agent internals. Sentry doesn't see inside LLM chains.
*Stack: Sentry Performance (APM — slow queries, request traces, web vitals), LangSmith (LLM-specific — prompt versions, token usage, chain traces, latency per step)*
*Why both: Sentry tells you the API call took 8 seconds. LangSmith tells you it was the retrieval step, not the generation.*
*Cost: LangSmith free tier: 5K traces/mo. Set up early — retroactive tracing isn't possible.*

**16. E2E Testing & UAT**
Catching regressions before users do.
*Stack: Playwright (E2E automated testing, runs in GitHub Actions on every PR), manual UAT checklist per feature before production push*
*Cost: Playwright open source. Runs on GitHub Actions free minutes.*

---

## GROUP E — AI & LLM

**17. LLM Gateway & Model Routing**
Single API entry point for all LLM calls. One key, one bill, swap models in one line of config.
*Stack: OpenRouter (primary gateway — routes to Claude, GPT-4o, Kimi K2, Gemini, Llama, Mixtral, and 200+ models)*
*Why OpenRouter over direct connections: model flexibility without code changes, one integration point, spend limits per model, usage analytics across all providers.*
*Cost: ~5-10% markup over provider pricing. Worth it for operational simplicity.*

**18. LLM Providers (via OpenRouter)**
The actual models behind the gateway. You don't integrate these directly — OpenRouter handles it.
*Stack: Claude/Anthropic (reasoning, generation, agents), OpenAI GPT-4o (general tasks), Kimi K2 (coding and development tasks), Gemini (multimodal, video processing), Llama/Mixtral (cost-sensitive tasks)*
*Exception: Anthropic SDK direct for Claude Code — it uses its own tooling outside OpenRouter.*

**19. Fast Inference (Voice-specific)**
Only relevant if you build a voice loop requiring sub-200ms LLM response time.
*Stack: Groq direct (LPU hardware — fastest open-source model inference, Llama and Mixtral only)*
*When to use: real-time voice response loops only. Everything else goes through OpenRouter.*
*Cost: Groq currently very cheap. Rates will change — don't architect around current pricing.*

**20. Voice & Telephony**
Real-time voice AI stack. Latency compounds across every hop.
*Stack: Telnyx (telephony, SIP trunking, SMS, phone number management), ElevenLabs (TTS — voice synthesis, voice cloning), Deepgram (STT — real-time speech transcription)*
*Cost: All three usage-based. Model every conversation at expected volume before launch.*

---

## GROUP F — Payments

**21. Payments & Billing**
Revenue infrastructure. Subscriptions, usage metering, invoicing, customer portal.
*Stack: Stripe (payments, subscriptions, webhooks, Stripe Customer Portal)*
*Cost: 2.9% + $0.30 per transaction. No monthly fee. Radar fraud protection included.*

---

## GROUP G — Communication & Notifications

**22. Transactional Email & Domain Email**
*Stack: Resend (outbound transactional email — receipts, magic links, system alerts), ImprovMX (inbound email aliases — forwards hello@yourdomain.com to your main Gmail, no Workspace needed), Namecheap (domain registrar + DNS management)*
*Cost: Resend free: 3K emails/mo. Pro = $20/mo. ImprovMX free tier covers most use cases. Namecheap ~$15/yr per domain.*

**23. Internal Communication & Alerts**
*Stack: Slack (primary — team communication, webhook alerts from n8n/Sentry/Stripe), Telegram (lightweight personal alerts, bot integrations)*
*Cost: Slack free tier loses history after 90 days. Pro = $7.25/user/mo. Telegram free.*

---

## GROUP H — Automation & Integration

**24. Automation & Workflows**
Connecting services without custom code. No per-execution pricing.
*Stack: n8n (self-hosted on Railway — complex multi-step workflows, MCP integrations, full control, flat cost regardless of execution volume)*
*Cost: Railway compute only. Dramatically cheaper than Make.com or Zapier at any real volume.*

---

## GROUP I — Sales & Marketing

**25. Sales Enablement & CRM**
*Stack: Apollo.io (lead database, email sequences, LinkedIn outreach, contact enrichment)*
*Cost: Apollo free: 50 credits/mo. Basic = $49/mo. Filter tightly before exporting — every export costs credits.*

---

## GROUP J — Development Environment

**26. Development Tooling**
*Stack: Claude Code (primary — agentic coding, terminal-based, full codebase context, skill + command system)*
*Cost: Included in Claude Pro/Max subscription.*

---

## Consolidation Decisions Log

| Removed | Replaced By | Reason |
|---|---|---|
| Postman | Bruno | Open source, lives in GitHub, zero cost |
| Better Uptime / Checkly | Sentry Pro uptime | Already paying for Sentry — redundant tool |
| Google Sheets as DB | Supabase | Not a real database — liability at scale |
| Groq as primary gateway | OpenRouter | OpenRouter routes Groq models too — one API key for everything |
| Groq direct (general use) | Kept for voice only | Sub-200ms voice loops need direct hardware access |
| Gemini direct | OpenRouter | Routed through OpenRouter — no separate integration |
| OpenAI direct | OpenRouter | Same — one gateway for all providers |
| Cursor | Removed | Redundant with Claude Code |
| Make.com / Zapier | n8n | Self-hosted = flat cost, more powerful |

---

## Cost Architecture Summary

**Top 5 bill-spike risks:**
1. **LLM tokens** — mitigation: OpenRouter spend limits per model, token budgets per request, cache repeated prompts
2. **Supabase egress** — mitigation: aggressive caching, Postgres views, avoid SELECT *
3. **Vercel function invocations** — mitigation: Edge caching, ISR, move heavy compute to Railway flat-rate
4. **ElevenLabs TTS characters** — mitigation: cache common phrases server-side, only invoke on confirmed active call
5. **Telnyx per-minute** — mitigation: model call duration before launch, set hard session time limits

**The rule before adding any paid tool:** Document (1) free tier limit, (2) what triggers paid, (3) estimated monthly cost at 100 users and at 1,000 users. No surprises.
