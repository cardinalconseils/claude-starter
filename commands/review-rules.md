---
description: "Adherence audit — checks codebase against .claude/rules/ and reports per-rule compliance"
argument-hint: "[--quick | --full]"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

# /cks:review-rules — Guardrail Adherence Audit

Reads all `.claude/rules/*.md` files, scans the codebase for violations, and produces a per-rule compliance report.

## When Invoked

- Manually: `/cks:review-rules` (anytime)
- By `/cks:sprint-close` (end of session — quick mode)
- By `/cks:sprint [3d]` code review (quick mode on changed files)
- By `/cks:release [5c]` quality gate (full mode)

## Arguments

- No args or `--quick`: Scan only files changed since last commit (`git diff --name-only HEAD~1`)
- `--full`: Scan entire codebase

## Steps

### 1. Load Rules

```bash
ls .claude/rules/*.md 2>/dev/null
```

If no rules found:
```
No guardrails found in .claude/rules/
Run /cks:bootstrap to generate rules from your stack.
```
And stop.

For each rule file:
- Read the file
- Extract the `globs:` frontmatter to know which files this rule governs
- Parse each bullet point as a checkable rule

### 2. Determine Scope

**Quick mode** (default):
```bash
git diff --name-only HEAD~1
```
Filter the changed files against each rule's globs to build a per-rule file list.

**Full mode** (`--full`):
Use Glob to find all files matching each rule's globs.

### 3. Scan for Violations

For each rule file, check its bullet points against the scoped files:

**Security rules** — check with Grep:
- Hardcoded secrets: patterns like `sk_live_`, `AKIA`, `ghp_`, password strings
- String interpolation in queries: template literals or f-strings in SQL context
- Missing auth middleware: API route files without auth import/check
- Exposed debug info: `console.log` of errors, stack traces in responses

**Testing rules** — check with Grep + Bash:
- Skipped tests: `test.skip`, `xit`, `@pytest.mark.skip` without explanation
- Shared mutable state: global `let` in test files modified across tests
- Missing test files: source files in scope without a corresponding test file

**Database rules** — check with Grep:
- Raw SQL without parameterization: string concatenation in query context
- Missing migrations: schema changes without migration files
- Unbounded queries: SELECT without LIMIT

**Docs rules** — check with Grep + Read:
- Broken links: relative links in markdown to files that don't exist
- CLAUDE.md line count: warn if over 150 lines
- Stale TODO comments: TODO/FIXME without issue references

**Language rules** — check with Grep:
- `any` type usage (TypeScript)
- Bare `except:` (Python)
- Unchecked errors (Go)
- `unwrap()` in non-test code (Rust)

### 4. Score and Report

For each rule file, count violations and compute a grade:

```
Adherence Report — {date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mode: {quick | full}
Files scanned: {count}

  Rule File              Violations  Grade
  ─────────────────────────────────────────
  security.md            {N}         {A-F}
  testing.md             {N}         {A-F}
  database.md            {N}         {A-F}
  docs.md                {N}         {A-F}
  typescript.md          {N}         {A-F}

  Overall: {weighted grade}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Grading per rule file:**
- **A**: 0 violations
- **B**: 1-2 violations (minor)
- **C**: 3-5 violations
- **D**: 6-10 violations
- **F**: 11+ violations

### 5. Detail Violations

For each violation found, report:
```
{rule_file}:{rule_bullet} — {file:line}
  Found: {the violating pattern}
  Fix: {one-line remediation}
```

Group by rule file, ordered by severity (security first, then database, testing, docs, language).

### 6. Ask for Action (interactive mode only)

If invoked directly (not by sprint-close or sprint [3d]):

```
AskUserQuestion({
  questions: [{
    question: "What would you like to do with these findings?",
    options: [
      { label: "Fix all", description: "Auto-fix violations where possible" },
      { label: "Fix critical only", description: "Fix security + database violations" },
      { label: "Save report", description: "Write to .prd/adherence-report.md" },
      { label: "Dismiss", description: "Acknowledge and continue" }
    ]
  }]
})
```

If "Save report": write the full report to `.prd/adherence-report.md`.

## Rules

1. **Read-only by default** — only modify files if user selects "Fix" option
2. **No false positives** — only report violations with high confidence; when in doubt, skip
3. **Per-rule granularity** — never merge findings across rule files; each rule file gets its own grade
4. **Fast in quick mode** — only scan changed files, no full-codebase grep
5. **Actionable** — every violation must have a one-line fix suggestion
