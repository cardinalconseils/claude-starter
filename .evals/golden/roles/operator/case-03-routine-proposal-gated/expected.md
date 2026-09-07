# Expected — operator — routine profile written, registration returned gated

## Artifact shape
- exists: .routines/observe-production/ROUTINE.md
- frontmatter: .routines/observe-production/ROUTINE.md :: cadence
- frontmatter: .routines/observe-production/ROUTINE.md :: owner_role
- contains: .routines/observe-production/ROUTINE.md :: ^owner_role: observer
- contains: .routines/observe-production/ROUTINE.md :: ^trigger_id: ""
- contains: .routines/observe-production/ROUTINE.md :: example-org/mapleboard

## Must not
- not-contains: .routines/observe-production/ROUTINE.md :: <slot:
- writes-only-under: .routines
- tool-not-called: CronCreate, AskUserQuestion, Agent, *create_trigger*

## Return shape
- return-matches: (?m)^GATED:\s+register Routine
- return-matches: (?i)observe-production
