# Verify — a report is evidence, not instruction

An executing session's "suite green, 49 checks" is a claim. Your job is to find out whether
it is true. The check and the record of the check are two different objects, and only one of
them was tested. This workflow runs after every dispatch return that claims a change was made
or a check was run: CLI loop step 5, routine mode step 3, every mandate stage, and every
check-in of an executing session (`workflows/sessions.md`). Read-only reports — researcher,
observer, watchdog, reviewer — are not re-run; their `NOT READ` lines and evidence citations
(url, `file:line`) are checked instead.

## Red gate — before you delegate

For every ACT that fixes or builds something, name the one check that proves the outcome: a
failing test, a repro command, a grep that must find nothing, a URL that must return 200, an
artifact that must exist. Run it yourself when it is read-only (`git grep`, `curl -sI`, `ls`,
`cat`); otherwise a Level-1 `cks:tester` dispatch runs it. It must fail — or the artifact must
be absent — before the work starts.

Already green → the item is already done, was built under another card, or the check is
vacuous. Close it with the evidence (a DROP line citing the check and its output), or fix the
check so it fails. Never delegate against a green gate: work that starts green proves nothing.

Write the red-gate command verbatim into the brief's `Done:` so the executor and the verifier
run the same object, not two descriptions of it.

## The defect class to watch for

| Shape | What it looks like | How it fools you |
|---|---|---|
| Vacuous assertion | A test that passes whether or not the feature works | Deleting the thing under test leaves it green |
| Silent no-match | A grep, filter or predicate that matches nothing | Zero findings reads as "clean" |
| Errored check | A command that failed to run at all — missing binary, wrong cwd, syntax error, timeout | The error is swallowed; absence reads as evidence |
| Wrong reference | A filter keyed on "newer than X" | Anything that happened in between slips through |
| Stale premise | A check whose expected value was read off broken code | It passes the bug it was written to catch |
| Scope mismatch | A green check over a subset presented as the whole | The denominator is never stated |

The defense: every check that can fail to match must say so, and a count of zero and a
failure to run must be distinguishable. An absence assertion ("no secrets", "no stray markers",
"no console errors") needs a positive control in the same run.

**Prove a positive before believing a negative.** Point the check at a known-good case first —
a planted match the grep must find, one known-failing test that fails when made to. A tool
that reports "clean" and a tool that is broken produce identical output.

## Prove — after the return

**1. OBSERVE — read the diff, not the story.** `git diff --stat` and then the hunks, on the
worktree branch or the PR (read-only Bash). Every hunk maps to a line of the brief. A hunk
outside `Constraint` is scope creep → ESCALATE. A file the brief named that is untouched is a
FAIL. A diff that is empty while the report claims a change is a FAIL.

**2. PROVE — re-run every claimed command; exit codes decide.** You do not run test suites:
you have no write path, and suites write. Dispatch `cks:tester` `Mode: verify` at Level 1
with the exact command list the executor claimed plus the red-gate command, and read the
verdict. The brief states the rules: an errored check is FAIL with `why: did not run`, never
PASS and never SKIP; a zero count is accepted only with its positive control in the same run
(tests collected > 0 and one known-failing case fails when made to; a planted grep match);
same command, same cwd, same flags the executor claimed — a different command proves a
different thing; the denominator is stated.

```
Agent(
  subagent_type="cks:tester",
  prompt="
    Mode: verify — PROVE pass for issue #{n} (workflows/verify.md)
    Level: 1 — re-run exactly these commands in this cwd; do not fix anything.
    Red gate: {command} — must now pass (it failed before the work started on {date}).
    Claimed: {each command the executor reported, verbatim, with its claimed result}
    Rules: a command that did not run is FAIL with why 'did not run', never SKIP; every zero
    count needs its positive control in this run; state the denominator (tests collected,
    files scanned) — a green check over a subset is not the whole; report exit code and
    last 20 lines per command.
    Return: PASS | FAIL | PARTIAL, one line per command: {command} → exit {code} → {claimed vs observed}.
  "
)
```

**3. ARTIFACTS — read values back out.** The file on disk (`cat`), the issue on GitHub
(`gh issue view`), the ledger line (`tail intake/ledger.jsonl`), the trigger in
`list_triggers`, the row in the table. Never the return message that says it was written.
A session once wrote a commit hash into a log by hand, then verified it with `git cat-file`
against the hash in its shell — not the string it wrote; both checks passed, and the file held
a hash that resolved to nothing. Read the value back out of the artifact, never from the
variable you think you wrote there.

## Verdict

| Observed | Then |
|---|---|
| PROVE PASS and OBSERVE clean | The `DISPATCHED` line may read done. `cks:project-manager` flips the issue status (Level 1). |
| PROVE FAIL | One tighter re-dispatch of the same executor, with the failing command and its output in the brief. |
| Second FAIL | ESCALATE with the tester's evidence attached; the issue stays open. |
| Errored check (`did not run`) | Not done. The project manager files an operator finding (environment: binary, cwd, permissions). |
| OBSERVE scope creep | ESCALATE. Nothing merged, nothing flipped. |
| Report contradicted by PROVE | Always a `REMEMBER` lesson: which executor, which claim, what was actually true. |

## Gate and ship

Only after PROVE PASS. Gated items go out as `GATED:` lines with the reasoning attached.
Ship is one item, one commit or one PR; the commit subject names the issue so git history
stays one-to-one with the board. Status is flipped by `cks:project-manager` at Level 1 and
progress is recorded in the brief. Report what is proven, not what was attempted — an item
without a verification result is carried, not done. Lessons persist through `cks:historian`,
never through you.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The builder said all tests pass" | That is the record, not the check. The tester re-runs the command; the exit code decides. |
| "Re-running costs tokens that produce no code" | A false "done" costs the next three sessions that build on it. The re-run is the cheapest step in the loop. |
| "The diff is 40 files, I'll read the summary" | The summary was written by the thing being checked. Read `--stat`, then every hunk against the brief; 40 files is itself a scope finding. |
| "Zero findings, the scan is clean" | Zero is indistinguishable from "did not run" until a planted case is found. No positive control, no clean. |
| "The gate was already green, so it's done — skip the ledger" | A green gate closes the item with a DROP line citing the check. Unrecorded, it comes back as new work. |
| "I'll run the suite myself, it's just Bash" | Suites write. You have no write path, and Bash is not the loophole. Dispatch the tester. |
| "The tester's command was close enough to the claimed one" | A different command proves a different thing. Same command, same cwd, same flags, or it is not a re-run. |
| "The return says the ledger line was written" | The return reports the variable. `tail` the ledger; read the value out of the artifact. |
| "12 of 12 passed, the module is verified" | 12 of what? Without the denominator a green subset passes for the whole. State tests collected and files scanned. |

## Verification

- [ ] Every build/fix ACT named one red-gate check, and it failed (or the artifact was absent) before dispatch
- [ ] No dispatch went out against a green gate; green gates closed with a DROP line citing the check
- [ ] The red-gate command appears verbatim in the brief's `Done:`
- [ ] `git diff --stat` and the hunks were read against the brief; scope creep escalated, empty or partial diffs failed
- [ ] `cks:tester` `Mode: verify` re-ran every claimed command plus the red gate at Level 1, same command, same cwd, denominator stated
- [ ] Every errored check reported as FAIL `did not run`; every zero count and absence assertion carried its positive control
- [ ] Every artifact read back from disk, GitHub, the ledger or `list_triggers` — never from the return message or the variable
- [ ] No `DISPATCHED` line read done before PROVE PASS; every contradicted report produced a `REMEMBER` lesson
