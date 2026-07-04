# SaaS Single-App Enforcement Rules

## Mandatory Behavior

When `project_type: multi-role-saas` is set for a project, two structural facts are checked
deterministically — neither requires judgment about intent, only pattern matching against a
diff, PLAN.md, ADR, or code:

1. **Single-app check:** does a diff, PLAN.md, or ADR scaffold a second full app/dashboard
   root (a new top-level app directory with its own routing root — e.g. a second
   `package.json`/app entry point alongside the existing one)?
2. **Shared-matrix-citation check:** do RLS policy comments, API middleware checks, and
   frontend visibility guards all cite the same `PERMISSIONS-MATRIX.md` path?

This rule is kept separate from `.claude/rules/saas-build-sequence.md` — that rule offers the
12-stage methodology (judgment-adjacent: the user decides whether to run it). This rule
enforces two checkable facts once `multi-role-saas` is confirmed (fact-checking, not offering).

## Check 1 — Second App Root

**Trigger:** `project_type: multi-role-saas` is set, AND a diff, PLAN.md, or ADR under review
scaffolds a second top-level app directory with its own routing root (second `package.json`,
second app entry point, second deployment target that duplicates the existing app's role
instead of extending it).

**Required behavior:** Flag the finding as a violation requiring explicit justification,
UNLESS a `.decisions/ADR-*-multi-app-justification.md` already exists covering this specific
second app root.

Surface exactly this block (per `.claude/rules/human-intervention.md` format):

```
─────────────────────────────────────────────────
❓ DECISION REQUIRED
─────────────────────────────────────────────────
This project is tagged multi-role-saas. The diff/plan scaffolds a second app root
({path}), which contradicts the single-app-with-role-gating mandate.

  1. Proceed — write a one-paragraph ADR justification (.decisions/ADR-*-multi-app-justification.md)
  2. Redesign as a role-gated view inside the existing app (Recommended)
  3. Dismiss with reason — records dismissal in .prd/phases/{NN}/DISMISSED-PATTERNS.md, never re-prompted for this finding

Reply with the number or describe what you want.
─────────────────────────────────────────────────
```

This mirrors `.claude/rules/arch-patterns.md`'s Review Gate shape exactly. This is a
non-blocking flag — the user's choice governs. It is NOT a hard block and NOT a silent
suggestion: the finding must always surface once matched, and merge is never blocked on it.

## Check 2 — Shared Matrix Citation

**Trigger:** `project_type: multi-role-saas` is set, AND RLS policies, API middleware checks,
or frontend visibility guards exist in the changed files.

**Required behavior:** grep the changed files for a `PERMISSIONS-MATRIX.md` (or project's
chosen matrix filename) citation in RLS policy comments, API middleware checks, and frontend
visibility guards. If any of the three layers is missing the citation while the other two have
it, flag the gap.

Non-blocking — surfaces as a finding, same three-option shape as Check 1, substituting
"add the missing citation" for "write an ADR."

## Required Behavior by Lifecycle Gate

### Sprint Gate [3c]-equivalent — Non-blocking catch

After SUMMARY.md is written but before declaring build complete, for a `multi-role-saas`
project:

1. Run Check 1 against the sprint's changed files (new top-level app directories created)
2. Run Check 2 against the sprint's changed files (RLS/API/frontend citation grep)
3. If either check finds a violation, surface the `❓ DECISION REQUIRED` block above
4. Non-blocking — log the finding and continue if the architecture-generator or the check
   itself is unavailable

### Review Gate [4a] — Diff scan, non-blocking

After SUMMARY.md exists and before PR review, for a `multi-role-saas` project:

1. Run `git diff main...HEAD` on changed files
2. Run Check 1 (second app root signal: new `package.json`, new app entry point, new routing
   root) and Check 2 (matrix citation grep across RLS/API/frontend) against the diff
3. If a violation is found and not already covered by an existing ADR or a prior dismissal,
   surface the `❓ DECISION REQUIRED` block above
4. MUST NOT block merge — the user's choice governs
5. Record all dismissals in `.prd/phases/{NN}/DISMISSED-PATTERNS.md` — never re-prompt for the
   same finding

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The second app root might be temporary" | Flag it anyway. The ADR justification path exists precisely for legitimate temporary or exceptional cases — silence is not the same as justification. |
| "RLS already restricts data, the citation is just decoration" | The citation is what lets a future reader confirm all three layers reason about the same source of truth. Missing it is a gap, not decoration. |
| "This should be a hard block, not just a flag" | Confirmed strictness level is flag + require ADR, non-blocking. A hard block was explicitly rejected — don't write this rule stricter than confirmed. |
| "This should just be a suggestion, not a structured gate" | Both checks are enumerable structural facts (a directory exists or doesn't; a string is grep-matched or isn't). That makes them Layer 4 enforcement, not a Layer 6 suggestion. |
| "I'll skip Check 2 since Check 1 already passed" | They test different things — one app root doesn't guarantee the three layers cite the same matrix. Run both. |
