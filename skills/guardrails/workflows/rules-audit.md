# Workflow: Rules Audit — adherence scan against `.claude/rules/`

Scan the codebase against `.claude/rules/*.md` and report per-rule compliance with grades.
Read-only: the role running this reports; it never fixes.

## Inputs

- `mode`: `quick` (changed files only, default) or `full` (entire codebase)
- `caller`: `manual` | `sprint-close` | `sprint-3d` | `release-5c`

## 1. Load rules

```bash
ls .claude/rules/*.md 2>/dev/null
```

None found → report "No guardrails found in `.claude/rules/`. Run `/cks:bootstrap` to
generate rules from your stack." and stop.

For each rule file: read it, extract the `globs:` frontmatter for file scope, and treat each
bullet point as a checkable rule.

## 2. Determine scope

- Quick: `git diff --name-only HEAD~1`, filtered against each rule's globs.
- Full: glob all files matching each rule's globs.

## 3. Scan for violations

**Security rules** — grep for hardcoded secrets (`sk_live_`, `AKIA`, `ghp_`, password
strings), string interpolation in SQL context, route files without an auth import, debug
output of errors or stack traces in responses.

**Testing rules** — skipped tests (`test.skip`, `xit`, `@pytest.mark.skip`) without a reason,
shared mutable state across tests (global `let` mutated), source files without a test file.

**Database rules** — raw SQL without parameterization, schema changes without a migration,
`SELECT` without `LIMIT` on unbounded tables.

**Docs rules** — `CLAUDE.md` over 150 lines, stale TODO comments without an issue reference.

**Language rules** — `any` (TypeScript), bare `except:` (Python), unchecked errors (Go),
`unwrap()` outside tests (Rust).

## 4. Score and report

Per rule file: A = 0 violations, B = 1–2, C = 3–5, D = 6–10, F = 11+.

```
Adherence Report — {date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mode: {quick | full}
Files scanned: {count}

  Rule File              Violations  Grade
  ─────────────────────────────────────
  {name}.md              {N}         {A-F}

  Overall: {weighted grade}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Per violation:
```
{rule_file}:{rule} — {file:line}
  Found: {violating pattern}
  Fix: {one-line remediation}
```

Group by rule file, ordered security → database → testing → docs → language.

## Rules

1. High confidence only — skip when unsure; no false positives.
2. One grade per rule file.
3. Quick mode touches only changed files.
4. Every violation has a one-line fix. Fixing is a separate dispatch (builder), never this run.
