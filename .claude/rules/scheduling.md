# Scheduling Rules

## Mandatory Behavior

When any feature description, CONTEXT.md, PLAN.md, or user message contains scheduling signals, the planner MUST dispatch the `cks:scheduler` agent BEFORE writing PLAN.md. This is not a suggestion — it fires deterministically on pattern match.

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
instead**. Do NOT dispatch `cks:scheduler` when a loop signal is present — the loop-designer
handles the automation layer (CronCreate) internally.

## Required Behavior

When a trigger pattern is matched (and NO loop signal from `loops.md` is present):

1. **Do not skip, do not suggest** — invoke the scheduler directly
2. Dispatch `cks:scheduler` agent before writing PLAN.md:

```
Agent(
  subagent_type="cks:scheduler",
  prompt="
    Feature being planned: {feature name and description from CONTEXT.md}
    Scheduling trigger detected: {matched pattern}
    Interview the user to configure the recurring agent.
    Save state to .agents/{feature-name}/state.json when done.
  "
)
```

3. Wait for the scheduler agent to complete before continuing with PLAN.md
4. Reference the registered routine ID in the PLAN.md Risk Notes section

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The scheduling might not be needed yet" | Pattern matched = it's needed. Defer setup only if user explicitly says so after being prompted. |
| "I'll mention it as a suggestion" | The rule mandates invocation, not a suggestion. Dispatch the agent. |
| "It's a small feature, schedule can come later" | Later never comes. Wire it during planning when the context is fresh. |
| "The user didn't explicitly ask for a cron job" | Scheduling signals in feature descriptions are implicit requirements. Surface them now. |
