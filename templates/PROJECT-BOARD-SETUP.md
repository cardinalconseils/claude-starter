# Project board — one-time setup

Do this once per account. After it, every issue an agent opens appears on the board
automatically, and nothing needs an integration, an API key, or a sync job.

Fifteen minutes, all of it in the GitHub UI.

## Why a board and not a database

The board is a **view of the issues**, not a second copy of them. Agents write issues;
GitHub's own workflows move the cards. There is one source of truth, so the view cannot
drift from reality — which is the failure every "sync my tasks into another tool" setup
eventually hits.

## 1. Create the project

github.com → your profile → **Projects** → **New project** → **Board**.

Name it for the portfolio, not one repo — it spans every venture. "Cardinal Workforce"
works.

## 2. Set the columns

Rename the default `Status` options to these, in order:

| Column | What sits here |
|---|---|
| **Inbox** | Opened, not yet triaged. The chief of staff empties this. |
| **Todo** | Accepted, ready, nobody started. |
| **In progress** | An agent holds it right now. |
| **Needs you** | Blocked on the founder — a gate, or a question only he can answer. |
| **In review** | A PR is open against it. |
| **Done** | Merged or closed with evidence. |

**Needs you** is the one that earns the board. It should be checkable in ten seconds to
answer "am I the blocker right now?"

## 3. Turn on the built-in workflows

Project → **⋯** → **Workflows**. Enable, and set the target column:

| Workflow | Set to |
|---|---|
| Item added to project | **Inbox** |
| Item reopened | **Todo** |
| Pull request merged | **Done** |
| Item closed | **Done** |
| Code changes requested | **In progress** |

These are GitHub's, not ours. They keep running whether or not any agent does.

## 4. Auto-add every repo the workforce touches

Same Workflows screen → **Auto-add to project** → enable → choose a repository → filter:

```
is:issue is:open
```

Add one entry per repo: `claude-starter`, `CardinalConseils`, `proposai`,
`serviconnect`, and any new venture.

This is the step that makes it deterministic. From here, **an agent opening an issue is
the same act as putting it on your board** — there is no second step to forget.

## 5. Add the fields the agents write

Project → **+** in the field header:

| Field | Type | Why |
|---|---|---|
| `Venture` | Single select | Filter the board to one business |
| `Level` | Number | Autonomy granted on that dispatch (1/3/4/5) |
| `Agent` | Text | Which specialist holds it |

Then save a view per venture, and one view filtered to `Needs you`. That last view is
your daily check.

## 6. Label for the gate

Repo → Issues → Labels → new label **`needs-you`**, colour red.

The `project-manager` agent applies it to anything waiting on you. Pair it with a board
filter so it lands in the **Needs you** column on sight.

## Verifying it works

Open a test issue in any auto-added repo. It should appear in **Inbox** within a few
seconds without anyone touching the board. Close it — it should move to **Done**.

If that round trip works, the wiring is correct and nothing else needs checking.
