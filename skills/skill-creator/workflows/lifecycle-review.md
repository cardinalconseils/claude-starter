# Workflow: Skill Lifecycle Review — quarantine candidates, three checks, human verdict

Review every `CANDIDATE.md` in quarantine, run three checks on each, and return a verdict
recommendation. Promotion to `skills/validated/` and archiving to `skills/archived/` are
gated writes: the reviewing role returns findings; the chief of staff asks the human and
has the operator move files. No auto-promotion path exists.

## 1. Scan quarantine

Glob `skills/quarantine/**/CANDIDATE.md`. Nothing found → report "Nothing to review —
quarantine is empty." and stop.

## 2. Three checks per candidate

Process candidates one at a time.

**a) Format** — valid YAML frontmatter with non-empty `name` and `description`.
Fail: missing frontmatter, missing field, or empty value.

**b) Conflict** — glob `skills/validated/{name}/SKILL.md`.
Pass: nothing there. Fail: name collision.

**c) Scope** — the `description` maps to a known CKS skill domain:
database-design, migrations, rls, authentication, api-design, monitoring, performance,
security-hardening, payments, cicd-starter, environment-management, no-code,
context-research, retrospective, caveman, prd, kickstart, deep-research, evals,
ecosystem-watch, skill-creator, brainstorming, verification, anti-patterns, core-behaviors.
Fail: outside known domains, or too vague to classify.

## 3. Verdict question (the human decides)

For each candidate the chief of staff asks:

> "{name}" — checks: [format ✓/✗] [conflict ✓/✗] [scope ✓/✗]. Verdict?
> Approve — promote to validated/ · Reject — move to archived/ · Skip — leave in quarantine

On a conflict-check failure the follow-up is: Replace (archive the existing skill to
`skills/archived/{name}-replaced/CANDIDATE.md`, then promote) · Rename (leave in
quarantine) · Reject.

## 4. What each verdict does (operator executes)

- **Approve** — copy to `skills/validated/{name}/SKILL.md` (renaming to `SKILL.md` is the
  activation act), delete the quarantine copy only after the write succeeded, append
  `| {today} | {name} | approve | {reason} | {reviewer} |` to `memory/gatekeeper/review_log.md`.
- **Reject** — copy to `skills/archived/{name}/CANDIDATE.md` (never live), delete the
  quarantine copy after the write succeeded, append the same log row with `reject`.
- **Skip** or a closed prompt — candidate untouched, nothing logged.
- Write failure — leave the candidate in quarantine, log `error`, report it.

## 5. Report

One line per candidate:
- `{name}: recommend approve — checks {✓✓✓}`
- `{name}: recommend reject — {failing check and why}`
- `{name}: needs human call — {which check is ambiguous}`

Final line: `N reviewed — A approve, R reject, S undecided`.
