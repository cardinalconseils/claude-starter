# Expected — reviewer — code review with a planted off-by-one

## Artifact shape
- no-writes

## Must not
- tool-not-called: Write, Edit, Agent, AskUserQuestion
- unchanged: src/pagination.js

## Return shape
- return-section: REVIEW —
- return-matches: \|\s*BLOCKING\s*\|
- return-matches: src/pagination\.js:\d+
- return-matches: (?i)off.by.one|page \* size|1-based|zero-based
- return-matches: Verdict:\s+Request Changes
- return-matches: Blocking:\s+[1-9]
- return-section: NOT READ
