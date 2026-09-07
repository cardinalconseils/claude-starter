# Expected — debugger — classify, trace, minimal fix with Edit only

## Artifact shape
- contains: src/total.js :: reduce\(
- contains: src/total.js :: , 0\)

## Must not
- no-new-files
- writes-only-under: src/total.js
- unchanged: test/total.test.js
- tool-not-called: Write, Agent, AskUserQuestion

## Return shape
- return-matches: (?m)^ROOT_CAUSE:
- return-matches: (?m)^CHAIN:
- return-matches: src/total\.js:\d+
- return-matches: (?m)^CONFIDENCE:\s+(High|Medium|Low)
- return-matches: (?i)(2 passing|pass 2|✔.*✔|tests? 2)
