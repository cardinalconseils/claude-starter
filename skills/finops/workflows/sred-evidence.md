# SR&ED Evidence

Build the technical-narrative skeleton the accountant needs for a Scientific Research and
Experimental Development claim, from what the repo already recorded: commits, `.prd/`
phase artifacts, verification results, retros. Output:
`.finops/sred/<fiscal-year>/<project>.md`. This is evidence collection, not tax advice —
eligibility, rates, and the claim itself are for a qualified preparer.

## What qualifies (the test the narrative must pass)

Work is SR&ED when it was a **systematic investigation** to resolve a **technological
uncertainty** that could not be removed by standard practice, and it produced a
**technological advancement** (or a documented failure to achieve one). Routine
development, styling, data entry, and integrating documented APIs the documented way do
not qualify. The narrative has four parts and every part cites evidence.

## 1. Scan the record

```bash
git log --since="<fiscal-year-start>" --until="<fiscal-year-end>" --date=short --format='%h %ad %an %s'
git log --since="<start>" --until="<end>" --grep='spike\|experiment\|prototype\|attempt\|fails\|regress\|benchmark\|eval\|latency\|accuracy\|hallucinat' --format='%h %ad %s'
ls .prd/phases/*/ .evals/ .harness-evals/ .learnings/ .autoresearch/ 2>/dev/null
```

Where the GitHub grant is present, `mcp__plugin_github_github__list_commits` gives the
same history for a repo not checked out locally.

Read, per phase directory: `CONTEXT.md` (the problem and acceptance criteria — the
uncertainty usually hides in the ones that were hard to state), `PLAN.md` (the hypothesis
and the approach), `SUMMARY.md` (what was actually built vs intended), `VERIFICATION.md`
and `CONFIDENCE.md` (experiments and their results, FAIL verdicts with root causes), and
`.learnings/*.md` retros (what did not work and why). Eval runs (`.evals/`, `.autoresearch/`
`results.tsv`) are the strongest experiment evidence: dated, measured, repeated.

## 2. Group into projects

An SR&ED project is one uncertainty, not one repo. Cluster commits and phases by the
question they were answering ("can retrieval over X reach Y accuracy at Z latency"). Skip
clusters that are routine work; list them under "Excluded" with a one-line reason so the
preparer sees the judgment.

## 3. Skeleton per project

```
# SR&ED — <project> — FY<year>

Fiscal year:   <start> → <end>
Repo(s):       <paths / URLs>
People:        <name> — role — hours estimate (source: session logs or owner)

## Technological uncertainty
What could not be known or achieved with standard practice, in one paragraph.
Evidence: CONTEXT.md §<n> (<path>), commit <hash> "<subject>", retro <path>

## Hypothesis
What was believed would resolve it, and why.
Evidence: PLAN.md (<path>), ADR <path>

## Experiments (systematic investigation)
| Date | What was tried | Measured result | Evidence |
|---|---|---|---|
| <date> | <approach> | <metric, pass/fail> | commit <hash>, VERIFICATION.md <path>, results.tsv row <n> |
Include the failures — a failed iteration is the proof the outcome was uncertain.

## Advancement (or documented failure)
What is now known that was not before; how it generalises beyond this product.
Evidence: SUMMARY.md <path>, final eval <path>

## Time allocation
Commits in scope: <n> of <total>; sessions with SR&ED dispatches: <n>; hours estimate <n> (method stated)

## Excluded (routine)
- <cluster> — <reason>
```

## 4. Hand-off

Return the file paths and three things the preparer will ask for that the repo could
not supply (contractor invoices, payroll split, the claim year's T661 lines). Never
invent hours: estimate from session logs and say so, or leave the cell for the owner.
