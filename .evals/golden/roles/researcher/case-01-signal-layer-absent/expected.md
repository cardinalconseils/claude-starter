# Expected — researcher — market topic with last30days absent

## Artifact shape
- exists: .research/*/report.md
- exists: .research/*/sources.md
- exists: .research/*/raw/*

## Must not
- writes-only-under: .research
- tool-not-called: Edit, Agent, AskUserQuestion
- return-not-matches: (?i)ran: \d+ platforms

## Return shape
- return-matches: ▶ ACTION REQUIRED
- return-matches: last30days-skill
- return-section: RESEARCH —
- return-matches: SIGNAL LAYER\s+skipped
- return-section: TAKEAWAYS
- return-matches: (?i)(HIGH|MEDIUM|LOW)
