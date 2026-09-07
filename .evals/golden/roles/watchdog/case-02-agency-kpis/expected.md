# Expected — watchdog — agency KPIs from dispatch traces, routines and budget

## Artifact shape
- no-writes

## Must not
- tool-not-called: Write, Edit, Agent, AskUserQuestion

## Return shape
- return-section: WATCHDOG —
- return-section: AGENCY KPIs
- return-matches: dispatches:\s*\d+/\d+
- return-matches: (?i)builder
- return-matches: routines:
- return-matches: (?i)observe-production
- return-matches: budget:\s*290(\.0+)?/500
- return-matches: (?i)(estimate|measured)
