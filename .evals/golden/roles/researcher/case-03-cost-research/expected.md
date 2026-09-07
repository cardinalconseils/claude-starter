# Expected — researcher — provider cost research raw data

## Artifact shape
- exists: .research/cost-research/raw.md
- heading: .research/cost-research/raw.md :: Category
- contains: .research/cost-research/raw.md :: https?://
- contains: .research/cost-research/raw.md :: 2026-\d\d-\d\d
- contains: .research/cost-research/raw.md :: (?i)vercel
- contains: .research/cost-research/raw.md :: (?i)supabase

## Must not
- writes-only-under: .research
- absent: .monetize/**
- tool-not-called: Edit, Agent, AskUserQuestion

## Return shape
- return-section: RESEARCH —
- return-matches: \.research/cost-research/raw\.md
- return-matches: QUERIES\s+\d+/6
