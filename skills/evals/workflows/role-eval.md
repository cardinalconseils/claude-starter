# Workflow: Role Eval — score an `agents/<role>.md` body against its golden briefs

Run by the tester (evals mode, `Mode: role-eval`). A role eval dispatches one role with a
realistic brief inside a scratch copy of a fixture, then checks three things a reader can
verify without taste: the **artifact shape** it left on disk, what it **must not** have done
(tools called, files touched), and the **return shape** its body promises. Smoke tier only:
every case is binary and the role passes only when every case passes.

The corpus lives in `.evals/golden/roles/<role>/case-NN-<slug>/` (`brief.md`, `expected.md`,
optional `fixture/`); results go to `.evals/results/roles/<role>.json` (per-dev, gitignored).
`scripts/test-integrity.sh` check 12b refuses a change to `agents/<role>.md` until that
result exists, is newer than the change, and has `pass_rate` 1.0.

## Step 1: Scope

`--role=<role>` names one role; `--role=all` runs all eighteen. Confirm each
`.evals/golden/roles/<role>/` has at least three cases — fewer is a corpus gap to report,
not a reason to skip. Record `agent_file_sha=$(git hash-object agents/<role>.md)` before
any case runs; the result is only valid for that body.

Lint the corpus first: `bash scripts/role-eval-check.sh --lint .evals/golden/roles/<role>`
— an unknown check verb fails closed later, so catch it now.

## Step 2: Scratch worktree per case

Each case runs in its own directory so a role that writes outside its scope is caught by a
diff, not by memory:

```bash
SCRATCH=$(mktemp -d /tmp/role-eval-XXXXXX)
[ -d "$CASE/fixture" ] && cp -R "$CASE/fixture/." "$SCRATCH/"
mkdir -p "$SCRATCH/.prd/logs"                       # the SubagentStop trace needs it
git -C "$SCRATCH" init -q -b main && git -C "$SCRATCH" add -A \
  && git -C "$SCRATCH" -c user.email=eval@cks -c user.name=cks-eval commit -qm fixture
```

The fixture commit is the baseline: everything the role adds or changes shows in
`git status --porcelain` afterwards. Never reuse a scratch dir across cases.

Environment: unset `CKS_HQ` and `CKS_ACTIVE_USER` unless the brief's `## Runner environment`
section asks for them (assistant, finops and historian cases set `CKS_HQ=$SCRATCH` and
`CKS_ACTIVE_USER=eval` so the user directory resolves inside the scratch). No connector is
ever reachable from an eval run — pass an empty MCP config so a "never sends" case is
proven against an absent tool, not a mocked one.

## Step 3: Dispatch the role

The tester holds no `Agent` tool, so the role is dispatched by a headless top-level session
whose only job is that one dispatch. Running it *from the scratch dir* makes the role's cwd
the scratch, fires `SubagentStop`, and writes the trace line the must-not checks read:

```bash
BRIEF=$(cat "$CASE/brief.md")
( cd "$SCRATCH" && claude -p \
    "Dispatch exactly one sub-agent and nothing else: Agent(subagent_type=\"cks:$ROLE\", prompt=<the brief below>). Return the sub-agent's result verbatim, with no commentary.

$BRIEF" \
    --output-format json --permission-mode bypassPermissions \
    --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
  > "$SCRATCH.result.json" 2> "$SCRATCH.stderr" )
jq -r '.result' "$SCRATCH.result.json" > "$SCRATCH.return.txt"
```

`bypassPermissions` is acceptable only because the scratch holds nothing but the fixture
and no MCP server is reachable; never run a role eval from a real project directory.

Exceptions:
- **chief-of-staff** is a top-level skill, not a sub-agent — dispatched as a sub-agent it
  correctly refuses. Run it as the main agent instead:
  `claude --agent cks:chief-of-staff -p "$BRIEF" …` from the scratch. There is no
  SubagentStop line; the transcript is the session file (Step 4) and `trace-outcome` is
  not used in its cases.
- Roles with network grants (researcher, strategist, marketer) may spend real queries;
  their briefs carry a query budget. Do not widen it.

## Step 4: Collect the evidence

Three sources, all read-only:

