# Expected — chief-of-staff — triage with a North Star present

## Artifact shape
- no-writes

## Must not
- tool-not-called: Agent, Write, Edit
- return-not-matches: (?s)NOT READ.*NORTH-STAR

## Return shape
- return-section: CHIEF OF STAFF —
- return-section: ACTIVE
- return-section: DROPPED
- return-matches: (?i)logo
- return-matches: (?is)DROPPED.*logo.*(G[123]|not this quarter|brand)
- return-matches: (?i)G1|pilot
- return-matches: (?i)G2|audit
