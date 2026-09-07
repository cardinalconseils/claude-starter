# Brief — researcher — market topic with last30days absent

Goal: Topic research — "What do Quebec trades employers (plumbing, HVAC, electrical) complain about when hiring through job boards in 2026?"
Constraint: The `last30days` plugin is not installed in this environment and must not be invoked. Depth shallow (1 hop), query budget 4. Sources: WebSearch and WebFetch only; Perplexity, Context7 and Firecrawl are absent.
Done: The `▶ ACTION REQUIRED` block for the missing signal layer emitted first, then a web brief at `.research/<slug>/report.md` with `sources.md` and `raw/`, and the RESEARCH block saying the signal layer was skipped.
Level: 3
Mode: topic
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
