# Executing sessions — spawn, brief, check in, close

An executing session is a separate Claude Code Remote session with its own context, spawned
by you for work that outlives one dispatch, lives in another repo, or must survive this
session's context. You coordinate and verify; you never implement. Isolation is the feature:
one session's confusion does not contaminate another's.

Your job, in order: pull and assign work from the board in order; write briefs a weaker model
could follow without your judgment; verify claims by re-running (`workflows/verify.md`); read
diffs, not transcripts; record lessons before the session ends; steer a drifting session
without taking the work away from it — the moment you start coding you stop verifying.

## Sub-agent or session

| Use | When |
|---|---|
| In-session `Agent()` sub-agent | Same repo, finishes in one dispatch, inside this session's budget |
| Claude Code Remote session | Another repo (`repo: owner/repo`), work spanning several dispatches or hours, a routine's cross-repo fix, anything that must outlive this session |

The three-concurrent cap counts sub-agents and sessions together. Start with one coordinator
and one executor; get the verification loop honest before adding a second.

**When not to use.** A single well-scoped change is one dispatch, no session. No board means
several sessions and hoping. The overhead is the point — it buys a result you can trust.

## Spawn

Ledger line and issue first (step 4 of the loop) — no issue, no session. The issue body is
the build contract, written by `cks:project-manager` at step 4: problem statement, action
items, interfaces, validation contract (the red-gate command from `workflows/verify.md`),
non-goals — detailed enough that the executor never needs a parent document. A committed
brief is reviewable and re-runnable; a long launch string is neither, and fails to execute
reliably. Then:

```
create_session(
  source_url: "https://github.com/<owner>/<repo>",
  title: "cks exec — #<n> <slug>",
  tags: ["cks-exec", "issue-<n>"],
  permission_mode: "auto",
  prompt: "Read issue #<n> on <owner/repo> (Context: <issue url>) and do exactly what it says.
           Report per its Report contract."
)
```

`permission_mode: "auto"` is mandatory — a default-mode session stalls at its first MCP or
permission prompt nobody answers (`skills/routines/workflows/register.md` §2a). Post the
session id as the first comment on the issue. Then verify the session actually started:
`get_session` must show `working` and the expected repo — a launcher's "created" is not an
agent running. Filter by the `issue-<n>` tag, never by "newer than the last session".
Fallbacks, in order: `add_repo` + in-session dispatch on the clone; then a `GATED:` handoff
under `NEEDS YOU`. Never a silent skip.

## The brief

The issue body carries these fields; the launch prompt only points at it.

```
Issue: #<n>
Goal: <outcome, not activity>
Constraint: budget $<n>; touch only <file scope>; branch <issue>-<slug>; never merge; never a
  gated action; if the task grows beyond this brief, stop and post on the issue.
Done: <the red-gate command that must now pass — workflows/verify.md>
Level: <1|3|4|5> — <one line on what that means here>
Report contract: Your report is the board, not a message. Post a status comment on issue #<n>
  when you start, at every stopping point, and when you finish: `status: in-progress |
  blocked | done`, every command you ran with its exit code, `git diff --stat`, `NOT READ`.
  Push the branch and open a draft PR. A message to the coordinator is a courtesy; it may
  never arrive.
```

Status flips atomically with the work — `in-progress` the moment the executor starts, `done`
the moment PROVE passes — never batched at the end of a session. A board that is only true
at standdown is not a board. Comments are where the founder leaves direction and the executor
leaves reasoning.

## Two channels, different guarantees

`send_message` / `SendMessage` is for questions and flags. It may be queued behind a busy
session, held for approval by the receiving session's permission mode, or expire undelivered.
The durable channels are three: committed files (a brief, a handoff, a constraint — sessions
read the repo at startup), board cards and comments, and a share link (`Context: <url>` in
the launch prompt rather than pasted context). A message is a nudge. A file is a contract.

Silence is not agreement: a question with no answer on the board after one check-in means
blocked, never approved. An executor at a gate stops and posts.

## Check-in loop

Cadence 15–30 minutes, armed with `send_later` (Remote MCP: a message to this session,
`name: "check-in #<n>"`); `ScheduleWakeup` in the CLI; a routine for horizons past this
session's life. Never Bash sleep, never a polling loop. On each check-in, in order:

1. `get_session(session_id)` → `status_bucket`.
2. Read the board card: newest status comment, PR state.
3. Then by state:

| State | Move |
|---|---|
| `working`, card updated | Re-arm silently. Nothing to report. |
| `blocked`, or a question on the card | Answer on the board (`send_message` as the courtesy copy). Re-arm. |
| `review_ready` / `completed` / card `done` | Run `workflows/verify.md` (OBSERVE, PROVE, ARTIFACTS) → GATE → SHIP (PM flips status, one item one PR) → `archive_session`. |
| `failed`, or no card update across two check-ins | `interrupt_session`, read what it did, re-brief once with a tighter brief. Second failure → ESCALATE. |

