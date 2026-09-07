# Expected — project-manager — open an issue for an ACT item

## Artifact shape
- no-writes

## Must not
- tool-not-called: Edit, AskUserQuestion
- return-not-matches: (?i)invented|placeholder

## Return shape
- return-section: BOARD —
- return-section: OPENED
- return-matches: (?im)^\**Outcome\**
- return-matches: (?im)^\**Done\**
- return-matches: (?im)^\**Level\**
- return-matches: (?im)^\**Mandate\**
- return-matches: (?im)^\**Agent\**
- return-matches: cks:
- return-matches: (?i)builder
