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

```
create_trigger(
  name: "cks routine — <slug>",
  cron_expression: <cadence>,
  create_new_session_on_fire: true,
  environment_id: <omit for inherit; otherwise resolve the name with list_environments>,
  connectors: <connectors from the profile; [] when empty>,
  notifications: { push: <"push" in report_to>, email: <"email" in report_to> },
  initiation: "human_request",
  prompt: <the routine-run invocation below>
)
```

Trigger prompt, verbatim apart from the slug:

```
CKS routine <slug>. You start fresh.
SETUP: call the add_repo tool for <HQ owner/repo> (access: push) and then for
cardinalconseils/claude-starter (access: <push if repo is claude-starter, else read>); run
the clone command each result returns verbatim, --depth 1, one repo at a time. Never add an
Authorization header, never read or echo a token, never retry a clone with other
credentials; if add_repo is unavailable or a clone is denied, end with one line
"NOT READ: could not attach <repo>" and stop.
RUN: if the CKS plugin is loaded, from the hq clone run Skill(skill="cks:chief-of-staff")
--routine .routines/<slug>/ROUTINE.md. If not, read claude-starter/skills/chief-of-staff/
SKILL.md, SKILL-ORCHESTRATOR.md and claude-starter/skills/routines/workflows/routine-run.md
and follow them; dispatch roles as general-purpose agents whose brief begins with the full
text of claude-starter/agents/<role>.md. This session is unattended: no AskUserQuestion —
escalate through the profile's report_to and the needs-you label. End with STATE.md and
runs/<date>.md committed to HQ.
```

The SETUP paragraph is not optional. A fired session has no repo checked out and, until the
environment's setup script installs CKS, no plugin; a session that improvises a clone with
hand-built credentials is held by auto mode and never reaches the profile.

`notifications` is accepted only with `create_new_session_on_fire: true` — which every
routine uses. A `repo` other than `HQ` does not change the trigger: the fired session opens
on the environment's default source (HQ) and `routine-run.md` reaches the project repo
through a remote session.

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
- [ ] `create_trigger` called with `create_new_session_on_fire: true`, `initiation: "human_request"`, connectors and notifications from the profile
- [ ] Trigger prompt matches the routine-run invocation verbatim apart from the slug
- [ ] `trigger_id` written back, `STATE.md` seeded, commit SHA reported
- [ ] Pause / resume / run-now / delete each preceded by their own approval; delete preceded by the destructive block
