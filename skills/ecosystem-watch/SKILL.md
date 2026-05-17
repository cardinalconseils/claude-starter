---
name: ecosystem-watch
description: >
  Living knowledge store for ecosystem changes — breaking changes, opportunities, deprecations,
  and security alerts from tools in the CKS stack (Supabase, Vercel, Anthropic, n8n, GitHub Actions).
  Use when: planning database migrations, implementing new features, reviewing architecture,
  or any time you need to know if a technology you're using has changed recently.
  Always check index.md for HIGH/MEDIUM bulletins affecting your domain before planning or implementing.
allowed-tools: Read, Glob, Grep
---

# Ecosystem Watch

Living knowledge store for ecosystem changes that affect how CKS agents should build software.

## How to Use This Skill

Before planning or implementing work that touches a technology:

1. Read `skills/ecosystem-watch/index.md` — scan for HIGH/MEDIUM bulletins in the `affects` column matching your domain
2. For any matching bulletins: read the full bulletin file for the "Impact on Agents" and "Required Pattern Going Forward" sections
3. Apply those patterns in your plan or implementation — do not use the old pattern if a HIGH bulletin supersedes it

## Priority Definitions

| Priority | Meaning | Agent action |
|----------|---------|--------------|
| HIGH | Breaking change with cutover date, deprecation < 90 days, or security vuln | Change behavior now — old pattern is wrong |
| MEDIUM | New recommended pattern, pricing change, deprecation > 90 days | Inform decisions — prefer new pattern for new work |
| LOW | Blog posts, general announcements, roadmap previews | Awareness only — no behavior change required |

## Type Definitions

| Type | Meaning |
|------|---------|
| BREAKING_CHANGE | Old code will stop working after a date |
| OPPORTUNITY | New capability worth adopting |
| DEPRECATION | Feature being removed |
| ENHANCEMENT | Improvement to existing behavior |
| SECURITY | Vulnerability or security posture change |

## Priority Rubric (for classification)

```
HIGH — assign when ALL of:
  - A breaking change with a hard cutover date, OR
  - A deprecation with < 90 days notice, OR
  - A security vulnerability affecting the stack
  - AND it affects a technology in the current project stack

MEDIUM — assign when ANY of:
  - New feature that changes the recommended pattern (no breaking change)
  - New pricing tier or quota change that affects architecture decisions
  - A deprecation with > 90 days notice

LOW — everything else:
  - Blog posts, case studies, general announcements
  - Features in technologies not in the stack
  - Roadmap previews with no release date

When in doubt, go MEDIUM not HIGH. HIGH triggers a human confirmation gate.
```

## Bulletin Format

Each bulletin in `skills/ecosystem-watch/bulletins/` uses this structure:

```markdown
---
date: YYYY-MM-DD
source: source-name
title: Short descriptive title
priority: HIGH | MEDIUM | LOW
type: BREAKING_CHANGE | OPPORTUNITY | DEPRECATION | ENHANCEMENT | SECURITY
affects: [comma, separated, skill, domains]
action_required: true | false
expires: YYYY-MM-DD
---

## What Changed
[1-2 sentences — factual]

## Impact on Agents
[What agents must do differently — imperative, specific]

## Required Pattern Going Forward
[Code snippet or rule]

## Reference
[URL]
```

## Index

See `skills/ecosystem-watch/index.md` for the full catalog.

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "I know this library, I don't need to check bulletins" | The rubric catches breaking changes your training data doesn't know about. Check anyway. |
| "This is MEDIUM so I can ignore it" | MEDIUM = prefer new pattern for new work. If you're writing new code, use the new pattern. |
| "The bulletin is old" | Check the `expires` date. If not expired, it still applies. |
