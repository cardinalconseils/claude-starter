# Role Evals — Golden Briefs

Three smoke cases per v6 role (`docs/v6-workforce.md`), 54 in all. Each case dispatches
the role with a realistic brief inside a scratch copy of its fixture and checks what a
reader can verify without taste: the files it left, what it must not have done, and the
shape of what it returned. This is the harness that makes a change to `agents/<role>.md`
measurable — `.harness-evals/` covers hooks, `.evals/golden/<feature>/` covers product
features, this directory covers the role bodies themselves.

## Layout

```
.evals/
  golden/roles/<role>/
    case-NN-<slug>/
      brief.md       ← the dispatch: Goal / Constraint / Done / Level (+ Mode or action),
                       runner lines, inline context
      expected.md    ← ## Artifact shape / ## Must not / ## Return shape — checkable bullets
      fixture/       ← optional: the smallest project state the brief needs
  results/roles/<role>.json   ← per-dev run results (gitignored)
```

Case names: `case-NN-<kebab-slug>`, NN for sort order. The three cases together cover the
role's main modes and its most important refusal (assistant never sends, debugger never
creates a file, reviewer never writes, chief of staff says `NOT READ` for a missing source).

## Running

```
/cks:evals --type=role --role=<role>       # one role
/cks:evals --type=role --role=all          # all eighteen
```

Both dispatch `cks:tester` with `Mode: role-eval`, which follows
`skills/evals/workflows/role-eval.md`: lint the corpus, one scratch git worktree per case
(fixture committed as the baseline), the role dispatched by a headless top-level session
run *from the scratch* with no MCP servers, evidence from the scratch diff + the
`SubagentStop` trace line + the sub-agent transcript, scoring with
`scripts/role-eval-check.sh`, result to `.evals/results/roles/<role>.json`.

Manual equivalent, per case:

```bash
CASE=.evals/golden/roles/debugger/case-01-trace-and-minimal-edit; ROLE=debugger
SCRATCH=$(mktemp -d /tmp/role-eval-XXXXXX); cp -R "$CASE/fixture/." "$SCRATCH/"; mkdir -p "$SCRATCH/.prd/logs"
git -C "$SCRATCH" init -q -b main && git -C "$SCRATCH" add -A && git -C "$SCRATCH" -c user.email=eval@cks -c user.name=cks-eval commit -qm fixture
( cd "$SCRATCH" && claude -p "Dispatch exactly one sub-agent and nothing else: Agent(subagent_type=\"cks:$ROLE\", prompt=<the brief below>). Return its result verbatim.

$(cat "$CASE/brief.md")" --output-format json --permission-mode bypassPermissions --strict-mcp-config --mcp-config '{"mcpServers":{}}' > "$SCRATCH.result.json" )
jq -r .result "$SCRATCH.result.json" > "$SCRATCH.return.txt"
T=$(find ~/.claude/projects -name "$(jq -r .transcript "$SCRATCH"/.prd/logs/agents/*"$ROLE"*.jsonl | tail -1)" | head -1)
bash scripts/role-eval-check.sh --case "$CASE" --scratch "$SCRATCH" --return "$SCRATCH.return.txt" --transcript "$T" --trace "$SCRATCH"/.prd/logs/agents/*"$ROLE"*.jsonl
```

`chief-of-staff` runs as the main agent (`claude --agent cks:chief-of-staff -p …`) — as a
sub-agent it correctly refuses. Assistant, finops and historian briefs carry a
`## Runner environment` section (`CKS_HQ=$SCRATCH`, `CKS_ACTIVE_USER=eval`).

## The gate

`scripts/test-integrity.sh` check 12b ("role evals") runs on every invocation, including
`--quick` from the pre-commit hook. For each `agents/<name>.md` that differs from
`origin/main` (or `main`):

- golden dir absent → warning (write the three cases)
- fewer than three cases → warning
- `.evals/results/roles/<name>.json` missing → **fail**
- result older than the agent file's last commit, or `agent_file_sha` ≠ `git hash-object agents/<name>.md` → **fail** (stale)
- `pass_rate` ≠ 1.0 → **fail**
- `delta.delta < 0` → **fail** (the change made the role worse)

Results are per-developer and gitignored, so **the first run must happen on the machine
that commits**: until the tester has run `/cks:evals --type=role --role=all` after the v6
role bodies landed, check 12b fails for every role that differs from `main`. That is the
intended state, not a bug — a role body nobody has measured does not merge.

## Adding a case

1. Read the role body and pick the cheapest observable promise: a file it must write, a
   file or tool it must never touch, a section its output block always carries.
2. Copy an existing case dir of that role; rewrite `brief.md` with `Goal`, `Constraint`,
   `Done`, `Level`, the `Mode` (or `action` / `scope`) the body expects, and keep the two
   runner lines (`Source: routine (non-interactive) …`, `project_root: .`).
3. Write `expected.md` with the check vocabulary in `skills/evals/workflows/role-eval.md`
   (Step 5). Every bullet must be decidable from the scratch diff, the transcript, the
   trace, or the returned text.
4. Keep `fixture/` tiny and synthetic: `example` domains, no real paths, no credential
   shapes the pre-commit secret gate matches, no model names. A planted secret for a role to
   catch looks like `planted-…-0001` and gets a `return-not-matches` bullet.
5. `bash scripts/role-eval-check.sh --lint .evals/golden/roles/<role>` → 0 problems.
6. Run the case once; a golden case that has never passed is not golden.

Golden dirs are committed; `.evals/results/` never is.