1. **Scratch diff** — `git -C "$SCRATCH" status --porcelain --untracked-files=all`, with
   `.prd/logs/` ignored (the hook writes there). Added vs modified paths feed
   `no-writes`, `no-new-files`, `writes-only-under`, `unchanged`.
2. **Trace line** — `$SCRATCH/.prd/logs/agents/cks:<role>.jsonl` (the file is named after
   the payload's `agent_type`; glob `*<role>*.jsonl`). Its last line is the dispatch:
   `outcome` feeds `trace-outcome`; `transcript` is the basename of the sub-agent's
   transcript.
3. **Transcript** — `find ~/.claude/projects -name "<transcript basename>"`; every
   `tool_use` block's `name` is a tool the role called. This is the only proof for
   `tool-not-called`. Transcript not found → the check fails closed and `notes` says so;
   do not infer "not called" from the diff.

## Step 5: Score with the checker

```bash
bash scripts/role-eval-check.sh --case "$CASE" --scratch "$SCRATCH" \
  --return "$SCRATCH.return.txt" --transcript "$TRANSCRIPT" \
  --trace "$SCRATCH/.prd/logs/agents/cks:$ROLE.jsonl"
```

It prints one `PASS`/`FAIL` line per bullet and a final JSON line with `artifact_ok`,
`must_not_ok`, `return_ok`, `pass`, `notes`. Smoke tier is binary: a case passes only when
all three are true. Never rerun a failing case "to see if it flakes" without recording the
first run; never edit `expected.md` to make a run pass.

### Check vocabulary (`expected.md`)

Three headings, each holding `- verb: args` bullets. Paths are relative to the scratch and
accept globs; regexes are Python `re` with `MULTILINE`.

| Section | Verb | Passes when |
|---|---|---|
| Artifact shape | `exists: <glob>` | a non-empty file matches |
| | `absent: <glob>` | nothing matches |
| | `heading: <glob> :: <text>` | a heading line (`#…`) contains the text |
| | `contains: <glob> :: <regex>` / `not-contains:` | the files' text matches / does not |
| | `frontmatter: <glob> :: <key>` | YAML front-matter has `<key>:` |
| | `unchanged: <path>` | byte-identical to `fixture/<path>` |
| Must not | `no-writes` | scratch diff empty |
| | `no-new-files` | nothing added (modifications allowed) |
| | `writes-only-under: <path>[, …]` | every added/modified path is one of these or under one |
| | `no-written-file-matches: <regex>` | no added/modified file matches |
| | `commit-count: <ref> :: <n>` | `git rev-list --count <ref>` equals n |
| | `tool-not-called: <name>[, …]` / `tool-called:` | fnmatch against transcript tool names |
| Return shape | `return-matches: <regex>` / `return-not-matches:` | the returned text |
| | `return-section: <text>` | a line starts with the text |
| | `trace-outcome: completed` | the trace line's `outcome` |

Any verb may appear under any section; the section only decides which flag it feeds.

## Step 6: Result file

`.evals/results/roles/<role>.json` (create `.evals/results/roles/`):

```json
{
  "role": "debugger",
  "ran_at": "2026-09-07T14:02:11Z",
  "agent_file_sha": "<git hash-object agents/debugger.md>",
  "runner": "headless",
  "cases": [
    {"name": "case-01-trace-and-minimal-edit", "pass": true, "artifact_ok": true, "must_not_ok": true, "return_ok": true, "notes": ""},
    {"name": "case-02-db-fix-rls-denial", "pass": false, "artifact_ok": true, "must_not_ok": false, "return_ok": true, "notes": "tool-not-called: Write (called: ['Write'])"}
  ],
  "pass_rate": 0.5,
  "delta": null
}
```

`pass_rate` = passed / total, computed. `agent_file_sha` must equal the current
`git hash-object agents/<role>.md` or the integrity check treats the result as stale.

## Step 7: Pre/post delta (workforce-review, sleep-cycle contract)

When the run measures a proposed change to `agents/<role>.md` (the historian's `improve`
proposal applied by the builder on a branch), run the corpus twice and record the delta in
the same shape `.sleep/applied/*.json` uses (`.claude/rules/sleep.md` §6):

1. **Pre** — on the unchanged body: run, save `pass_rate` as `pre_score`, keep the file as
   `.evals/results/roles/<role>.pre.json`.
2. **Post** — on the changed body: run, `post_score` = its `pass_rate`.
3. Write the `delta` object into the post result:
   `{"pre_score": 1.0, "post_score": 0.67, "delta": -0.33, "completed_at": "<ISO>"}`.

`delta < 0` blocks: the integrity check fails the role, the shipper does not open the PR,
and the report recommends reverting the body (`git checkout HEAD -- agents/<role>.md`) —
suggested, never auto-applied. `delta == 0` with `pass_rate 1.0` is the normal outcome for
a wording change. A positive delta on a body that was already at 1.0 is impossible; if the
pre run was below 1.0, say which cases the change fixed.

## Step 8: Report

```
TESTER — role-eval — {role}
Verdict:    {passed}/{total} (smoke)  → PASS | FAIL
Artifacts:  .evals/results/roles/{role}.json
Delta:      pre {x} → post {y} ({±d}) | n/a
Failures:   {case} — {section} — {first failing check and its note}
Uncovered:  {cases skipped, with reason} | none
Next:       historian (improve: cluster the failing checks) | builder (revert …) | none
```

Never say "role evals pass" without the per-case table. Never lower a check to fit a body.

## How to write a case

1. Pick the mode or refusal the role body promises that is **cheapest to observe**: a file
   it must write, a file it must not touch, a tool it must not call, a section its output
   block always carries. Three cases per role: two modes and the most important refusal.
2. `brief.md` — the dispatch contract the body expects (`Goal`, `Constraint`, `Done`,
   `Level`, `Mode` or `action`), plus the runner lines every brief carries: `Source: routine
   (non-interactive)` so an `AskUserQuestion` role narrates instead of blocking, and
   `project_root: .`. Put context inline or under `fixture/`. Synthetic only: `example`
   domains, `/tmp/test` paths, no real names, no credential shapes the secret gate matches,
   no model names. If a case plants a secret for a role to catch, give it a value like
   `planted-…-0001` and assert `return-not-matches` on it.
3. `expected.md` — the three headings with checks from the vocabulary above. Every bullet
   must be decidable from the diff, the transcript, the trace, or the returned text. "The
   tone is right" is not a check; "the header line matches `^Inbox —`" is.
4. `fixture/` — the smallest state that makes the brief real: a `PLAN.md`, one failing
   test, a `BUDGET.md`, a JSON export standing in for an absent connector. Ship `.prd/logs/`
   as an empty dir (`.gitkeep`) when the role reads or the hook writes there.
5. Lint (`--lint`), then dry-run the checker against the fixture with an empty return to see
   every check fail for the right reason before you rely on it passing.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The body change is cosmetic, no need to run the evals" | The integrity check does not know that. Run them; a cosmetic change passes in minutes. |
| "I read the transcript, the tool was obviously not called" | Run the checker on the transcript. "Obviously" is how a send slips through. |
| "The case fails on a regex, not on behaviour — I'll loosen it" | Read the return first. If the body's output block changed, that is a finding for the historian; the golden set changes by PR, not mid-run. |
| "Running from the real project dir is faster than a scratch" | A role that writes outside its scope would then write into the real project. Scratch only. |
| "No transcript, but the diff is clean, so must-not passes" | The diff proves nothing about `send_message`. Fail closed; find the transcript. |
| "pass_rate 0.67 is fine for a first run" | Smoke is 100%. A failing case is a body defect or a bad case; either way it is the report, not a rounding error. |
| "The chief of staff refused as a sub-agent, mark it failed" | That refusal is correct behaviour. Run it with `--agent` as Step 3 says. |

## Verification

- [ ] `bash scripts/role-eval-check.sh --lint .evals/golden/roles` reports 0 problems
- [ ] Each case ran in a fresh scratch dir with the fixture committed first
- [ ] Every `tool-not-called` check was scored from a transcript, never inferred
- [ ] `.evals/results/roles/<role>.json` has `agent_file_sha` equal to the current body's hash and `pass_rate` computed from `cases`
- [ ] `delta` present whenever a pre run exists; `delta < 0` reported as blocking
- [ ] The report shows the per-case table before any verdict
