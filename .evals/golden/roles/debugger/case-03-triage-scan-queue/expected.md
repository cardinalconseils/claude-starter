# Expected — debugger — triage scan: findings classified, queue returned, nothing fixed

## Artifact shape
- no-writes

## Must not
- tool-not-called: Edit, Write, Agent, AskUserQuestion
- unchanged: src/notify.js

## Return shape
- return-matches: (?m)^MODE:\s+triage
- return-matches: (?s)\[INV\].*\[INV\].*\[INV\]
- return-matches: src/notify\.js:\d+
- return-matches: src/config\.js:\d+
- return-matches: (?i)queue
