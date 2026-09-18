#!/bin/bash
# scripts/cost-report.sh [--period YYYY-MM] [--by role|model|session] [--json]
# Sums the dispatch traces in ./.prd/logs/agents/*.jsonl (telemetry Layer 2) for one
# period. Local only: HQ ledgers are the finops role's job, this script feeds them.
# cost_usd is list price from model-prices.json — an estimate, not a bill. Exit 0 always.
command -v python3 >/dev/null 2>&1 || { echo "python3 required"; exit 0; }

python3 -c "$(cat <<'PY'
import sys, json, glob, datetime, collections
args = sys.argv[1:]
period = datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m')
by, as_json = 'role', False
i = 0
while i < len(args):
    a = args[i]
    if a == '--period' and i + 1 < len(args):
        period = args[i + 1]; i += 1
    elif a.startswith('--period='):
        period = a.split('=', 1)[1]
    elif a == '--by' and i + 1 < len(args):
        by = args[i + 1]; i += 1
    elif a.startswith('--by='):
        by = a.split('=', 1)[1]
    elif a == '--json':
        as_json = True
    i += 1
if by not in ('role', 'model', 'session'):
    by = 'role'
key_field = {'role': 'role', 'model': 'model', 'session': 'session_id'}[by]

rows = collections.OrderedDict()
for path in sorted(glob.glob('.prd/logs/agents/*.jsonl')):
    try:
        lines = open(path, encoding='utf-8', errors='replace').read().splitlines()
    except Exception:
        continue
    for line in lines:
        try:
            r = json.loads(line)
        except Exception:
            continue
        if not isinstance(r, dict) or not str(r.get('ts', '')).startswith(period):
            continue
        k = str(r.get(key_field) or '') or '(none)'
        row = rows.setdefault(k, {'key': k, 'dispatches': 0, 'tokens_in': 0, 'tokens_out': 0, 'cost_usd': 0.0})
        row['dispatches'] += 1
        # Lines written before Layer 2 shipped carry no token fields; they count as dispatches only.
        for f in ('tokens_in', 'tokens_out'):
            try:
                row[f] += int(r.get(f) or 0)
            except Exception:
                pass
        try:
            row['cost_usd'] += float(r.get('cost_usd') or 0)
        except Exception:
            pass

total = {'key': 'total', 'dispatches': 0, 'tokens_in': 0, 'tokens_out': 0, 'cost_usd': 0.0}
for row in rows.values():
    row['cost_usd'] = round(row['cost_usd'], 6)
    for f in ('dispatches', 'tokens_in', 'tokens_out', 'cost_usd'):
        total[f] += row[f]
total['cost_usd'] = round(total['cost_usd'], 6)
ordered = sorted(rows.values(), key=lambda r: -r['cost_usd'])

if as_json:
    print(json.dumps({'period': period, 'by': by, 'rows': ordered, 'total': total}))
    sys.exit(0)
if not ordered:
    print('no trace lines for ' + period)
    sys.exit(0)
w = max(len(r['key']) for r in ordered + [total])
fmt = '{:<' + str(w) + '}  {:>10}  {:>12}  {:>12}  {:>12}'
print('Cost report — ' + period + ' — by ' + by + ' (list-price estimate, USD)')
print(fmt.format(by, 'dispatches', 'tokens_in', 'tokens_out', 'cost_usd'))
for r in ordered + [total]:
    if r is total:
        print('-' * (w + 54))
    print(fmt.format(r['key'], r['dispatches'], r['tokens_in'], r['tokens_out'], '%.4f' % r['cost_usd']))
PY
)" "$@" 2>/dev/null
exit 0
