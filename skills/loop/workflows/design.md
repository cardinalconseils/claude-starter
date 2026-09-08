# Loop Design Workflow

Run by `cks:architect` in `Mode: loop-design` (dispatched by `SKILL-ORCHESTRATOR.md`
§1, or by the PRD design phase step [2e] when CONTEXT.md carries loop signals). Produces
`.loops/{slug}/LOOP-DESIGN.md` and `state.json`. The schedule is registered afterwards by
`cks:operator` — report the chosen frequency; do not create the trigger yourself.

## Prerequisite: lifecycle check

1. If a phase number (NN) was passed, use it. Otherwise:
   `find .prd/phases -maxdepth 1 -type d 2>/dev/null | grep -i "{slug}"`
2. Check `{phase_dir}/{NN}-CONTEXT.md` and `{phase_dir}/{NN}-DESIGN.md`.

CONTEXT.md missing → stop with:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    /cks:new to start the lifecycle for this loop feature first
Why:    Discovery artifacts are missing. Loop architecture without requirements
        produces a LOOP-DESIGN.md with no grounding in real user needs.
Then:   Return to /cks:loop design {slug} after Phase 1 and Phase 2 are complete.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

DESIGN.md missing → same block with `Run: /cks:design {NN}` and the reason "loop
architecture extends the design phase — it depends on component specs and system
boundaries defined there".

Both present → read CONTEXT.md in full, pre-fill every interview answer it already gives
(frequency, connectors, users, data sources), and ask only for what is missing.

When the orchestrator passed the standalone override, skip this check and note
"standalone operational loop — no lifecycle phase" in LOOP-DESIGN.md.

## Interview (AskUserQuestion, one topic at a time)

1. **Purpose** — recurring task, what one run processes, frequency (hourly / daily /
   weekly / custom), what a successful run produces, who reviews output and how often.
2. **Six-part composition** — for each part, does it apply?
   - Automations: what triggers the loop (cron, file change, webhook, manual)
   - Worktrees: does it modify files? (isolation deferred to V2 — runs share the main worktree)
   - Skills: domain expertise the runner needs (list CKS skills)
   - Connectors: external systems read or written (APIs, DBs, Slack, email, Telegram)
   - Sub-agents: does a run need a specialist? (the runner cannot dispatch — note the role
     to request from the chief of staff instead)
   - Memory: context across runs (`STATE.md` / `PROGRESS.md`)
3. **Stop condition (mandatory)** — "What should cause this loop to stop?" Accept only
   conditions checkable without asking the agent: a file exists (`.loops/{slug}/STOP`), max
   iterations, error-rate threshold, N consecutive empty runs, a date/event. Push back on
   vague answers. **Refuse to write LOOP-DESIGN.md until one is concrete.**
4. **Autonomy level** — explain the ladder (Level 1 suggestions only; 2 drafts; 3 applies
   and shows before commit; 4 applies and commits with audit log). Default Level 1. Level 3+
   requires an explicit upgrade after one review cycle at the previous level.
5. **Observability** — Sentry DSN? LangSmith project (when the loop makes LLM calls)? An
   empty string is an explicit opt-out and must be stated; an absent field means the
   scaffold is incomplete.

## Output: `.loops/{slug}/LOOP-DESIGN.md`

```markdown
# Loop Design: {slug}

## Purpose
{One paragraph}

## Six-Part Composition
**Automations:** {trigger}
**Worktrees:** {yes/no — V2 deferral note if yes}
**Skills:** {list or "none"}
**Connectors:** {list or "none"}
**Sub-agents:** {roles to request, or "none"}
**Memory:** {STATE.md / PROGRESS.md, or "none"}

## Stop Condition
{Exact, checkable condition}
Backstop: {max iteration count, e.g. "100 runs then pause and report"}

## Autonomy Level
Level {1|2|3|4}: {description}
Upgrade path: {what must happen to move up one level}

## Schedule
{frequency chosen} — pending: orchestrator registers the trigger via cks:operator

## Observability
sentry_dsn: {value or "empty — explicit opt-out"}
langsmith_project: {value or "empty — explicit opt-out"}
```

## Output: `.loops/{slug}/state.json`

```json
{"slug": "{slug}", "autonomy_level": 1, "sentry_dsn": "", "langsmith_project": ""}
```

Fill actual values from the interview. Create `.loops/{slug}/` first.

## Constraints

- No LOOP-DESIGN.md without a stop condition
- Never scaffold at Level 3+ without explicit user confirmation
- Both observability fields present in state.json, even as empty strings
- Report the two paths and the chosen frequency when done
