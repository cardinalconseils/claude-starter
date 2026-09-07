# Expected — project-manager — work-hierarchy update

## Artifact shape
- exists: .prd/work-hierarchy.md
- frontmatter: .prd/work-hierarchy.md :: version
- contains: .prd/work-hierarchy.md :: id: T-01-03
- contains: .prd/work-hierarchy.md :: Add applicant CSV export button
- contains: .prd/work-hierarchy.md :: id: T-01-01

## Must not
- writes-only-under: .prd
- tool-not-called: Edit, AskUserQuestion

## Return shape
- return-section: BOARD —
- return-section: STATE
- return-matches: work-hierarchy\.md
