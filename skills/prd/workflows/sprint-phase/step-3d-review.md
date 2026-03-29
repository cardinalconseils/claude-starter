# Sub-step [3d]: Code Review

<context>
Phase: Sprint (Phase 3)
Requires: De-sloppify complete ([3c+])
Produces: Code review report, blocking/warning classifications
</context>

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3d.started" "{NN}-{name}" "Sprint: code review started"`

## Guardrail Adherence Check (pre-review)

Before code review, run the guardrails audit on changed files:

```
Skill(skill="cks:review-rules", args="--quick")
```

This checks changed files against `.claude/rules/*.md` (security, testing, database, docs, language).

- If grade is **D or F** on any rule file: fix violations before proceeding to code review. Re-run [3c] for fixes, then re-run the adherence check.
- If grade is **A-C**: note findings in the review but proceed. Warnings are included in the code review report.

If no `.claude/rules/` exists, skip this check and proceed to code review.

## Decision: Single reviewer vs. Parallel review agents

Read SUMMARY.md to count files changed:
- **≤ 15 files** → single code review tool
- **> 15 files or multi-layer (frontend + backend + DB)** → dispatch 3 parallel review agents

## Single Review (default)

Invoke code review tools in order of preference:

```
1. Skill(skill="pr-review-toolkit:review-pr")
2. Skill(skill="code-review:code-review")
3. Skill(skill="coderabbit:review")
```

Use whichever is available. If NONE are available, fall back to self-review:
```
No external code review tool available. Performing self-review:
- Read all changed files (from git diff)
- Check for: security issues, error handling gaps, naming inconsistencies, dead code
- Report findings in the same format as external tools
Note: Self-review is less thorough. Consider installing a review tool for production use.
```

## Parallel Review (> 15 files or multi-layer)

Dispatch 3 review agents in a SINGLE message (parallel):

```
Agent(model="sonnet", prompt="
  You are a correctness reviewer. Check files from {NN}-SUMMARY.md for logic errors,
  bugs, missing edge cases, and adherence to acceptance criteria.
  Read: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md for file list
  Read: .prd/phases/{NN}-{name}/{NN}-PLAN.md for acceptance criteria
  Report: [BLOCKING] or [WARNING] with file:line references.
")

Agent(model="sonnet", prompt="
  You are a security reviewer. Check API routes, auth, and data handling files from
  {NN}-SUMMARY.md for OWASP Top 10, injection risks, auth bypass, secrets exposure.
  Read: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md for file list
  Report: [BLOCKING] or [WARNING] with file:line references.
")

Agent(model="sonnet", prompt="
  You are a conventions reviewer. Check files from {NN}-SUMMARY.md for adherence to
  CLAUDE.md conventions and design spec match.
  Read: CLAUDE.md, .prd/phases/{NN}-{name}/{NN}-DESIGN.md
  Read: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md for file list
  Report: [BLOCKING] or [WARNING] with file:line references.
")
```

After all 3 complete: deduplicate findings, classify blocking vs. warnings, present to user.

## Handle Review Results

If blocking issues found:
```
AskUserQuestion({
  questions: [{
    question: "Code review found {N} blocking issues. How to proceed?",
    header: "Code Review Results",
    multiSelect: false,
    options: [
      { label: "Fix issues", description: "Address blocking issues before QA" },
      { label: "Defer non-critical", description: "Fix blockers only, defer warnings" },
      { label: "Override", description: "Proceed to QA despite review findings" }
    ]
  }]
})
```

If "Fix issues" → re-run [3c] implementation for fixes, then re-run [3d].

```
  [3d] Code Review            ✅ {status} {team ? "— team review (correctness + security + conventions)" : "(" + tool_used + ")"}
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3d.completed" "{NN}-{name}" "Sprint: code review complete"`
