# Register — the chief of staff turns an approved profile into a trigger

Only the chief of staff runs this, top-level, after a `❓ DECISION REQUIRED` for this
exact profile was answered "register". Creating, changing, pausing, firing on demand, or
deleting a trigger is a gated action (`skills/chief-of-staff/SKILL.md`); an approval covers
one profile, one time.

The chief of staff has no write path. Every file change below is a Level-1 dispatch to
`cks:operator` ("write exactly this, commit with this message, report the SHA").

## 1. Validate the profile

Read `.routines/<slug>/ROUTINE.md`. Refuse — return the failing check as an ESCALATE, do
not create anything — unless all of these hold:

| Check | How |
|---|---|
| All 16 schema fields present | grep the frontmatter against the table in `SKILL.md` |
| No `<slot:` anywhere | `grep -c '<slot:'` is 0 |
| `cadence` parses as 5 fields | five whitespace-separated tokens, each digit / `*` / `,` / `-` / `/`; hourly forms use minute 0 |
| `owner_role` is one of the 18 roles and not `chief-of-staff` | list in `SKILL.md` |
| `stop_condition` names external state and a backstop | contains a count, date, or ledger reference and an "or N runs" clause |
| `autonomy_level` ≤ 2, or a founder upgrade is recorded in the body with a date | never infer an upgrade |
| `report_to` values are from the allowed set | `push`, `email`, `channel:<name>`, `issue` |
| `connectors` are names the registering session can resolve | unknown names fail `create_trigger`; ask rather than guess |
| `budget_per_run` is a number | USD |

## 2. Create the trigger

A trigger created through the MCP fires a session with **no repository** (`create_trigger`
has no source parameter; `session_request.config.sources` is empty), so a fresh-session routine
has nothing to read and nothing to push. HQ routines therefore fire into one **persistent HQ
session** that already holds the checkout. Verified 2026-09-09: a session created with
`source_url: <HQ>` has HQ at its working directory, pushes to `main` with the existing remote
and no credentials, and carries `add_repo`, `PushNotification` and the Remote MCP.

**2a. The HQ session (once per environment, reused by every routine).** If `list_sessions`
shows an open session tagged `cks-hq-routines`, reuse its id. Otherwise:

```
create_session(
  source_url: "https://github.com/<HQ owner/repo>",
  title: "HQ routines",
  tags: ["cks-hq-routines"],
  permission_mode: "default",
  prompt: "Run git clone --depth 1 https://github.com/cardinalconseils/claude-starter
           claude-starter (public repo: no add_repo, no credentials), then wait."
)
```

`permission_mode: "auto"` is mandatory, not a preference: a `default`-mode session stops at
its first MCP call (a web search, a connector) waiting for a permission prompt nobody answers —
the 2026-09-10 acceptance run stalled exactly there after $7.54. Creating the session in `auto`
requires the registering session itself to be in auto mode.

Re-create it (archive the old one; `update_trigger` cannot rebind, so re-create each routine's
trigger with the new `persistent_session_id` and pause the old one) when its context passes
~60% — every run keeps its state in files, so nothing is lost.

To test a bound routine, do not use `fire_trigger`: it mints a fresh, repo-less session and
ignores the binding. Create a one-shot `create_trigger(run_once_at: <now + 3 min>,
persistent_session_id: <HQ session>, prompt: <the routine prompt>)` — it exercises the exact
scheduled path and disables itself after firing. Verified 2026-09-10: the wake landed in the HQ
session, the run committed `runs/2026-09-10.md` + `STATE.md` to HQ `main` and pushed the digest.

**2b. The trigger.**

```
create_trigger(
  name: "cks routine — <slug>",
  cron_expression: <cadence>,
  persistent_session_id: <HQ session id>,
  environment_id: <omit for inherit; otherwise resolve the name with list_environments>,
  initiation: "human_request",
  prompt: <the routine-run invocation below>
)
```

`notifications` is rejected for persistent-session routines; the prompt's FINISH step calls
`PushNotification` instead, which reaches the phone the same way. `connectors` is rejected
for this organisation ("not available"); a bound routine uses the connectors the HQ session
already holds, so the profile's `connectors` list is checked against that session, not passed.

Trigger prompt, verbatim apart from the slug and level:

