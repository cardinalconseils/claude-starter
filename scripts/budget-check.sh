#!/bin/bash
# scripts/budget-check.sh — spend vs .finops/BUDGET.md ceiling, called by budget-guard.sh
# before every Agent dispatch. Spend = this project's dispatch traces (cost_usd) plus the
# HQ ledger's booked api lines for the venture and period. ≥80% warns once per session,
# ≥100% blocks the way destructive-op-guard.sh does: reason on stderr, exit 2 (the
# documented PreToolUse block); the JSON decision is echoed on stdout as well.
# No BUDGET.md or an override flag → silent exit 0. Never exits non-zero for any other reason.
[ -f ".cks/budget-override" ] && exit 0
command -v python3 >/dev/null 2>&1 || exit 0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
[ -f "$SCRIPT_DIR/hq-path.sh" ] && . "$SCRIPT_DIR/hq-path.sh"

BUDGET_FILE=".finops/BUDGET.md"
[ -f "$BUDGET_FILE" ] || BUDGET_FILE="$(cks_hq_root 2>/dev/null)/.finops/BUDGET.md"
[ -f "$BUDGET_FILE" ] || exit 0
LEDGER="$(cks_finops_dir 2>/dev/null)/ledger.jsonl"
SID=$(cat .prd/logs/.current_session_id 2>/dev/null)

python3 -c "$(cat <<'PY'
import sys, json, re, glob, os, datetime
budget_path, ledger_path, sid = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    text = open(budget_path, encoding='utf-8', errors='replace').read()
except Exception:
    sys.exit(0)

def bullet(label, pattern):
    m = re.search(r'^- \*\*' + label + r':\*\*\s*(' + pattern + ')', text, re.I | re.M)
    return m.group(1) if m else ''

try:
    ceiling = float(bullet('Monthly ceiling', r'[0-9]+(?:\.[0-9]+)?'))
except Exception:
    sys.exit(0)
if ceiling <= 0:
    sys.exit(0)
currency = (bullet('Currency', r'[A-Za-z]{3}') or 'USD').upper()
try:
    fx = float(bullet('FX to USD', r'[0-9]+(?:\.[0-9]+)?') or 1.0)
except Exception:
    fx = 1.0
fx = fx if fx > 0 else 1.0
period = bullet('Period', r'[0-9]{4}-[0-9]{2}') or datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m')
venture = bullet('Venture', r'[A-Za-z0-9_.-]+')
ceiling_usd = ceiling / fx

spend = 0.0
for path in glob.glob('.prd/logs/agents/*.jsonl'):
    try:
        for line in open(path, encoding='utf-8', errors='replace'):
            try:
                r = json.loads(line)
            except Exception:
                continue
            if isinstance(r, dict) and str(r.get('ts', '')).startswith(period):
                spend += float(r.get('cost_usd') or 0)
    except Exception:
        pass
try:
    for line in open(ledger_path, encoding='utf-8', errors='replace'):
        try:
            r = json.loads(line)
        except Exception:
            continue
        if not isinstance(r, dict) or r.get('category') != 'api' or r.get('period') != period:
            continue
        if r.get('kind', 'cost') != 'cost' or (venture and r.get('venture') != venture):
            continue
        # cost-audit books this venture's trace sums into the ledger; those lines are the
        # traces already counted above, so skipping them avoids counting the same spend twice.
        if venture and str(r.get('source', '')).startswith('scripts/cost-report.sh'):
            continue
        amt = float(r.get('amount') or 0)
        spend += amt if str(r.get('currency', 'USD')).upper() == 'USD' else amt / fx
except Exception:
    pass

pct = int(spend * 100 / ceiling_usd)
summary = 'API spend %.2f USD of %.2f USD ceiling (%s %s, period %s) = %d%%' % (spend, ceiling_usd, ceiling, currency, period, pct)
if pct >= 100:
    reason = ('━' * 48 + '\n▶ ACTION REQUIRED\n' + '━' * 48 +
              '\nRun:    raise \"- **Monthly ceiling:**\" in ' + budget_path + ', or run: touch .cks/budget-override'
              '\nWhy:    ' + summary + ' — agent dispatches are paused at 100% of the budget.'
              '\nThen:   continue — re-run the dispatch that was blocked.\n' + '━' * 48)
    print(json.dumps({'decision': 'block', 'reason': reason}))
    sys.stderr.write(reason + '\n')
    sys.exit(2)
if pct >= 80:
    marker = '.cks/.budget-warned-' + period
    try:
        already = open(marker).read().strip() == sid
    except Exception:
        already = False
    if not already:
        try:
            os.makedirs('.cks', exist_ok=True)
            open(marker, 'w').write(sid)
        except Exception:
            pass
        sys.stderr.write('Budget warning: ' + summary + ' — dispatches block at 100%.\n')
sys.exit(0)
PY
)" "$BUDGET_FILE" "$LEDGER" "$SID"
