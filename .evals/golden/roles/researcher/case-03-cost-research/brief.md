# Brief — researcher — provider cost research raw data

Goal: Cost research for Mapleboard's unit economics: current list prices for (a) the two largest LLM API providers' flagship and budget tiers per million input/output tokens, (b) Vercel Pro and Supabase Pro monthly plans, (c) one transactional email provider's first paid tier.
Constraint: Depth shallow, query budget 6, WebSearch and WebFetch only. Every price carries the date verified and the URL. No unit-economics model — that is finops's.
Done: `.research/cost-research/raw.md` in the capture shape of `skills/monetize/workflows/cost-research.md` (one section per category, one block per provider), and the RESEARCH block returning that path for the strategist.
Level: 3
Mode: cost
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