```
CKS routine <slug>, autonomy Level <N>. This is a wake of the persistent HQ session: HQ is
checked out at your working directory and claude-starter at ./claude-starter.
SETUP: git pull --ff-only origin main in HQ. If ./claude-starter is missing, run
git clone --depth 1 https://github.com/cardinalconseils/claude-starter claude-starter (public
repo, no add_repo); otherwise git -C claude-starter pull --ff-only. add_repo is only for a
private repo the profile names, and only with the clone command it returns, verbatim. Never add
an Authorization header, never read or echo a token, never retry a clone with other
credentials; if a repo cannot be attached, end with one line
"NOT READ: could not attach <repo>" and stop.
RUN: if the CKS plugin is loaded, run Skill(skill="cks:chief-of-staff")
--routine .routines/<slug>/ROUTINE.md. If not, read claude-starter/skills/chief-of-staff/
SKILL.md, SKILL-ORCHESTRATOR.md and claude-starter/skills/routines/workflows/routine-run.md
and follow them; dispatch roles as general-purpose agents whose brief begins with the full
text of claude-starter/agents/<role>.md. This session is unattended: no AskUserQuestion —
escalate through the profile's report_to and the needs-you label.
FINISH: commit STATE.md and runs/<date>.md, git push origin main, then call PushNotification
with the report (under 12 lines); your final message repeats it.
```

The SETUP paragraph is not optional: a session that improvises a clone with hand-built
credentials is held by auto mode and never reaches the profile, and an `add_repo` call in a
default-mode session waits on a permission prompt nobody answers — public repos are cloned
plainly for that reason. Until the environment's setup
script installs CKS, the "if not loaded" branch is the one that runs.

A `repo` other than `HQ` does not change the trigger: the routine runs in the HQ session and
`routine-run.md` reaches the project repo through a remote session or `add_repo`.

Routines the owner registers in the claude.ai UI with a git source may keep
`create_new_session_on_fire: true` (that form carries the repo and accepts `notifications`);
the MCP cannot create that shape.

If `create_trigger` is unavailable in this session (no Claude Code Remote MCP), stop: report
`NOT READ: create_trigger — routine <slug> not registered` and surface a `▶ ACTION REQUIRED`
to open a cloud session on HQ and rerun `/cks:routine new`. Never substitute `CronCreate`.

## 3. Write back and commit

Level-1 dispatch to `cks:operator`: set `trigger_id: <id from the result>` in
`ROUTINE.md`, create `STATE.md` from the seed in `SKILL.md` (`runs_total: 0`), create
`runs/.gitkeep`, commit `routine(<slug>): register <trigger id>` and push to HQ. Report the
SHA in the brief under `DISPATCHED`.

## Pause / resume / run-now / delete

Each is gated; each needs its own approval this session.

| Command | Call | Then |
|---|---|---|
| `/cks:routine pause <slug>` | `update_trigger(trigger_id, enabled: false)` | operator appends `paused: <date>` to `STATE.md`, commits |
| `/cks:routine resume <slug>` | `update_trigger(trigger_id, enabled: true)` | operator removes the `paused:` line, commits |
| `/cks:routine run-now <slug>` | `fire_trigger(trigger_id, text: "manual fire by <user> on <date>")` | nothing to write; the fired run writes its own log |
| cadence or prompt change | `update_trigger(trigger_id, cron_expression | prompt)` | operator updates `cadence` in `ROUTINE.md`, commits |
| `/cks:routine delete <slug>` | see below | |

Delete is destructive — show the `⛔ DESTRUCTIVE ACTION` block (`.claude/rules/destructive-ops.md`)
then a `❓ DECISION REQUIRED` with the safer alternative first:

```
  1. Pause instead — trigger disabled, profile and history kept (Recommended)
  2. Delete the trigger, keep .routines/<slug>/ as history (trigger_id cleared)
  3. Delete the trigger and move .routines/<slug>/ to .routines/_archived/<slug>/
```

Only option 2 or 3 calls `delete_trigger`. Never remove the directory outright; run logs are
the routine's audit trail.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "He approved the profile last week, cadence change is minor" | Every trigger change is its own gated action. Ask again. |
| "I'll fix the missing field myself and register" | A missing field is an unfinished interview. ESCALATE it; the strategist finishes. |
| "No Remote MCP here, CronCreate will do for now" | Then it is not registered. `NOT READ` + `▶ ACTION REQUIRED`. |
| "Delete is cleaner than pause" | Pause keeps the history and the id. Delete needs the destructive block and a decision. |
| "I'll write trigger_id into the file with Bash" | No write path. Level-1 dispatch to `cks:operator`. |

## Verification

- [ ] Every check in step 1 passed, or the failure was returned as an ESCALATE with no trigger created
- [ ] `create_trigger` called with `persistent_session_id` of the `cks-hq-routines` session and `initiation: "human_request"`; no `connectors`, no `notifications`
- [ ] Trigger prompt matches the routine-run invocation verbatim apart from the slug
- [ ] `trigger_id` written back, `STATE.md` seeded, commit SHA reported
- [ ] Pause / resume / run-now / delete each preceded by their own approval; delete preceded by the destructive block