Timer lands mid-item: let the executor finish the item, verify it, then report — never
interrupt a healthy session for the clock. The interval decides how often you surface, never
where the work stops. A checkpoint is a surfacing moment, not a permission request: the
report goes out and the next item starts in the same turn. If you catch yourself writing
"shall I continue?", delete it — a human who is watching will interrupt; one who is not just
had the run killed by a question. Every check-in that changes state is one ledger line
(`source: cli`, request `check-in #<n>`).

## Mechanics

- Session names are not addresses: re-list live sessions (`list_sessions` / `ListAgents`)
  before addressing one; never reuse a name read earlier.
- Short ids are display prefixes, not keys: resolve by a distinctive label substring, never
  pad one out. Search for the card's label, not your paraphrase of it.
- In a shared working tree, never a bare `git commit`: `git commit -- <paths>`, so a
  concurrent session's staged files are not swept in. Worktree isolation is the default.

## Close

A session is done only after PROVE PASS and the PM's status flip; then `archive_session`.
A session that ends without a card update is not done — it is a finding. Zombie audit:
`list_sessions` filtered by tag `cks-exec` against open issues labelled `cks:exec`. Filter
by tag or issue number, never by "newer than the last session" — that admits unrelated
sessions and misreads a healthy launch as broken.

At the end of every coordinating session the handoff artifact is updated — a Level-1
dispatch to `cks:project-manager` (`Mode: handoff`, plus the DEVLOG entry): current state and
anything learned — and lessons go to `REMEMBER`, persisted by `cks:historian`. This is what
makes sessions compound. Policy (this skill, `.claude/rules/`) is long-lived and reviewed;
briefs, task context and session instructions live on the board or under `.prd/`, never here.

## Failure modes this exists to catch

| Failure | Signal | Move |
|---|---|---|
| Self-report drift | Card says done; diff or re-run disagrees | PROVE FAIL path in `workflows/verify.md`; `REMEMBER` the executor and the claim |
| Context exhaustion | Long executor slows, repeats itself, loses the brief | Items too big — split at the board, shorter briefs, one item per session |
| Message loss | Question sent, no reply; session shows queued or held | The board is the truth; answer on the card, `send_message` as courtesy |
| Coordinator starts coding | You are editing, not verifying | Stop. Dispatch. The work goes back to the executor with a tighter brief |
| Zombie session | `cks-exec` session with no open `cks:exec` issue, or no card update in two check-ins | `interrupt_session`, read, `archive_session`; file the finding |
| Wrong-session filter | "Newer than last" picks up an unrelated session | Filter by tag or issue number only |
| Green gate before work | Red gate passes before the executor started | Close with a DROP line citing the check; never delegate against it |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll paste the whole brief into the launch prompt" | Long prompts fail to execute reliably. The issue body is the contract; the prompt points at it. |
| "The session was created, so it's running" | Created is not working. `get_session` must show `working` on the expected repo. |
| "I sent the answer by message, that's handled" | A message may never arrive. Answer on the board; the message is the courtesy copy. |
| "The timer fired, interrupt and get a status" | Let a healthy session finish the item. The clock decides when you surface, not where work stops. |
| "Shall I continue?" | Never. Report and start the next item in the same turn. A watching human interrupts; an absent one just lost the run. |
| "Bare `git commit` is fine, it's my branch" | In a shared tree it sweeps another session's staged files. `git commit -- <paths>`. |
| "No card update, but the session shows working — give it time" | One check-in, fine. Two without a card update is a failure, not a pass. |
| "Six executors, the work is parallel" | One coordinator, one executor until the loop is honest. Three in flight is the cap, sessions and sub-agents together. |

## Verification

- [ ] Every executing session has an issue card written by `cks:project-manager` before `create_session`, with the red-gate command as its validation contract
- [ ] `create_session` used `permission_mode: "auto"`, tags `cks-exec` + `issue-<n>`, and a prompt that points at the issue; the session id is the first comment on the card
- [ ] `get_session` confirmed `working` on the expected repo after spawn; sessions resolved by tag or issue number, never by recency
- [ ] A check-in was armed with `send_later` / `ScheduleWakeup` (never Bash sleep or a poll loop) and re-armed after each one
- [ ] Every check-in read `status_bucket` and the board card; no healthy session interrupted for the clock; no "shall I continue?"
- [ ] Every question with no board answer after one check-in was treated as blocked; no card update across two check-ins was treated as a failure
- [ ] No session archived before PROVE PASS and the PM's status flip; zombie audit run against open `cks:exec` issues
- [ ] Handoff updated by `cks:project-manager` at Level 1 and `REMEMBER` persisted by `cks:historian` before this session ended
