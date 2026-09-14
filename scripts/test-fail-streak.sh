#!/bin/bash
# scripts/test-fail-streak.sh — count consecutive failing test runs, called by
# test-fail-guard.sh. PostToolUse payloads (tool_response present) record; PreToolUse
# payloads check. Two consecutive failures block the next test run the way
# destructive-op-guard.sh does — reason on stderr, exit 2 (the documented PreToolUse
# block), JSON decision echoed on stdout: confidence.md's anti-loop rule escalates a
# 2-FAIL gate, it does not retry. Non-test commands never block.
# Failure detection is best-effort — exit_code, then error, then a failure summary in
# the output. Streak file: .cks/.test-fail-streak = "<count>\n<last command>".
command -v python3 >/dev/null 2>&1 || exit 0

python3 -c "$(cat <<'PY'
import sys, json, re, os
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
if not isinstance(d, dict):
    sys.exit(0)
ti = d.get('tool_input') if isinstance(d.get('tool_input'), dict) else {}
cmd = str(ti.get('command') or d.get('command') or '')
TEST_RE = re.compile(r'\b(npm|pnpm|yarn|bun) (run )?test\b|\bpytest\b|\bvitest\b|\bjest\b|\bgo test\b|\bcargo test\b|\bbash scripts/test-integrity\.sh\b')
if not TEST_RE.search(cmd):
    sys.exit(0)
streak_path = '.cks/.test-fail-streak'
event = str(d.get('hook_event_name') or ('PostToolUse' if 'tool_response' in d else 'PreToolUse'))

if event == 'PostToolUse':
    r = d.get('tool_response')
    r = r if isinstance(r, dict) else {}
    if r.get('exit_code') is not None:
        failed = str(r.get('exit_code')) not in ('0', 'None')
    elif r.get('error'):
        failed = True
    else:
        out = str(r.get('stdout') or '') + '\n' + str(r.get('stderr') or '')
        failed = re.search(r'FAILED|failed|Tests:.*failed|✗|✖', out) is not None
    count = 0
    if failed:
        try:
            count = int(open(streak_path).read().splitlines()[0]) + 1
        except Exception:
            count = 1
    try:
        os.makedirs('.cks', exist_ok=True)
        open(streak_path, 'w').write('%d\n%s\n' % (count, cmd.replace('\n', ' ')[:200]))
    except Exception:
        pass
    sys.exit(0)

try:
    count = int(open(streak_path).read().splitlines()[0])
except Exception:
    count = 0
if count < 2:
    sys.exit(0)
reason = ('━' * 48 + '\n▶ ACTION REQUIRED\n' + '━' * 48 +
          '\nRun:    rm .cks/.test-fail-streak — after reading the failure output and fixing the root cause'
          '\nWhy:    %d consecutive failing test runs — per skills/prd/templates/confidence.md a 2-FAIL gate escalates, it does not retry.'
          '\nThen:   re-run the tests.\n' % count + '━' * 48)
print(json.dumps({'decision': 'block', 'reason': reason}))
sys.stderr.write(reason + '\n')
sys.exit(2)
PY
)"
