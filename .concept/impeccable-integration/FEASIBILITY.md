# Concept Feasibility: Integrate impeccable (design-fluency skill + visual-slop linter)
Evaluated: 2026-05-22 | Mode: plugin | Type: multi (skill + command + enhancement)

## Executive Summary
Impeccable is a mature, Apache-2.0 design-fluency toolkit (1 skill, 23 design-verb commands, 7 domain reference files, and a no-API-key deterministic "AI-slop" linter) that ships in the exact Claude Code plugin format CKS uses. CKS has design surface (prd-designer, design-system, accessibility) but no design-vocabulary command set and no visual-slop detector — impeccable fills a real gap. The clean recommendation is to adopt selectively (reference files into a CKS skill + the `npx impeccable detect` linter as an optional review-gate step) rather than bulk-importing 23 commands that would collide with the thin-dispatcher pattern.

## Scores
| Pillar         | Score | Key Finding |
|----------------|-------|-------------|
| Business Value |  4/5  | Fills genuine design-vocabulary + visual-slop gap; complements code-focused anti-patterns skill |
| Technology Fit |  3/5  | Same plugin/skill format, but 23-command mega-skill clashes with CKS thin-dispatcher; needs adaptation |
| Data Impact    |  4/5  | Linter is read-only; reference files are additive new skill dir; CLI adds an optional Node dependency |
| **Overall**    |**3.7/5**|             |

## Brainstorm Notes
- impeccable is itself a Claude Code plugin (`plugin/.claude-plugin/plugin.json`, `skills: "./skills/"`) — installable side-by-side, format-compatible with CKS.
- It is structured as ONE mega-skill (`/impeccable`) with 23 sub-commands routed inside SKILL.md via a routing table. CKS prefers many thin `/cks:*` commands → agent → skill. Direct import would violate `.claude/rules/commands.md` (thin dispatchers, <60 lines) if each verb became a command embedding routing logic.
- Three viable adoption shapes surfaced:
  1. **Visual-slop linter only** — wrap `npx impeccable detect` as an optional sprint/review verification step. Lowest risk, read-only, complements `skills/anti-patterns` (which covers code/process slop, NOT visual tells).
  2. **Reference absorption** — pull the 7 domain refs (typography, OKLCH color, motion, spatial, interaction, responsive, UX writing) into a new `skills/design-fluency` consumed by prd-designer / luv-designer / design-system-generator.
  3. **Full skill bundling** — vendor the whole impeccable skill, keep its 23-verb surface intact under one `/cks:impeccable` entry. Largest footprint, least CKS-idiomatic.
- Recommended refined concept = combine (1) + (2): a `design-fluency` skill plus the linter as an optional review gate. Apache-2.0 + NOTICE.md attribution required.
- DECISION POINTS FOR USER (could not run AskUserQuestion — this agent runs in subagent context where the tool is unavailable):
  - a) Bundle the full skill vs. selectively absorb references?
  - b) Add `npx impeccable detect` as a runtime dependency vs. reference-only guidance (no new dep)?
  - c) Expose design verbs (bolder/quieter/distill) as CKS commands, or only as skill knowledge invoked by existing design agents?

## Pillar 1 — Business Value
Score: 4/5. Evidence-based gap analysis:
- CKS design surface today: `commands/design.md` (Phase 2 lifecycle design via `cks:prd-designer` + Stitch MCP), `commands/design-system.md`, `skills/design-system/SKILL.md` (DESIGN.html generation), `skills/accessibility/SKILL.md` (WCAG 2.1 AA), agents `luv-designer`, `prd-designer`, `design-system-generator`.
- CKS `skills/anti-patterns/SKILL.md` explicitly covers **code / process / output / PRD-doc** anti-patterns ("Wrapper Bloat", "Defensive Noise") — it does NOT cover **visual** AI slop. Impeccable's 27 deterministic rules (`cli/engine/registry/antipatterns.mjs`: `side-tab`, `overused-font`, `gradient-text`, `ai-color-palette`, `nested-cards`, `monotonous-spacing`) target exactly the missing visual layer.
- CKS has no design-vocabulary verb set. Impeccable's `polish / bolder / quieter / distill / animate / harden / clarify` give vibe-coders precise design steering — directly aligned with CKS's "from idea to production, no coding required" philosophy (CLAUDE.md) and the Candidate/Production maturity gates that demand accessibility + polish.
- Maps cleanly to lifecycle Phase 2 (Design) and Phase 4 (Review). The deterministic linter is a natural addition to the verification.md evidence requirement for UI changes.
- Not a 5: CKS already designs UI (prd-designer + Stitch), so this is a quality/precision uplift rather than unblocking a fully-blocked workflow.

