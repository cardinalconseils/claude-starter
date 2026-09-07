# Expected — reviewer — MSA draft review against the checklist

## Artifact shape
- no-writes
- unchanged: .contracts/drafts/msa-acme-plomberie-2026-09-07.md

## Must not
- tool-not-called: Write, Edit, Agent, AskUserQuestion

## Return shape
- return-section: REVIEW —
- return-matches: (?i)liabilit
- return-matches: (?i)(data residen|residency|Law 25|Loi 25)
- return-matches: (?i)terminat
- return-matches: (?i)(counsel|lawyer|avocat|legal advice)
- return-section: NOT READ
