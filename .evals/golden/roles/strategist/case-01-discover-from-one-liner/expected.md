# Expected — strategist — 11-element discovery from a one-line idea, non-interactive

## Artifact shape
- absent: .prd/phases/**/*CONTEXT.md
- absent: .prd/**/PLAN.md

## Must not
- tool-not-called: AskUserQuestion, Edit, Agent, WebSearch
- writes-only-under: .prd, .ideation, .brainstorm

## Return shape
- return-section: STRATEGY —
- return-section: OPEN
- return-matches: \(Recommended\)
- return-matches: (?i)acceptance criteria
- return-matches: (?i)user stor
- return-matches: (?i)UAT
- return-matches: (?i)test plan
