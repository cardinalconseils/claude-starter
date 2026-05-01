# LangSmith Triage Workflow

Authenticate → list runs → find outliers → report.

## Prerequisites

- `LANGCHAIN_API_KEY` env var set

If not set:
- Report: "LangSmith is not configured. Set `LANGCHAIN_API_KEY` to enable trace analysis."
- Suggest: "Get an API key at https://smith.langchain.com under Settings → API Keys."

## Step 1: Verify Authentication

```bash
echo "LANGCHAIN_API_KEY=${LANGCHAIN_API_KEY:+set (${#LANGCHAIN_API_KEY} chars)}"
```

Test with a projects listing:
```
GET https://api.smith.langchain.com/api/v1/projects
Headers:
  x-api-key: ${LANGCHAIN_API_KEY}
```

## Step 2: Discover Projects

```
GET https://api.smith.langchain.com/api/v1/projects
```

Match project name to the current repo or the user-specified app name.

## Step 3: List Recent Runs

```
GET https://api.smith.langchain.com/api/v1/runs?project_name={project}&limit=50&order=desc
```

Key fields per run:
- `id` — run ID for drill-in
- `name` — run/chain name
- `start_time`, `end_time` — for latency calculation
- `error` — non-null if run failed
- `total_tokens`, `prompt_tokens`, `completion_tokens` — token usage
- `total_cost` — estimated cost in USD

## Step 4: Find Outliers

**Errors:** Runs where `error` is non-null:
```
GET https://api.smith.langchain.com/api/v1/runs?project_name={project}&error=true&limit=25
```

**Latency outliers (p99):** Sort by duration descending:
```
GET https://api.smith.langchain.com/api/v1/runs?project_name={project}&sort=desc&order_by=end_time&limit=50
```
Calculate `(end_time - start_time)` in ms for each run. Flag runs > 2x the median.

**Token cost anomalies:** Flag runs where `total_cost > {threshold}`. Default threshold: 3x the median cost for the same run name.

## Step 5: Drill Into a Specific Run

```
GET https://api.smith.langchain.com/api/v1/runs/{run-id}
```

From the response, extract:
- `inputs` — what was sent to the model
- `outputs` — what the model returned
- `child_runs` — tool calls and sub-chain executions
- `error` — full error message and traceback if failed
- Latency = `end_time - start_time`
- `prompt_tokens`, `completion_tokens`, `total_cost`

## Step 6: Report

```
LANGSMITH TRIAGE REPORT
━━━━━━━━━━━━━━━━━━━━━━━
Project:   {project-name}
Runs analyzed: {N} (last {window})
Errors:    {N}
p99 latency: {Xms}
Avg cost/run: ${X}

ERRORS
━━━━━━
Run {id} ({name}): {error message} at {timestamp}
  Input: {truncated input}

LATENCY OUTLIERS
━━━━━━━━━━━━━━━━
Run {id}: {Xms} (median: {Yms})

COST ANOMALIES
━━━━━━━━━━━━━━
Run {id} ({name}): ${X} (avg: ${Y})

SUGGESTED NEXT STEPS
━━━━━━━━━━━━━━━━━━━━
/cks:debug "error text..."   → trace root cause in prompt/chain code
```
