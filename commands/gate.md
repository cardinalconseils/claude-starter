---
description: "Review candidate skills in quarantine — human-gated: checks format/conflict/scope, then approve (promote to validated/) or reject (archive)"
allowed-tools: [Read, Agent, AskUserQuestion]
---

# /cks:gate [skill-name]

Run the skill lifecycle gatekeeper. Scans `skills/quarantine/` for `CANDIDATE.md` files,
runs format / conflict / scope checks on each, then fires `AskUserQuestion` for a human
verdict before any file is moved. Nothing is auto-promoted.

## Quick Reference

```
/cks:gate              # Review all candidates in quarantine
/cks:gate my-skill     # (optional) — gatekeeper still reviews all; name is informational
```

**Submission flow:**
1. Drop `skills/quarantine/{skill-name}/CANDIDATE.md` (not SKILL.md — inert by design)
2. Run `/cks:gate`
3. Approve → `skills/validated/{name}/SKILL.md` (auto-discovery active)
4. Reject → `skills/archived/{name}/CANDIDATE.md` (restorable, never live)

**Review log:** `memory/gatekeeper/review_log.md`

Agent(subagent_type="cks:gatekeeper", prompt="
  Review all candidate skills in skills/quarantine/.
  For each CANDIDATE.md found: run format/conflict/scope checks, then always fire
  AskUserQuestion for human verdict (approve / reject / skip).
  Log all verdicts to memory/gatekeeper/review_log.md.
")
