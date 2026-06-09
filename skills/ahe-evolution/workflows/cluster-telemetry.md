# Cluster Telemetry for Golden Case Candidates

## Enumerate Files

Find the 5 most recent session log files:

```bash
find .prd/logs/sessions -name "*.jsonl" 2>/dev/null | sort -r | head -5
```

If no files found: note "Telemetry: no session logs yet" and skip to governance signals.

## Read and Parse

Parse each JSONL file line by line:

```bash
while IFS= read -r line; do
  printf '%s\n' "$line" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d))" 2>/dev/null
done < {file}
```

Or with jq if available: `jq -c '.' {file}`

## Cluster Errors

Group records where `outcome=error` by `tool` field:

```bash
cat {files} | python3 -c "
import sys, json, collections
counts = collections.Counter()
for line in sys.stdin:
    try:
        d = json.loads(line)
        if d.get('outcome') == 'error':
            counts[d.get('tool','unknown')] += 1
    except: pass
for tool, count in counts.most_common():
    print(f'{count}\t{tool}')
"
```

## Detect Data Quality Issues

If `tool:"unknown"` accounts for > 90% of all records (not just errors):

Flag in Signal Summary:
> G3 tool-name resolution issue — field parsed as unknown. Telemetry error clustering is limited. Governance and harness-eval signals are primary.

This is a data quality note, NOT a blocker. Continue with governance and harness-eval signals.

## Rank Candidates

Score formula: `score = error_count × tool_risk_weight`

Tool risk weights:
- `Bash` = 3
- `Write` = 2
- `Edit` = 2
- `Agent` = 1
- all others = 1

Map tool name to likely hook handler:
- Bash errors → check `destructive-op-guard.sh`, `governance-log.sh`
- Write/Edit errors → check `post-tool-trace.sh`

## Skip Filter

Before finalizing candidates, check if the error pattern is already covered by an existing golden case:

```bash
find .harness-evals/golden/{hook-name} -name "input.json" 2>/dev/null | wc -l
```

If count > 0: review existing input.json files. If the error scenario is already represented, skip this candidate and note "covered by existing golden case."
