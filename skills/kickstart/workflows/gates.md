# Workflow: Kickstart Gates — project type, maturity, and the optional-phase questions

Run around Phase 1 (Intake) and Phase 1b (Compose). The questions are mandatory even
when the answer seems obvious — the user's explicit response drives skip/proceed, never
inference (see `SKILL.md` "MANDATORY GATES"). Every gate is an `AskUserQuestion` call.

## Before intake — classify the project type

"What type of project is this?" (header "Project Type"):
- AI agent system — autonomous agents, tool-calling loops, multi-agent orchestration
- Multi-role SaaS — admin/user/vendor roles, permissions, tenant-aware dashboards
- Plugin / tool / API — developer tool, CLI, library, API service
- Website / marketing — marketing site, landing page, content site
- Other / generic

Write `project_type: {value}` into `.kickstart/state.md` frontmatter. Non-blocking.

Then run `workflows/intake.md`, one question at a time, recommended answer first,
pre-filled from the pitch or `.kickstart/ideation.md` wherever possible, with glossary
definitions from `references/ai-glossary.md` when natural.

## Before compose — build-sequence offers

- `project_type: ai-agent-system` or an agent-system keyword during intake → the 15-stage
  offer per `.claude/rules/agent-build-sequence.md` (Kickstart Gate — Phase 1b).
- `project_type: multi-role-saas` or a multi-role keyword → the 12-stage offer per
  `.claude/rules/saas-build-sequence.md`.

Both non-blocking; then run `workflows/compose.md` and `workflows/stack-selection.md`.

## After compose — optional phase gates (ask in this order)

1. **Maturity** (first — it shapes the rest): Prototype · Pilot · Candidate · Production,
   with the one-line meaning of each from `CLAUDE.md`.
2. **Research**: deep (multi-hop, multi-source) · standard · skip.
3. **Monetize**: full analysis · skip for now.
4. **Feature scope**: "Yes — grill me on features and lock the MVP (Recommended)" · skip
   (feature discovery then happens per `/cks:new`).
5. **Brand**: set up brand identity · skip.
6. **Codex review**: add Codex to sprint [3d] (needs `OPENAI_API_KEY`) · skip. On yes,
   the operator creates `.cks/codex-enabled`; surface the `▶ ACTION REQUIRED` block
   (`Run: export OPENAI_API_KEY=your-key-here` · `Why:` Codex CLI needs it · `Then:` add
   it to the shell profile).

## State file — write before reporting

```yaml
---
started: {ISO date}
last_phase: 1b
last_phase_name: Compose
last_phase_status: done
compose_sub_projects: {count}
project_type: {ai-agent-system|multi-role-saas|plugin/tool/api|website/marketing|other/generic}
maturity_stage: {Prototype|Pilot|Candidate|Production}
research_opted: {true|false}
monetize_opted: {true|false}
feature_scope_opted: {true|false}
brand_opted: {true|false}
codex_opted: {true|false}
---
```

Plus the progress table (Phases 1 and 1b done, others pending/skipped). Validate that
`.kickstart/context.md` has every required section (`references/validation-and-state.md`)
before marking intake done.
