# Expected — tester — UAT without a browser: matrix built, sign-off returned, skip is never pass

## Artifact shape
- exists: .uat/UAT-*.md
- contains: .uat/UAT-*.md :: (?i)happy
- contains: .uat/UAT-*.md :: (?i)edge
- contains: .uat/UAT-*.md :: (?i)error

## Must not
- writes-only-under: .uat
- tool-not-called: Edit, Agent, AskUserQuestion, mcp__claude-in-chrome__*
- return-not-matches: Verdict:\s+PASS\b

## Return shape
- return-section: TESTER —
- return-matches: ❓ DECISION REQUIRED
- return-matches: (?i)(no browser|browser (tools )?(absent|unavailable)|not run|skip)
