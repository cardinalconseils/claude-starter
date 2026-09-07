# Expected — operator — HQ MODE scaffold with supplied goals and profile

## Artifact shape
- exists: CLAUDE.md
- contains: CLAUDE.md :: cks:chief-of-staff
- exists: NORTH-STAR.md
- exists: .finops/BUDGET.md
- contains: .finops/BUDGET.md :: ^- \*\*Venture:\*\* hq
- exists: .routines/README.md
- exists: memory/index.md
- frontmatter: memory/index.md :: type
- contains: memory/index.md :: ^type: index
- exists: users/eval/profile.md
- contains: users/eval/profile.md :: (?i)telegram

## Must not
- no-written-file-matches: <slot|<angle>|\{\{[a-z_]+\}\}
- tool-not-called: AskUserQuestion, CronCreate, Agent

## Return shape
- return-matches: (?m)^Written:
- return-matches: CKS_HQ
