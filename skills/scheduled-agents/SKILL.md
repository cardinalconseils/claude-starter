---
name: scheduled-agents
description: >
  Recurring/scheduled agent patterns — analytics with memory of prior runs, sentiment
  monitoring with parallel fan-out, and asset generation from repo + brand assets.
  Use when setting up a CronCreate-based agent that runs autonomously on a cadence.
allowed-tools: Read, Write, Bash, Glob, Grep, WebSearch, WebFetch, Agent, CronCreate
---

# Scheduled Agents

## Overview

Scheduled agents run autonomously on a cadence, come back with results, and build on prior runs over time. Three patterns cover most recurring PM jobs. Each reads a state file for config, writes dated output, and updates the state file so the next run can build on it.

## Core Mechanic — State File + Dated Output

Every scheduled agent follows this loop:

```
1. Read .agents/{name}/state.json        ← config + last run's findings
2. Do the work (query, scrape, generate)
3. Write .agents/{name}/runs/{date}.md   ← this run's output
4. Update state.json last_run + summary  ← next run can diff against this
```

Memory comes from comparing current findings to `last_output` in state.json. The agent notes what's new, what changed, what's trending — not just raw data.

---

## Template 1 — Analytics Agent

### What it does
Queries a data source, surfaces outliers and trends, compares to prior run, reports what changed.

### Interview questions (ask these in Step 2)
1. "Where is your data? (Supabase, Postgres connection string, CSV, Google Sheets)"
2. "What do you want to track? (e.g. signups, churn, feature adoption, revenue)" — offer examples from project context
3. "What would make you act? (e.g. >10% drop in signups, any churn spike)" — threshold for a flagged finding

### State file template
```json
{
  "agent_name": "analytics",
  "template": "analytics",
  "config": {
    "data_source": "{connection or path}",
    "metrics": ["{metric1}", "{metric2}"],
    "alert_thresholds": { "{metric}": "{condition}" }
  },
  "last_run": null,
  "last_output": null
}
```

### Cron prompt template
```
Read .agents/analytics/state.json for config.
Query {data_source} for these metrics: {metrics}.
Compare to last_output — flag anything that crossed alert_thresholds or changed >10% week-over-week.
Write findings to .agents/analytics/runs/{today}.md with sections: Summary, Trends, Flags, Raw Numbers.
Update state.json: set last_run to today's date, last_output to a 3-sentence summary of key findings.
```

---

## Template 2 — Sentiment Monitoring Agent

### What it does
Fans out to multiple sources in parallel, collects brand/product mentions, synthesizes sentiment, flags spikes.

### Interview questions (ask these in Step 2)
1. "What sources should I monitor? (Reddit, Twitter/X, G2, Hacker News, Product Hunt, Slack community)" — multi-select
2. "What search terms? (product name, competitors, category keywords)"
3. "What matters most to flag? (negative sentiment, feature requests, competitor mentions, churn signals)"

### State file template
```json
{
  "agent_name": "sentiment",
  "template": "sentiment",
  "config": {
    "sources": ["{source1}", "{source2}"],
    "search_terms": ["{term1}", "{term2}"],
    "flag_on": ["{negative_sentiment}", "{competitor_mention}"]
  },
  "last_run": null,
  "last_output": null
}
```

### Cron prompt template
```
Read .agents/sentiment/state.json for config.
Fan out to these sources in parallel: {sources}. Search for: {search_terms}.
For each source: collect top mentions from the past 7 days.
Synthesize: overall sentiment score (positive/neutral/negative), top themes, flagged items matching {flag_on}.
Compare to last_output — note any new themes or sentiment shifts.
Write to .agents/sentiment/runs/{today}.md: Executive Summary, Sentiment by Source, Flagged Items, Notable Quotes.
Update state.json: last_run and last_output summary.
```

### Fan-out pattern
Dispatch one sub-agent per source concurrently (single Agent() message), collect results, synthesize:
```
Agent(subagent_type="cks:deep-researcher", prompt="Search {source1} for {terms}. Return top 10 mentions with sentiment label.")
Agent(subagent_type="cks:deep-researcher", prompt="Search {source2} for {terms}. Return top 10 mentions with sentiment label.")
```
Wait for both. Merge. Synthesize.

---

## Template 3 — Asset Generation Agent

### What it does
Generates a recurring deliverable (demo deck, weekly report, changelog digest, customer brief) from repo state, brand assets, and prior output.

### Interview questions (ask these in Step 2)
1. "What's the deliverable? (conference demo, weekly changelog digest, customer onboarding deck, competitive brief)"
2. "What should it read? (git history, PRD roadmap, brand file, specific docs)" — multi-select
3. "What format? (Markdown report, slide outline for Canva, PDF brief)"

### State file template
```json
{
  "agent_name": "assets",
  "template": "assets",
  "config": {
    "deliverable_type": "{deck|report|digest|brief}",
    "sources": ["{git}", "{prd}", "{brand}"],
    "output_format": "{markdown|slide-outline|pdf-brief}"
  },
  "last_run": null,
  "last_output": null
}
```

### Cron prompt template
```
Read .agents/assets/state.json for config.
Read sources: {sources}.
Generate {deliverable_type} in {output_format} format.
If last_output exists, diff against it — only surface what's new since last run.
Write to .agents/assets/runs/{today}.md.
Update state.json: last_run and last_output summary.
```

---

## Custom Template

For jobs that don't fit the three patterns above:

### Interview questions
1. "Describe the job in one sentence — what does it do?"
2. "What does it read to do the job? (data source, web pages, repo files)"
3. "What does it produce? (report, alert, file, message)"

Build the state file and cron prompt from the user's answers. Follow the same state-file + dated-output pattern.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll just run it manually each week" | You won't. The operational tail kills momentum. Automate it once. |
| "The data changes too much for a template" | The template is the shape. The data fills in each run. |
| "I don't need the state file — I'll remember last week" | Memory across runs is the entire value. Without state.json, it's a one-shot report. |
| "CronCreate will wake Claude up at 3am" | Crons run at the time you set. Set it for your working hours. |

## Verification

- [ ] State file exists at `.agents/{name}/state.json` before CronCreate is called
- [ ] Cron prompt references the state file path (not hardcoded values)
- [ ] Output path uses dated format: `.agents/{name}/runs/{YYYY-MM-DD}.md`
- [ ] State file has `last_run: null` on creation (not null string)
- [ ] User knows how to view runs: `ls .agents/{name}/runs/`
