# Workflow: Plan — CONTEXT.md → PRD + PLAN, with requirement and roadmap rows returned

Transform discovery output into planning documents. Produces:

1. `docs/prds/PRD-{NNN}-{name}.html`
2. `.prd/phases/{NN}-{name}/{NN}-PLAN.html`
3. Rows for `.prd/PRD-REQUIREMENTS.md` and `.prd/PRD-ROADMAP.md` / `docs/ROADMAP.md`,
   returned for the project-manager to record (`.prd/` state is its write scope)

## 1. Read everything first

- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` — primary input
- `{NN}-RESEARCH.md` or `.research/*/report.md` — research findings, if any
- `.prd/PRD-PROJECT.md`, `.prd/PRD-REQUIREMENTS.md` (REQ-ID numbering), `.prd/PRD-ROADMAP.md`,
  `CLAUDE.md`, `docs/prds/` (PRD numbering), `.context/*.md`
- `.learnings/gotchas.md` (warnings → risk notes), `.learnings/conventions.md` (follow
  "Applied"), `{NN}-REVIEW.md` when this is an iteration
- `.preflight/{NN}-*/PREFLIGHT.md` — use its locked phase order (L), BLOCK/WARN gotchas
  (F) as risk notes, done criteria (E) as DoD, instrumentation (I) as the first task; status
  "Cleared for takeoff: NO" → surface the blocker before planning
- `skills/ecosystem-watch/index.md` — HIGH/MEDIUM bulletins for the stack

**Definition of Ready** — do not plan a task without: testable acceptance criteria,
approved design (frontend), agreed API contract (full-stack), identified dependencies, an
estimate.

## 1b. Gaps that need another role

- Missing implementation detail, ambiguous architecture, or a critical path (auth,
  payments, migration) with no RESEARCH.md → return to the chief of staff with the
  researcher dispatch you need (`skills/deep-research/workflows/codebase-research.md`).
- Scheduling signals (`.claude/rules/scheduling.md`) → name the operator/scheduler dispatch;
  note the routine in Risk Notes once registered.
- Loop signals (`.claude/rules/loops.md`) → `LOOP-DESIGN.md` must exist first.
- Distributed pattern signals (`.claude/rules/arch-patterns.md`) → write the pattern ADR
  yourself (`skills/architecture/workflows/generate.md`, mode pattern-adr) before PLAN,
  surface `▶ ACTION REQUIRED` with the patterns and ADR path, reference it in Risk Notes.

## 2. Write the PRD

Template: `skills/prd/templates/prd.md`. Principles: specific over vague; every acceptance
criterion a yes/no a QA engineer can mark without judgment ("returns 200 with a session
token", not "works correctly"); independently shippable phases sized for 1–3 sprint
sessions — split larger ones; explicit out-of-scope; every step traces to a CONTEXT.md
acceptance criterion — anything without a trace is scope creep.

Next PRD number from `docs/prds/`. Output HTML: nav shell from
`skills/prd/references/html-shell.md` (PRD tab active, prefix `../../`), `--accent` from
`.kickstart/brand.md`; header (title, phase, date, status badge); story cards
(`US-{N}`, priority badge); criteria checklists per story; two-column scope table; API
surface as `<pre><code>`; nested test plan; success-metric stat cards; self-contained
`<style>`, dark mode, no CDN.

## 3. Write the plan

```markdown
# Execution Plan: Phase {NN} — {Name}
**PRD:** PRD-{NNN}  **Created:** {date}

## Goal
{one sentence}

## Tasks
### Task 1: {Title}
**Files:** {files}  **Description:** {specifically what}  **Acceptance:** {how verified}

## Acceptance Criteria
- [ ] {criterion}

## Dependencies
## Risk Notes
## Estimated Scope
{Small | Medium | Large — why}
```

Output HTML at `.prd/phases/{NN}-{name}/{NN}-PLAN.html`: Plan tab active, prefix
`../../../`; task table with effort badge (S green, M yellow, L orange, XL red) and type
badge (Feature/Fix/Infra); in/out scope; criteria panel; risk notes as `<pre>`.

Too large for one session → numbered waves `{NN}-01-PLAN.html`, `{NN}-02-PLAN.html`, each
independently executable and producing its own `{NN}-{SS}-SUMMARY.md`.

## 4. Requirement and roadmap rows (returned, not written)

- REQ rows: functional requirements from the PRD, sequential REQ-IDs continuing
  `.prd/PRD-REQUIREMENTS.md`, linked to PRD-{NNN}, status Accepted.
- Roadmap rows for `.prd/PRD-ROADMAP.md` and `docs/ROADMAP.md` in the format of
  `skills/prd/references/roadmap-format.md`: feature under "Active Work" or "Up Next",
  phase status, PRD path.

## 5. Present for review

Summary (title, problem, phases, key criteria, scope per phase), then `AskUserQuestion`
for adjustments — never a plain-text question.

## Constraints

- Templates, not improvised structure. One feature per PRD — recommend splitting otherwise.
- Never implement. Never skip the roadmap rows — a PRD nobody tracks is lost.
