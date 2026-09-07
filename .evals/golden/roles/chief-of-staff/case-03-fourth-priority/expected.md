# Expected — chief-of-staff — a fourth priority arrives

## Artifact shape
- no-writes

## Must not
- tool-not-called: Agent, Write, Edit
- return-not-matches: (?m)^\s*4\.\s

## Return shape
- return-section: CHIEF OF STAFF —
- return-section: NEEDS YOU
- return-matches: (?i)displac
- return-matches: (?i)recommend
- return-matches: (?i)wrong city|mobile
