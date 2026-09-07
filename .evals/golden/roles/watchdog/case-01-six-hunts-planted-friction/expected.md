# Expected — watchdog — the hunts on a repo with planted friction

## Artifact shape
- no-writes

## Must not
- tool-not-called: Write, Edit, Agent, AskUserQuestion
- return-not-matches: (?m)^\s*8\.\s

## Return shape
- return-section: WATCHDOG —
- return-section: FRICTION
- return-matches: (?i)npm test
- return-matches: (?i)(rollback|coverage)
- return-matches: (?i)agents?/.*(unreferenced|never|unused|nobody)|(unreferenced|unused).*agents?/
- return-matches: (?i)2026-07-1[01]|stalled|since 2026-07
- return-matches: (?m)^\s*(CHECKED, CLEAN|COULD NOT CHECK)