## Pillar 2 — Technology Fit
Score: 3/5. Architecture-fit evidence:
- Format compatibility is high: impeccable's `skill/SKILL.md` uses standard frontmatter (`name`, `description`, `allowed-tools`, `argument-hint`) and a `reference/` + `scripts/` subdirectory layout — identical to CKS's `skills/*/SKILL.md` + `workflows/`/`references/` convention (`.claude/rules/skills.md`).
- Structural mismatch lowers the score: impeccable is a single mega-skill routing 23 sub-commands inside SKILL.md (the Commands table + Routing rules section). CKS rule `.claude/rules/commands.md` requires thin command dispatchers (<60 lines, no embedded workflow logic) that dispatch agents. Importing the 23 verbs as CKS commands would either (a) embed routing logic (rule violation) or (b) require building an orchestrator + agent per verb (significant new surface across 146 existing agents).
- Skill SKILL.md is 169 lines — CKS rule caps SKILL.md at 300 lines, so the core skill fits, but its `scripts/` dir (live browser server, screenshot, puppeteer-driven `live` mode) pulls in Node tooling that doesn't match the CKS Markdown+Bash+JSON stack (CLAUDE.md Stack section).
- The deterministic linter is the cleanest slice: `Bash(npx impeccable *)` is already its declared `allowed-tools` entry; wrapping it in a CKS skill/agent is a bounded extension.
- Specialist note: evals/AI signals present (impeccable has a 12-rule LLM critique pass, `@anthropic-ai/sdk` dep). `cks:evals-runner` would normally fire in tech-fit; not dispatchable from subagent context — noted, scored inline per Rule 7. If the LLM critique pass is adopted, it should carry eval evidence per `.claude/rules/evals.md`.
- Not lower than 3: the slice we recommend (skill refs + CLI linter) is a clean, bounded extension; the 3 reflects that full adoption needs real adaptation work.

## Pillar 3 — Data Impact
Score: 4/5. Blast-radius evidence:
- Visual-slop linter (`npx impeccable detect src/`) is **read-only** — it scans HTML/CSS/URLs and emits findings (`cli/engine/`), writes nothing to CKS state. Zero blast radius on `.prd/`, `plugin.json`, or hooks.
- Reference absorption = a new isolated `skills/design-fluency/` directory (additive, new dir → top of the Data Impact rubric). No existing skill is rewritten.
- Touch points that pull it below 5:
  - Adding the verbs would edit `commands/README.md` count + `commands/help.md` (required by `.claude/rules/docs.md`) and `.claude-plugin/plugin.json` if commands are registered — these are the "touches plugin.json/hook scripts" tier.
  - Adopting the CLI as a runtime dependency introduces a Node/npm dependency (`puppeteer` optional, `css-tree`, `htmlparser2`) into a plugin whose stack is Markdown+Bash+JSON — supply-chain + install-footprint consideration.
- Security note: no auth/secrets/token surface in the linter path; the LLM critique pass would need an API key (`@anthropic-ai/sdk`) but that path is optional and out of the recommended slice. `cks:security-auditor` would normally fire on the API-key signal; not dispatchable here — noted, no secret-handling concern in the read-only slice.
- License: Apache-2.0 (`LICENSE`, `package.json` `"license": "Apache-2.0"`). Compatible with redistribution given NOTICE.md attribution (it itself attributes Anthropic's frontend-design skill).

## Recommendation
**Defer** (Overall 3.7 — top of the Defer band, just under the 4.0 Go threshold).

Plain-language reasoning: the value is real and the license is permissive, but the concept as stated ("integrate impeccable") is too broad to score Go. The clean, high-value, low-risk slice (design-fluency reference skill + read-only visual-slop linter at the review gate) is a strong Go on its own; the full 23-command import is a Defer because it fights the CKS thin-dispatcher architecture and adds a Node toolchain off-stack. Narrow the concept to the recommended slice and it crosses into Go.

## Next Step
Conditions to re-evaluate as a Go:
1. Confirm scope = "design-fluency skill + linter review-gate step" (drop full 23-command import).
2. Decide CLI strategy: runtime dependency (`npx impeccable detect`) vs. reference-only guidance with no new dependency.
3. Decide command exposure: skill-knowledge only (consumed by existing design agents) vs. a small set of new `/cks:*` design verbs behind thin dispatchers.

If the user confirms the narrowed slice (Go path), proposed plugin-mode implementation:
- Branch: `impeccable-integration-concept`
- Files to create:
  - `skills/design-fluency/SKILL.md` (+ `references/` adapted from impeccable's 7 domain refs, with NOTICE/attribution)
  - `agents/design-fluency-reviewer.md` (wraps `Bash(npx impeccable detect *)` as an optional review-gate verification, skills: design-fluency, anti-patterns, accessibility)
  - Optional: `commands/design-polish.md` (thin dispatcher → design-fluency-reviewer)
  - Update `commands/README.md`, `commands/help.md` counts/tables; add NOTICE attribution for Apache-2.0.
