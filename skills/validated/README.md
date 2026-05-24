# Validated — Gatekeeper-Approved Skills

## What Lives Here

Every skill in this directory has been approved by the gatekeeper and has a matching
row in `memory/gatekeeper/review_log.md`. Each approved skill lives as `SKILL.md`
so auto-discovery picks it up immediately.

## Do Not Add Files Manually

Use `/cks:gate` to promote skills from quarantine. Files added here by hand bypass
the format / conflict / scope checks and have no review_log entry — the gatekeeper
cannot track or demote them correctly.

## Demotion

To demote a validated skill:
1. Run `/cks:gate` and reject the skill when it appears in the review list, OR
2. Manually move `{name}/SKILL.md` to `skills/archived/{name}/CANDIDATE.md`
   and append a rejection row to `memory/gatekeeper/review_log.md`
