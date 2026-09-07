# Workflow: Threat Intel — CCCS advisories, diffed against what was already seen

Fetch Canadian Centre for Cyber Security alerts and advisories, diff against the seen
list, classify what is new, and draft the alerts. Sending to Telegram and updating the
seen list are gated (channel post + state write) and are routed by the chief of staff;
this workflow fetches, diffs, classifies, and writes the run report.

Setup (Telegram token, cadence, the Routine) is the operator's; see
`skills/routines/` once it ships.

## 1. Load state

Read `.agents/cccs-intel-monitor/state.json`.

- Missing → "No state file. The operator must run the CCCS monitor setup first." Stop.
- `active: false` → "CCCS intel monitor is paused." Stop.

Extract `seen_threat_ids`, `severity_threshold`, `telegram_chat_id`,
`telegram_token_env`. Never read or echo the token value — only the env var name.

`seed_only` (first run after setup): populate the seen list, draft nothing.

## 2. Fetch

The CCCS CLI ships with printing-press; check presence first:

```bash
command -v cccs >/dev/null 2>&1 || ls "$HOME"/printing-press/library/cccs/build/cccs 2>/dev/null
```

Absent → `▶ ACTION REQUIRED` with
`Run: npx -y @mvanhorn/printing-press-library install cccs --cli-only`, then stop.

```bash
cccs list-threats --json --agent 2>&1
```

Parse the JSON. On error, record it in the run report and stop cleanly — a Routine retries
next cycle.

## 3. Diff

`new_threats` = fetched threats whose title is not in `seen_threat_ids`. Never skip the
dedup — duplicate alerts destroy trust in the monitor.

## 4. Classify

| type | severity |
|---|---|
| `alert` | 🚨 CRITICAL |
| `advisory` | ⚠️ HIGH |
| `bulletin` | 📋 MEDIUM |
| unknown | 📢 INFO |

Filter by `severity_threshold`: MEDIUM sends all three, HIGH skips bulletins, CRITICAL
alerts only.

## 5. Draft alerts (not sent here)

One block per new threat, CRITICAL → HIGH → MEDIUM, summary cut to 200 chars:

```
{emoji} CCCS {SEVERITY}
*{title}*
📅 {published_date}
{summary_200}
🔗 {url}
```

## 6. Run report

Write `.research/threat-intel/{YYYY-MM-DD}.md`:

```markdown
# CCCS Intel — {date}

## Summary
- Threats fetched: {N} · New: {N} · Alerts drafted: {N} (or "0 — seed run")
- Threshold: {severity_threshold}

## New Threats
| Severity | Title | Type | Published | URL |
|---|---|---|---|---|

## Already Seen (skipped)
{count}

## Errors
{fetch errors, or "None"}

## Updated seen list
{all fetched titles merged with the previous list, no duplicates}
```

Always written, even on an error run.

## 7. Return

`GATED:` the Telegram send (chat id, env var name, drafted blocks) and the `state.json`
update (`seen_threat_ids`, `last_run`) for the chief of staff to route to the operator.
