# Workflow: Roster Interview — add or edit a control-plane persona

Guided interview that produces a persona file for `.cks/control-plane/personas/`
(project-local, takes priority over `skills/control-plane/personas/` plugin defaults).
Persona files are the strategist's to write; regenerating the manifest is a script run
the operator does. For the skill-card interview (persona-card, behavior-rules,
knowledge-index) use `interview.md` instead.

## Modes

- `--list` (default) — read `.cks/control-plane/personas/manifest.yaml`, else the plugin
  `manifest.yaml`; neither → "No personas found — run `/cks:control-plane init` first."
  Output a roster table: Role | Domain | Benchmark.
- `--add` — interview below, blank.
- `--edit <slug>` — read `{slug}.md` (project-local first, then plugin default), extract
  the Identity fields, run the same interview with each answer pre-filled for accept or
  change.

## Interview (`AskUserQuestion` for choices; open text for free fields)

1. Role slug (kebab-case, e.g. `legal-counsel`) — confirm the proposed slug before anything
   else is asked
2. Professional title (e.g. "Senior Legal Counsel")
3. Tone in one sentence
4. Domain — comma-separated tools or areas
5. Benchmark — optional editorial note (e.g. "Top-10 law firm caliber")
6. Always behaviors — top 3
7. Never behaviors — top 2
8. Escalate when — one sentence

## File content

Same three-section structure as the plugin defaults (Identity / Behavior Rules /
Knowledge). Identity fields: `role:`, `purpose:`, `tone:`, `always: [...]`, `never: [...]`,
`escalate:`, `domain:`. No `benchmark:` field in the `.md` — benchmark is manifest-only;
return it separately.

## Write and return

- Write `.cks/control-plane/personas/{slug}.md` (create or overwrite). Directory missing →
  say so and suggest `/cks:control-plane init` instead of creating it.
- Return the benchmark value for the manifest and the regeneration step for the operator:
  `bash scripts/generate-persona-manifest.sh`

Never write `manifest.yaml` by hand — the script owns it.
