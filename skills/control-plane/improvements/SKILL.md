---
name: control-plane/improvements
description: "Self-improvement loop — analyze session patterns, propose rule/persona/workflow improvements, apply accepted proposals"
allowed-tools: [Read, Bash, Write, Edit, Grep, Glob, AskUserQuestion]
---

# Control Plane — Self-Improvement Loop

File-first. Agent reasons; bash triggers and stores. Supabase is optional durability.

## Proposal Storage

```
.cks/control-plane/improvements/
  pending/YYYY-MM-DD-NNN.md   ← awaiting user decision
  accepted/YYYY-MM-DD-NNN.md  ← applied improvements
  rejected/YYYY-MM-DD-NNN.md  ← rejected with reason
```

ID format: `YYYY-MM-DD-001`, `YYYY-MM-DD-002`, etc. Padded to 3 digits. Reset per day.

## Analysis Sources

Read in this order. Skip gracefully if file absent.

| Priority | Source | Path | What to look for |
|----------|--------|------|-----------------|
| 1 | Control plane gotchas | `.cks/control-plane/memory/project/gotchas.md` | Recurring traps (2+ entries about same domain) |
| 2 | Project learnings gotchas | `.learnings/gotchas.md` | Same — cross-reference with CP gotchas |
| 3 | Decisions | `.cks/control-plane/memory/project/decisions.md` | Patterns that should become rules |
| 4 | Session snapshots | `.cks/control-plane/memory/sessions/*.md` | Repeated next-actions, recurring phases |
| 5 | RAID log | `.cks/control-plane/raid/raid.md` | Open risks that haven't closed after 3+ sessions |
| 6 | Conventions file | `.learnings/conventions.md` | Proposed items not yet promoted |
| 7 | Existing rules | `.claude/rules/*.md` | Avoid proposing duplicates |

## Analysis Algorithm

1. **Frequency scan** — grep each source for recurring terms. Threshold: 2+ occurrences = signal; 3+ = strong signal.
2. **Gap scan** — look for gotchas/risks that exist in `.learnings/` but have no corresponding `.claude/rules/` file.
3. **Stale RAID scan** — RAID items open across 3+ session snapshots without mitigation = systemic risk → propose rule or workflow.
4. **Convention backlog scan** — `.learnings/conventions.md` entries with status "Proposed" older than 14 days → surface as improvement candidates.
5. **Persona drift scan** — if session snapshots show consistent role-specific issues, consider whether a persona needs an update.

## Proposal Types

| Type | Target | When to use |
|------|--------|-------------|
| `rule` | `.claude/rules/{topic}.md` | Pattern that agents should always follow; confidence ≥ 75 |
| `persona` | `.cks/control-plane/personas/{name}.md` | Persona behavior needs updating based on observed gaps |
| `workflow` | `.claude/rules/learnings.md` | Shorter convention that doesn't warrant a standalone rule file |
| `convention` | `.learnings/conventions.md` | Project-specific; too narrow for a global rule |

## Apply Mechanism

**rule proposals:**
- If `.claude/rules/{topic}.md` exists → use Edit (append new section or patch existing)
- If it does not exist → use Write (create from proposal's "Proposed Change" block)
- Mark proposal as `accepted`, move to `accepted/`

**persona proposals:**
- Edit the target `.cks/control-plane/personas/{name}.md`
- Mark proposal as `accepted`, move to `accepted/`

**workflow / convention proposals:**
- Append to `.claude/rules/learnings.md` or `.learnings/conventions.md`
- Mark proposal as `accepted`, move to `accepted/`

**Never auto-apply without explicit `--apply <id>` call.**

## Confidence Scoring

| Score | Meaning | Auto-propose? |
|-------|---------|--------------|
| ≥ 85 | High — observed 3+ times across different sources | Yes |
| 60–84 | Medium — observed 2 times | Yes, flagged as medium |
| < 60 | Low — single observation | No — skip |

## Deduplication

Before writing any proposal, grep `pending/` and `accepted/` for the proposed target file. If a proposal for the same target exists and is pending, do not create a duplicate.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The pattern might be coincidence" | Two observations is the threshold. Trust the data. |
| "The rule already exists somewhere" | Check `.claude/rules/` first. If covered, skip. |
| "I should auto-apply high-confidence proposals" | Never. Apply only on explicit `--apply <id>`. User owns the rules. |
| "Low-confidence proposals are still worth surfacing" | Below 60 = noise. Surfacing noise erodes trust in the loop. |

## Verification

- [ ] Every proposal has ≥ 2 evidence data points
- [ ] Confidence < 60 proposals are not written to pending/
- [ ] Target file is specified in every proposal
- [ ] No duplicate proposals for same target when one is already pending
- [ ] `--apply` moves file to accepted/ and makes the edit
- [ ] `--reject` captures reason in the file before moving to rejected/
