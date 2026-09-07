# Loop Run Workflow

Run by `cks:builder` in `Mode: loop-run` for one iteration of loop `{slug}` (optional
`args`). Dispatched by `SKILL-ORCHESTRATOR.md` §2.

## Step 1: Read LOOP-DESIGN.md

`.loops/{slug}/LOOP-DESIGN.md` missing → stop:
```
Cannot run loop '{slug}': LOOP-DESIGN.md not found at .loops/{slug}/LOOP-DESIGN.md
Run: /cks:loop design {slug}
```
Present but no stop-condition section → stop:
```
Cannot run loop '{slug}': LOOP-DESIGN.md is missing a stop condition.
Edit .loops/{slug}/LOOP-DESIGN.md to add a valid stop condition before running.
```

## Step 2: Read state.json

Extract `sentry_dsn`, `langsmith_project`, `autonomy_level` (1–4). Missing file → create it
with `{"slug":"{slug}","autonomy_level":1,"sentry_dsn":"","langsmith_project":""}`.

## Step 3: Check the stop condition

Evaluate it. Met → append a final health entry with `outcome: "pass"` and
`summary: "Stop condition met — loop halted"`, then stop and notify.

## Step 4: Open the LangSmith trace (when configured)

Generate `run_id` (`uuidgen` or `python3 -c "import uuid; print(uuid.uuid4())"`) — always,
it keys health.jsonl. When `langsmith_project` is non-empty, open the trace with `run_id`
as the trace ID; it must be closed at the end of the run, pass or fail.

## Step 5: Execute the loop task

Perform the task in LOOP-DESIGN.md "Purpose". Read `.loops/{slug}/STATE.md` first when it
exists. Enforce the autonomy level:

- Level 1: write suggestions to the output file only; apply nothing
- Level 2: write drafts (PRs, documents); do not send or merge
- Level 3: apply changes, show them to the user before committing
- Level 4: apply and commit with an audit log entry

The design's "Sub-agents" part names roles a run may need; you cannot dispatch them —
record the request in the output file's "Next Run Context" for the chief of staff.

Unhandled exception → when `sentry_dsn` is non-empty capture it to Sentry immediately,
before writing the health entry (mandatory); record it in the summary; set
`outcome: "fail"`.

## Step 6: Append the health.jsonl entry

`.loops/{slug}/health.jsonl` (create if absent), one line:
```json
{"schema_version":1,"loop_slug":"{slug}","run_id":"{uuid}","ts":"{ISO8601 UTC}","outcome":"pass|fail","summary":"{what happened}","iteration":{n}}
```
`schema_version` is always `1`; `ts` is UTC (`date -u +"%Y-%m-%dT%H:%M:%SZ"`); `iteration`
= existing line count + 1; `summary` is a meaningful one-liner.

## Step 7: Close the LangSmith trace (when configured)

Always — pass or fail, every run.

## Step 8: Write the run output

`.loops/{slug}/output/{run_id}.md`:
```markdown
# Run {run_id}

**Slug:** {slug}  **Iteration:** {n}  **Timestamp:** {ts}  **Outcome:** {pass|fail}

## Summary
## Findings
{suggestions, drafts, or applied changes — per autonomy level}
## Next Run Context
{what run N+1 should know or focus on; specialist requests for the chief of staff}
```

## Step 9: Update STATE.md (when memory is declared)

Keep `.loops/{slug}/STATE.md` under 50 lines: what this run completed, what the next run
should focus on, deferred items, iteration count.

## Constraints

- Never swallow exceptions silently when `sentry_dsn` is set
- Never omit `schema_version: 1`
- Never leave a LangSmith trace open
- Never run without LOOP-DESIGN.md and a stop condition
- Level 1 loops write only — never apply
