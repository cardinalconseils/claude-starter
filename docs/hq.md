# HQ — the workforce's home repo

## What it is

HQ is a private git repo (`cardinalconseils/hq` for the owner; any private repo works) that holds
everything that crosses ventures: the North Star, the finops ledger, routine profiles, workforce
memory and per-user assistant memory. Project repos stay thin — each keeps only its own `.prd/`,
`.finops/BUDGET.md`, rules and code. The plugin never ships HQ content; it only knows how to find it.

Why a repo and not `~/.cks/`: Claude Code web/mobile cloud sessions run in ephemeral containers, so
anything under the home directory is gone at the next session. A cloned repo is restored on every
session start and every change is a commit.

## Layout

```
CLAUDE.md               first turn of any session runs Skill(skill="cks:chief-of-staff"); state map
NORTH-STAR.md           cross-venture goals for the quarter — the chief of staff triages against it
.finops/BUDGET.md       HQ-level ceiling (venture tag "hq"); projects carry their own BUDGET.md
finops/ledger.jsonl     one line per spend across ventures — the finops role appends, never edits
.routines/<slug>/       ROUTINE.md profile + STATE.md + runs/ — cross-run memory of each routine
memory/{raw,wiki,output}/ workforce memory in OKF format (see .claude/rules/memory-format.md)
users/<slug>/           per-user assistant memory: profile.md, reminders.md, drafts/
.gitignore              secrets (.env*, *.pem, *.key) and regenerated caches
```

Scaffold it with `/cks:hq init [--user <slug>]` from inside the clone; `/cks:hq status` lists what exists.

## `CKS_HQ` resolution order

`scripts/hq-path.sh` is the single helper every reader sources. It exposes:

| Function | Result when `CKS_HQ` is set to a directory | Fallback |
|---|---|---|
| `cks_hq_root` | `$CKS_HQ` | `~/.cks` |
| `cks_user_dir <slug>` | `$CKS_HQ/users/<slug>` | `~/.cks/user/<slug>` (legacy singular `user`) |
| `cks_north_star_path` | first existing of `.prd/NORTH-STAR.md`, `NORTH-STAR.md`, `$CKS_HQ/NORTH-STAR.md`, `~/.cks/north-star.md` | empty |
| `cks_finops_dir` | `$CKS_HQ/finops` | `~/.cks/finops` |

Project-local files always win over HQ ones: a repo's `.prd/NORTH-STAR.md` shadows HQ's
`NORTH-STAR.md` in that repo's sessions. `CKS_HQ` pointing to a missing directory is treated as unset.

Readers today: `hooks/handlers/session-start.sh` (Goals/Budget banner and status packet),
`hooks/handlers/user-memory-guard.sh` (allowlist), `scripts/north-star-status.sh`.

## Cloud sessions and Routines

Set `CKS_HQ` in the cloud environment's setup script after cloning HQ, e.g.
`git clone <hq-url> "$HOME/hq" && export CKS_HQ="$HOME/hq"`. Sessions opened on HQ get the chief
of staff on turn one from HQ's `CLAUDE.md`; sessions opened on a project repo still read HQ state
through `CKS_HQ`. Routines (Claude Code Remote triggers) fire into one persistent session opened on HQ
(`skills/routines/workflows/register.md` §2a) — a trigger created through the MCP carries no
repository of its own — so a routine run reads its `.routines/<slug>/STATE.md` from that checkout
and commits `STATE.md` plus `runs/YYYY-MM-DD.md` back at the end of the run. Cross-repo work goes through Claude Code Remote sessions opened on the
project repo — the HQ session is the brain, not the worker.

## Routines

`.routines/` is the home of every recurring, unattended run (`skills/routines/SKILL.md`):

```
.routines/<slug>/ROUTINE.md                     profile — goal, north_star_goal, owner_role, sources,
                                                connectors, cadence (cron, UTC), environment, repo,
                                                autonomy_level, stop_condition, report_to,
                                                budget_per_run, quiet_hours, created, trigger_id
.routines/<slug>/STATE.md                       cross-run memory, under 50 lines, rewritten each run
.routines/<slug>/runs/YYYY-MM-DD.md             one log per fire, never edited afterwards
.routines/<slug>/references/<slug>-sources.md   what the owner role reads first every run
.routines/_archived/<slug>/                     deleted routines keep their history here
```

A profile is the contract; the Claude Code Remote trigger (`trigger_id`) is its schedule. Any
role may write a draft profile and return `❓ DECISION REQUIRED`; only the chief of staff
registers, pauses, fires or deletes the trigger (`skills/routines/workflows/register.md`). The
trigger's prompt loads the chief of staff with `--routine $CKS_HQ/.routines/<slug>/ROUTINE.md`,
and every run ends with `STATE.md` and `runs/<date>.md` committed here. `/cks:routine audit`
compares this directory with `list_triggers` and files drift as issues. Seed profiles, including
the three triggers the owner already runs, live in `skills/routines/templates/`.

## Telegram / Hermes sessions

The Hermes VPS process (`docs/hermes-mode.md`) uses the HQ clone as its working directory and sets
`CKS_HQ` to that path. Per-user memory then lives at `$CKS_HQ/users/<slug>/`, keyed by the trusted
`CKS_ACTIVE_USER`; `user-memory-guard.sh` confines each user to their own directory under either
layout and blocks traversal and cross-user paths exactly as before. State is pushed as commits, so
nothing is trapped on the VPS.

## What stays per-project

`.prd/` (state, phases, logs, `NORTH-STAR.md` when project-specific), `.finops/BUDGET.md` and the
gitignored `.finops/costs.jsonl`, `.claude/rules/`, `.learnings/`, `.harness-evals/`, and the
per-dispatch agent traces in `.prd/logs/agents/*.jsonl`. Nothing in HQ references a project file by
absolute path.

## Sessions without the plugin

A Routine fires a fresh cloud session in the environment it inherits. If that environment's
setup script does not install CKS, `/cks:*` commands and `cks:<role>` agent types do not
exist there. The HQ `CLAUDE.md` covers this: the session attaches and clones
`cardinalconseils/claude-starter`, follows `skills/chief-of-staff/SKILL.md` and
`SKILL-ORCHESTRATOR.md` as instructions, and dispatches roles as `general-purpose` agents
with the matching `agents/<role>.md` body as the brief's system section (the chief of
staff's resolution order, step 3). The durable fix is one line in the environment setup
script: run `install.sh` from the plugin repo so every fired session loads CKS natively.

Attach repos with `add_repo` only and run the clone command it returns verbatim — and only for
repos the session does not already hold: HQ routines wake a persistent session that has HQ checked
out and `claude-starter/` cloned beside it. A fired
session that hand-builds git credentials (an `Authorization` header, a token in the URL) is
held by auto mode for approval nobody is there to give, and the routine never runs. The
first cultural-observer acceptance run stalled exactly this way.
