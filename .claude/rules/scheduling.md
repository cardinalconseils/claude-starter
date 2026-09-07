# Scheduling Rules

## Mandatory Behavior

When any feature description, CONTEXT.md, PLAN.md, or user message contains scheduling signals, the planner MUST route the feature through the routines flow (`skills/routines/`) BEFORE writing PLAN.md: the chief of staff dispatches `cks:strategist` with `skills/routines/workflows/interview.md`, which produces a `ROUTINE.md` draft; the chief of staff registers it after approval. This is not a suggestion — it fires deterministically on pattern match.

## Trigger Patterns

Match is case-insensitive. Any single match is sufficient to trigger.

**Time-based recurrence**
- `every day`, `every week`, `every month`, `every hour`, `every N minutes/hours/days`
- `daily`, `weekly`, `monthly`, `hourly`, `nightly`
- `schedule`, `scheduled`, `on a schedule`, `recurring`, `recurrence`
- `cron`, `cron job`, `cronjob`
- `periodic`, `periodically`, `at midnight`, `at noon`, `every morning`, `every night`

**Background work**
- `background job`, `background task`, `background process`
- `background sync`, `sync every`, `auto-sync`
- `batch job`, `batch process`, `batch run`
- `queue`, `worker`, `job runner`

**Monitoring and alerting**
- `monitor`, `monitoring`, `watch for`, `detect when`, `alert when`, `notify when`
- `poll`, `polling`, `check every`, `ping every`
- `health check`, `uptime check`

**Automation and reporting**
- `automatic report`, `auto report`, `generate report every`
- `automated email`, `send email every`, `digest`
- `automated summary`, `weekly summary`, `daily summary`
- `auto-generate`, `auto-publish`, `auto-post`
- `trigger on schedule`, `time-based trigger`

## Loop Supersedes Schedule

If `.claude/rules/loops.md` trigger patterns ALSO match the same feature, **loops.md fires
instead**. Do NOT start the routines interview when a loop signal is present — the
loop-designer handles the automation layer (in-session `CronCreate` for loop iterations)
internally.

## Required Behavior

When a trigger pattern is matched (and NO loop signal from `loops.md` is present):

1. **Do not skip, do not suggest** — start the routines interview directly
2. Before writing PLAN.md, dispatch the strategist with the interview workflow. The planner
   is a sub-agent and cannot dispatch, so it returns this to the chief of staff (or the
   orchestrating skill), which dispatches:

```
Agent(
  subagent_type="cks:<strategist>",   # cks:strategist once agents/strategist.md exists; until then the strategist row of skills/chief-of-staff/references/roster.md
  prompt="
    Routine intake per skills/routines/workflows/interview.md.
    Feature being planned: {feature name and description from CONTEXT.md}
    Scheduling trigger detected: {matched pattern}
    Interview the user; return the ROUTINE.md draft, references/<slug>-sources.md and the
    DECISION REQUIRED block. Do not create a trigger.
  "
)
```

3. Wait for the interview to complete; the chief of staff registers the profile after
   approval (`skills/routines/workflows/register.md`) — a gated action, never done by the planner
4. Reference the profile path `.routines/<slug>/ROUTINE.md` and its `trigger_id` in the
   PLAN.md Risk Notes section (`trigger_id` may still be empty if registration is pending — say so)

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The scheduling might not be needed yet" | Pattern matched = it's needed. Defer setup only if user explicitly says so after being prompted. |
| "I'll mention it as a suggestion" | The rule mandates invocation, not a suggestion. Start the interview. |
| "A CronCreate is faster than a routine" | Session-bound; it dies with the process. Routines are Claude Code Remote triggers with a profile in HQ (`skills/routines/`). |
| "It's a small feature, schedule can come later" | Later never comes. Wire it during planning when the context is fresh. |
| "The user didn't explicitly ask for a cron job" | Scheduling signals in feature descriptions are implicit requirements. Surface them now. |
