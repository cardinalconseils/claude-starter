#!/bin/bash
# scripts/agent-trace.sh — turn one SubagentStop payload (stdin) into a line in
# .prd/logs/agents/<role>.jsonl. SubagentStop field names differ across Claude Code
# versions, so every lookup is optional with an explicit default. Exit 0 always.
# Token counts and cost come from the sub-agent transcript; cost is list price from
# skills/finops/references/model-prices.json — an estimate, never a bill.
command -v python3 >/dev/null 2>&1 || exit 0
[ -d ".prd/logs" ] || exit 0
SID=$(cat .prd/logs/.current_session_id 2>/dev/null)
PRICES="$(dirname "$0")/../skills/finops/references/model-prices.json"

python3 -c "$(cat <<'PY'
import sys, json, os, datetime
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
if not isinstance(d, dict):
    d = {}
role = str(d.get('agent_type') or d.get('subagent_type') or 'unknown')
sid = sys.argv[1] or str(d.get('session_id') or '')
transcript = str(d.get('agent_transcript_path') or d.get('transcript_path') or '')

try:
    prices = json.load(open(sys.argv[2]))
except Exception:
    prices = {}

def parse_ts(s):
    try:
        return datetime.datetime.fromisoformat(str(s).replace('Z', '+00:00')).timestamp()
    except Exception:
        return None

# Streaming writes several assistant lines per message with the same cumulative usage,
# so usage is keyed by message.id and the last line seen per id wins.
usage_by_id, model, last, first_ts, last_ts = {}, '', '', None, None
try:
    with open(transcript, 'rb') as f:
        for raw in f:
            line = raw.decode('utf-8', 'replace')
            try:
                obj = json.loads(line)
            except Exception:
                obj = None
            if not isinstance(obj, dict):
                continue
            ts = parse_ts(obj.get('timestamp'))
            if ts is not None:
                first_ts = ts if first_ts is None else first_ts
                last_ts = ts
            if obj.get('type') != 'assistant':
                continue
            last = line
            msg = obj.get('message') or {}
            if not isinstance(msg, dict):
                continue
            model = str(msg.get('model') or model)
            u = msg.get('usage') or {}
            if isinstance(u, dict):
                usage_by_id[str(msg.get('id') or len(usage_by_id))] = u
except Exception:
    pass

def n(u, k):
    try:
        return int(u.get(k) or 0)
    except Exception:
        return 0

tin = sum(n(u, 'input_tokens') for u in usage_by_id.values())
tout = sum(n(u, 'output_tokens') for u in usage_by_id.values())
tcr = sum(n(u, 'cache_read_input_tokens') for u in usage_by_id.values())
tcw = sum(n(u, 'cache_creation_input_tokens') for u in usage_by_id.values())

price, source = None, 'unknown'
models = prices.get('models') or {}
tiers = prices.get('tiers') or {}
if model in models:
    price, source = models[model], 'model'
else:
    parts = model.split('-')
    fam = parts[1] if len(parts) > 1 and parts[0] == 'claude' else ''
    if fam in tiers:
        price, source = tiers[fam], 'tier-fallback'
cost = 0.0
if price:
    pi, po = float(price.get('input') or 0), float(price.get('output') or 0)
    cw = float(prices.get('cache_write_multiplier') or 1.25)
    cr = float(prices.get('cache_read_multiplier') or 0.1)
    cost = (tin * pi + tout * po + tcw * pi * cw + tcr * pi * cr) / 1e6

low = last.lower()
failed = 'outcome=fail' in low or 'outcome=error' in low or '"is_error": true' in low or '"is_error":true' in low
rec = {
    'ts': datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.000Z'),
    'role': role,
    'agent_id': str(d.get('agent_id') or ''),
    'outcome': 'error' if failed else 'completed',
    'session_id': sid,
    'transcript': os.path.basename(transcript) if transcript else '',
    'model': model,
    'tokens_in': tin,
    'tokens_out': tout,
    'tokens_cache_read': tcr,
    'tokens_cache_write': tcw,
    'cost_usd': round(cost, 6),
    'duration_ms': int((last_ts - first_ts) * 1000) if first_ts is not None and last_ts is not None else 0,
    'price_source': source,
}
os.makedirs('.prd/logs/agents', exist_ok=True)
with open(os.path.join('.prd/logs/agents', role.replace('/', '_') + '.jsonl'), 'a') as f:
    f.write(json.dumps(rec) + '\n')
PY
)" "$SID" "$PRICES" 2>/dev/null
exit 0
