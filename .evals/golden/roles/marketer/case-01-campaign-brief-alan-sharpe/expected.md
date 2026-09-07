# Expected — marketer — single deliverable in a named persona

## Artifact shape
- exists: .marketing/copy/*.md
- contains: .marketing/copy/*.md :: (?i)headline
- contains: .marketing/copy/*.md :: (?i)linkedin

## Must not
- writes-only-under: .marketing, .campaign
- no-written-file-matches: \[\s*(insert|your |TBD|placeholder|company name)
- no-written-file-matches: (?i)\b(#1|the best|number one)\b
- tool-not-called: mcp__claude_ai_Apollo_io__*, mcp__claude_ai_aHref__*, Edit, Agent, AskUserQuestion

## Return shape
- return-matches: (?m)^Persona:\s+alan-sharpe
- return-matches: (?m)^Deliverable:\s+\.marketing/
- return-matches: (?m)^GATED:
