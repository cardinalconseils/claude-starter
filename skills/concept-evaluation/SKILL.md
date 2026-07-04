---
name: concept-evaluation
description: "CKS concept feasibility evaluation — scoring rubrics, dual-mode detection, pillar frameworks, Go/Defer/Reject thresholds, and specialist-trigger conditions. Use when evaluating whether a concept should be added to the CKS plugin or a CKS-powered project."
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
---

# Concept Evaluation Skill

Domain knowledge for evaluating whether a new concept should be added to CKS or a project.

## Input Types

`/cks:concept` accepts four input types. The orchestrator detects automatically:

| Input type | Examples | What Step 0 does |
|---|---|---|
| `url` | `https://github.com/some-tool`, article URL, docs page | Fetches page/README, extracts concept brief |
| `text` | Pasted YouTube transcript, PDF extract, guide > 100 words | Parses inline, extracts concept brief |
| `description` | "add voice transcription skill" | No ingestion — use as-is |
| `prune` | "evaluate retiring cks:schedule" | Evaluates removing a concept with no replacement |

## Concept Type Taxonomy

Classify the concept before scoring. Type affects Technology Fit scoring.

| Type | Description |
|---|---|
| command | New `/cks:*` slash command |
| agent | New subagent dispatched by a command or orchestrator |
| skill | New domain knowledge loaded via `skills:` frontmatter |
| hook | New automation event handler (SessionStart, PreToolUse, etc.) |
| workflow | New `workflows/*.md` progressive-disclosure document |
| rule | New `.claude/rules/*.md` guardrail |
| integration | New MCP server or external service connection |
| enhancement | Modification to an existing component |
| multi | Spans multiple types above |
| prune | Evaluation of retiring an existing concept with no replacement |

## Dual-Mode Detection

The orchestrator detects context at startup:

| Signal | Mode | What "value" means |
|---|---|---|
| `.claude-plugin/plugin.json` exists | **plugin** | Value to CKS plugin + its users (vibe coders, marketers, biz dev) |
| `CLAUDE.md` or `.prd/PRD-STATE.md` exists, no `plugin.json` | **project** | Value to this specific project's users + roadmap |

## Scoring Rubrics (1–5)

### Pillar 1 — Business Value
Does this concept earn its place?

| Score | Signal |
|-------|--------|
| 5 | Fills a gap in the 5-phase lifecycle; users are visibly blocked without it |
| 4 | Speeds up a common workflow; clear, measurable time savings |
| 3 | Nice-to-have; reduces friction but a workaround exists |
| 2 | Marginal improvement; duplicates something already possible |
| 1 | No evidence of demand; solves a problem nobody has |

**Lean & Clean modifiers** (apply after base score):

| Signal | Modifier |
|---|---|
| Concept replaces a weaker existing concept — net neutral count | +0.5 |
| Concept eliminates two or more weaker concepts — net reduction in surface area | +1.0 |
| Concept duplicates existing capability without replacing it | cap BV at 2 regardless of base score |

Evidence sources: existing commands/agents gap analysis, CLAUDE.md philosophy fit, PRD lifecycle phase mapping, user friction signals, supersession scan results from Step 3.5.

### Pillar 2 — Technology Fit
Does this slot into CKS architecture cleanly?

| Score | Signal |
|-------|--------|
| 5 | Pure Command→Agent→Skill pattern; no new tool types needed |
| 4 | Needs one new agent or skill; clean extension of existing patterns |
| 3 | Requires hook or workflow addition; bounded, explainable impact |
| 2 | Requires external MCP or new tooling; non-trivial wiring |
| 1 | Breaks existing patterns; architectural surgery required |

Evidence sources: `agents/` listing, `hooks/hooks.json`, `tools/`, `.claude-plugin/plugin.json`.

### Pillar 3 — Data Impact
What does it read/write, what can it break?

| Score | Signal |
|-------|--------|
| 5 | Read-only or writes to a new isolated directory; zero blast radius |
| 4 | Writes to `.prd/` or `.assess/` but additive only |
| 3 | Modifies existing state files; migration or deprecation notes needed |
| 2 | Touches `CLAUDE.md`, `plugin.json`, or hook scripts |
| 1 | Rewrites core state; high regression risk on existing commands |

Evidence sources: Glob/Grep for files the concept would touch, PRD-STATE.md schema, existing `.prd/` and `.assess/` structure.

## Go/Defer/Reject Thresholds

Overall = average(Business Value, Technology Fit, Data Impact)

| Score | Recommendation | Meaning |
|---|---|---|
| >= 4.0 | **Go** | Strong case; proceed to implementation |
| 2.5–3.9 | **Defer** | Conditions listed; re-evaluate when met |
| < 2.5 | **Reject** | Not worth the cost; reasoning stated |

## Supersession Scan (Step 3.5)

Before brainstorming, the orchestrator MUST scan for conceptual overlap. This is not optional.

```bash
# Extract 3–5 keywords from the concept brief
grep -rl "{keyword}" commands/ agents/ skills/ 2>/dev/null
```

**If overlap found:**
- List matched components with file paths and one-line descriptions
- Surface DECISION REQUIRED block (Replace / Enhance / Add-alongside / Prune)
- Wait for user decision before proceeding to brainstorming
- Record decision — it feeds the BV Lean & Clean modifier and FEASIBILITY.md

**If no overlap:**
- Note "no existing concept overlap detected"
- BV modifier = 0 (neutral)

## Specialist Trigger Conditions

Pillar workers fire these indeterministically — only when evidence warrants:

| Signal in concept | Specialist | Fires in pillar |
|---|---|---|
| "LLM", "prompt", "AI", "evals", "judge", "model" | `cks:evals-runner` | tech-fit |
| "auth", "secrets", "API key", "webhook", "token" | `cks:security-auditor` | data-impact |
| "database", "schema", "RLS", "migration", "table" | `cks:db-investigator` | data-impact |
| "schedule", "cron", "recurring", "daily", "weekly" | `cks:scheduler` | tech-fit |

Specialist failure never blocks the pillar — score inline and note the gap.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The concept is obvious, skip brainstorming" | Brainstorming surfaces edge cases and tradeoffs that look obvious only in hindsight. Always run it. |
| "I can score this pillar without reading the files" | Scores without evidence are opinions. Read the files, grep the codebase, show the facts. |
| "The blast radius is probably small" | "Probably" is not a score. Run Glob/Grep and report what you find. |
| "Business value is clear, no need to check lifecycle fit" | Check which of the 5 phases it strengthens. If it doesn't map to a phase, the value claim is weak. |
| "Technology fit is 5 because it's just a new agent" | Check tool requirements, worktree safety, and state schema impact before scoring 5. |
| "Reject is too harsh, I'll give it a 2.5" | If evidence doesn't support the score, the score is wrong. Reject with clear reasoning is more useful than an inflated Defer. |

## Verification Checklist

- [ ] Input type detected (url / text / description / prune)
- [ ] Step 0 External Resource Ingestion run (if input is url or text)
- [ ] Concept type classified
- [ ] Mode detected (plugin vs project)
- [ ] Step 3.5 Supersession Scan completed — overlap found or confirmed absent
- [ ] If overlap found: DECISION REQUIRED block shown and user decision recorded
- [ ] Brainstorming completed before scoring
- [ ] All three pillars scored with file-level evidence
- [ ] BV Lean & Clean modifier applied (or confirmed zero)
- [ ] Specialist triggered (or explicitly skipped with reason)
- [ ] Overall score computed as average
- [ ] FEASIBILITY.md written to `.concept/{slug}/` with all required sections
- [ ] FEASIBILITY.md includes `## External Resource` (or N/A note)
- [ ] FEASIBILITY.md includes `## Continuous Improvement Impact`
- [ ] Klein Pre-Mortem gate asked for Go verdicts (user may skip — gate must appear)
- [ ] Recommendation includes plain-language reasoning
- [ ] Next step is mode-appropriate (branch for plugin, /cks:new for project)

## Progressive Disclosure

For full 1–5 rubric detail, decision matrix, and evidence source examples:
→ Read `skills/concept-evaluation/workflows/pillar-scoring.md`
