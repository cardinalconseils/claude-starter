# Workflow: Generate — ARCHITECTURE.md and ADRs

Maintain two artifacts: `ARCHITECTURE.md` (project-level living doc) and
`.decisions/ADR-NNN.md` (one file per significant decision). Keep them accurate.

## Inputs (read in order)

1. `ARCHITECTURE.md` if it exists
2. all `.decisions/ADR-*.md`
3. all `.prd/phases/*/*-TDD.md` — extract architecture decisions
4. the active phase's CONTEXT.md — architecture tier is in element [1l]

## Mode 1 — full refresh (`/cks:architecture`)

Rebuild `ARCHITECTURE.md` from `templates/architecture.md`: Mermaid topology for the
current tier (`SKILL.md` conventions), Components table from every TDD, key data flows
(max 3, most user-facing), Decision Index from all ADRs. Report sections written, ADR
count, diagram tier.

## Mode 2 — sprint update (step [3b], after the TDD)

**A. ARCHITECTURE.md** — missing → create from the template with what CONTEXT.md + the
TDD give; exists → one-liner under "Recent Changes": `- Phase {NN}: {change}`.

**B. ADR** — a decision is significant when it introduces a technology, library, or
external service; chooses between valid approaches; sets a pattern future phases will
follow; or reverses an earlier decision. If found: next number from `.decisions/`, copy
`templates/adr.md`, fill every field from the TDD, write `.decisions/ADR-NNN.md`, add a
Decision Index row. Otherwise skip — no trivial ADRs.

## Mode 3 — pattern ADR (`.claude/rules/arch-patterns.md`)

Called with `mode: pattern-adr` and a `patterns:` list.

Project-type gap checks first (read `project_type` from `.kickstart/state.md`,
`.bootstrap/scan-context.md`, or the brief):
- `ai-agent-system` → confirm Stage 4 (state/transition tables from
  `skills/orchestration/workflows/state-machine.md`) and Stage 5 (a filled
  `skills/agent-build-sequence/references/tool-inventory-template.md`) exist. Missing →
  add `## Gap Found` to the ADR naming the artifact and surface `❓ DECISION REQUIRED`
  before finalizing.
- `multi-role-saas` → an ADR describing a second app root needs an existing
  `.decisions/ADR-*-multi-app-justification.md`; otherwise flag with
  `.claude/rules/saas-single-app.md` Check 1 instead of writing it blind.

Per pattern: read its entry in `references/distributed-patterns.md`; closely related
patterns → one combined ADR, else one each; 3+ patterns → one combined ADR "Distributed
Resilience Patterns for {Feature}". Fill Context (why this feature needs it — CONTEXT.md
signals), Decision (adopt `{Pattern}` + implementation cross-reference), Alternatives (the
production failure mode without it), Consequences (what must ship before the sprint).
Write `.decisions/ADR-NNN.md`, add the Decision Index row. Report paths and patterns.

## Output (caveman)

```
ARCHITECTURE.md updated
  Tier: [1/2/3]   Components: [N]   Flows: [N]   ADRs: [N total] ([+N new])
ADR-NNN written: [title] — .decisions/ADR-NNN.md
```

## Rules

- No ADR for a decision with no real alternative.
- Never overwrite an ADR — append new ones, or update `Status:` only.
- Validate Mermaid syntax before writing (closed brackets, valid arrows, ≤ 15 nodes).
- Tier not recorded → assume Tier 1 and say so.
