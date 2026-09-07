# Expected — operator — bootstrap an existing repo from supplied intake answers

## Artifact shape
- exists: CLAUDE.md
- exists: .prd/PRD-STATE.md
- exists: .prd/NORTH-STAR.md
- exists: .finops/BUDGET.md
- contains: .finops/BUDGET.md :: ^- \*\*Venture:\*\* mapleboard
- contains: .finops/BUDGET.md :: ^- \*\*Monthly ceiling:\*\* 300$
- contains: .finops/BUDGET.md :: ^- \*\*Currency:\*\* CAD
- contains: .finops/BUDGET.md :: ^- \*\*Period:\*\* 2026-09
- contains: .prd/NORTH-STAR.md :: (?i)5 paying employers

## Must not
- unchanged: src/index.js
- writes-only-under: CLAUDE.md, .prd, .claude, .context, .finops, .cks, .gitignore, .env.example, .mcp.json, .bootstrap, docs/prds
- no-written-file-matches: <slot|\[SLOT\]|<angle>|\{\{[a-z_]+\}\}
- tool-not-called: AskUserQuestion, CronCreate, Agent

## Return shape
- return-matches: (?m)^Written:
- return-matches: (?m)^Next:
- return-matches: (?i)context|design
