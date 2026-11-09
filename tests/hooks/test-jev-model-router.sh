#!/bin/bash
# jev-model-router.sh only rewrites tool_input.model when Jev, called over HTTP, says
# it is safe and cheaper — and never touches the call at all when disabled, unkeyed,
# already-explicit, or exempt. A local stdlib mock server stands in for api.typesafe.ai.
# Usage: bash tests/hooks/test-jev-model-router.sh [path/to/jev-model-router.sh]
# Exit 0 = all pass.

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
HANDLER="${1:-$ROOT/hooks/handlers/jev-model-router.sh}"
HANDLER=$(cd "$(dirname "$HANDLER")" && pwd)/$(basename "$HANDLER")
[ -f "$HANDLER" ] || { echo "FAIL: handler not found: $HANDLER"; exit 1; }
command -v python3 >/dev/null 2>&1 && command -v jq >/dev/null 2>&1 \
  || { echo "FAIL: python3 and jq are required"; exit 1; }

TMPROOT=$(mktemp -d "${TMPDIR:-/tmp}/jev-router-test-XXXXXX")
ISOLATED_HOME="$TMPROOT/home"
mkdir -p "$ISOLATED_HOME" "$TMPROOT/logs" "$TMPROOT/cwd"

# ── mock TypeSafe server ────────────────────────────────────────────────────
CTRL="$TMPROOT/ctrl.json"
COUNTER="$TMPROOT/calls.log"
: > "$COUNTER"
echo '{"status":200,"answers":{"tier":{"choice":"haiku","confidence":0.9,"probabilities":{}},"high_stakes":{"noul":0.1}},"usage":{}}' > "$CTRL"

MOCK="$TMPROOT/mock_server.py"
cat > "$MOCK" <<'PY'
import http.server, json, socketserver, sys, time

port, ctrl_path, counter_path = int(sys.argv[1]), sys.argv[2], sys.argv[3]

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def do_POST(self):
        try:
            with open(counter_path, "a") as f:
                f.write("1\n")
        except Exception:
            pass
        length = int(self.headers.get("Content-Length", 0) or 0)
        self.rfile.read(length)
        try:
            ctrl = json.load(open(ctrl_path))
        except Exception:
            ctrl = {}
        sleep_s = ctrl.get("sleep", 0)
        if sleep_s:
            time.sleep(sleep_s)
        status = ctrl.get("status", 200)
        if status == 200:
            body = {
                "model": "jev-latest",
                "answers": ctrl.get("answers", {}),
                "usage": ctrl.get("usage", {"input_tokens": 0, "output_tokens": 0}),
            }
        else:
            body = {"error": "mock"}
        data = json.dumps(body).encode("utf-8")
        try:
            self.send_response(status)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
        except Exception:
            pass

class Server(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True

Server(("127.0.0.1", port), Handler).serve_forever()
PY

PORT=$(python3 - <<'PY'
import socket
s = socket.socket()
s.bind(("127.0.0.1", 0))
print(s.getsockname()[1])
s.close()
PY
)

python3 "$MOCK" "$PORT" "$CTRL" "$COUNTER" &
SERVER_PID=$!
cleanup() { kill "$SERVER_PID" 2>/dev/null; rm -rf "$TMPROOT"; }
trap cleanup EXIT

for _ in $(seq 1 50); do
  curl -s -o /dev/null "http://127.0.0.1:$PORT/" 2>/dev/null && break
  sleep 0.1
done

BASE_URL="http://127.0.0.1:$PORT"
fail=0

run_handler() {  # $1 payload json, remaining args KEY=VAL env pairs
  local payload="$1"; shift
  env -i PATH="$PATH" HOME="$ISOLATED_HOME" "$@" bash "$HANDLER" <<<"$payload"
}

calls_since() {  # $1 line count before -> prints delta
  local before="$1" after
  after=$(wc -l < "$COUNTER" | xargs)
  echo $((after - before))
}

payload() {  # $1 subagent_type, $2 extra tool_input json fragment (may be empty)
  local extra="${2:-}"
  printf '{"tool_name":"Agent","cwd":"%s","tool_input":{"subagent_type":"%s","description":"Do the thing","prompt":"Do the thing well"%s}}' \
    "$TMPROOT/cwd" "$1" "${extra:+,$extra}"
}

set_ctrl() { printf '%s' "$1" > "$CTRL"; }

# (a) disabled — no output, no log, no HTTP call
LOG="$TMPROOT/logs/a.jsonl"
BEFORE=$(wc -l < "$COUNTER" | xargs)
OUT=$(run_handler "$(payload cks:builder)" TYPESAFE_API_KEY=test CKS_JEV_LOG="$LOG" CKS_JEV_BASE_URL="$BASE_URL")
if [ -z "$OUT" ] && [ ! -s "$LOG" ] && [ "$(calls_since "$BEFORE")" = 0 ]; then
  echo "PASS a-disabled: no output, no log, no call"
else
  echo "FAIL a-disabled: out='$OUT' log_exists=$([ -s "$LOG" ] && echo yes || echo no) calls=$(calls_since "$BEFORE")"; fail=1
fi

# (b) no key — no output, no log, no HTTP call
LOG="$TMPROOT/logs/b.jsonl"
BEFORE=$(wc -l < "$COUNTER" | xargs)
OUT=$(run_handler "$(payload cks:builder)" CKS_JEV_ROUTING=on CKS_JEV_LOG="$LOG" CKS_JEV_BASE_URL="$BASE_URL")
if [ -z "$OUT" ] && [ ! -s "$LOG" ] && [ "$(calls_since "$BEFORE")" = 0 ]; then
  echo "PASS b-no-key: no output, no log, no call"
else
  echo "FAIL b-no-key: out='$OUT' log_exists=$([ -s "$LOG" ] && echo yes || echo no) calls=$(calls_since "$BEFORE")"; fail=1
fi

# (c) explicit model already set — no output, no log, no HTTP call
LOG="$TMPROOT/logs/c.jsonl"
BEFORE=$(wc -l < "$COUNTER" | xargs)
OUT=$(run_handler "$(payload cks:builder '"model":"opus"')" \
  CKS_JEV_ROUTING=on TYPESAFE_API_KEY=test CKS_JEV_LOG="$LOG" CKS_JEV_BASE_URL="$BASE_URL")
if [ -z "$OUT" ] && [ ! -s "$LOG" ] && [ "$(calls_since "$BEFORE")" = 0 ]; then
  echo "PASS c-explicit-model: no output, no log, no call"
else
  echo "FAIL c-explicit-model: out='$OUT' log_exists=$([ -s "$LOG" ] && echo yes || echo no) calls=$(calls_since "$BEFORE")"; fail=1
fi

# (d) cks:builder (default sonnet), Jev haiku conf 0.9 high_stakes 0.1 -> haiku, fields preserved
set_ctrl '{"status":200,"answers":{"tier":{"choice":"haiku","confidence":0.9,"probabilities":{"haiku":0.9,"sonnet":0.08,"opus":0.02}},"high_stakes":{"noul":0.1}},"usage":{"input_tokens":120,"output_tokens":15}}'
LOG="$TMPROOT/logs/d.jsonl"
IN=$(payload cks:builder '"extra_field":"keep-me"')
OUT=$(run_handler "$IN" CKS_JEV_ROUTING=on TYPESAFE_API_KEY=test CKS_JEV_LOG="$LOG" CKS_JEV_BASE_URL="$BASE_URL")
MODEL=$(printf '%s' "$OUT" | jq -r '.hookSpecificOutput.updatedInput.model' 2>/dev/null)
EXTRA=$(printf '%s' "$OUT" | jq -r '.hookSpecificOutput.updatedInput.extra_field' 2>/dev/null)
DESC=$(printf '%s' "$OUT" | jq -r '.hookSpecificOutput.updatedInput.description' 2>/dev/null)
REASON=$(tail -n 1 "$LOG" 2>/dev/null | jq -r '.reason' 2>/dev/null)
if [ "$MODEL" = "haiku" ] && [ "$EXTRA" = "keep-me" ] && [ "$DESC" = "Do the thing" ] && [ "$REASON" = "downgraded" ]; then
  echo "PASS d-downgrade: model=haiku, fields preserved, reason=downgraded"
else
  echo "FAIL d-downgrade: model=$MODEL extra=$EXTRA desc=$DESC reason=$REASON out=$OUT"; fail=1
fi

# (e) high_stakes 0.8 -> no output, reason high_stakes
set_ctrl '{"status":200,"answers":{"tier":{"choice":"haiku","confidence":0.9,"probabilities":{}},"high_stakes":{"noul":0.8}},"usage":{}}'
LOG="$TMPROOT/logs/e.jsonl"
OUT=$(run_handler "$(payload cks:builder)" CKS_JEV_ROUTING=on TYPESAFE_API_KEY=test CKS_JEV_LOG="$LOG" CKS_JEV_BASE_URL="$BASE_URL")
REASON=$(tail -n 1 "$LOG" 2>/dev/null | jq -r '.reason' 2>/dev/null)
if [ -z "$OUT" ] && [ "$REASON" = "high_stakes" ]; then
  echo "PASS e-high-stakes: no output, reason=high_stakes"
else
  echo "FAIL e-high-stakes: out='$OUT' reason=$REASON"; fail=1
fi

# (f) confidence 0.4 -> no output, reason low_confidence
set_ctrl '{"status":200,"answers":{"tier":{"choice":"haiku","confidence":0.4,"probabilities":{}},"high_stakes":{"noul":0.1}},"usage":{}}'
LOG="$TMPROOT/logs/f.jsonl"
OUT=$(run_handler "$(payload cks:builder)" CKS_JEV_ROUTING=on TYPESAFE_API_KEY=test CKS_JEV_LOG="$LOG" CKS_JEV_BASE_URL="$BASE_URL")
REASON=$(tail -n 1 "$LOG" 2>/dev/null | jq -r '.reason' 2>/dev/null)
if [ -z "$OUT" ] && [ "$REASON" = "low_confidence" ]; then
  echo "PASS f-low-confidence: no output, reason=low_confidence"
else
  echo "FAIL f-low-confidence: out='$OUT' reason=$REASON"; fail=1
fi

# (g) cks:writer (default haiku) with Jev opus -> upgrade_blocked, no output
set_ctrl '{"status":200,"answers":{"tier":{"choice":"opus","confidence":0.9,"probabilities":{}},"high_stakes":{"noul":0.1}},"usage":{}}'
LOG="$TMPROOT/logs/g.jsonl"
OUT=$(run_handler "$(payload cks:writer)" CKS_JEV_ROUTING=on TYPESAFE_API_KEY=test CKS_JEV_LOG="$LOG" CKS_JEV_BASE_URL="$BASE_URL")
REASON=$(tail -n 1 "$LOG" 2>/dev/null | jq -r '.reason' 2>/dev/null)
if [ -z "$OUT" ] && [ "$REASON" = "upgrade_blocked" ]; then
  echo "PASS g-upgrade-blocked: no output, reason=upgrade_blocked"
else
  echo "FAIL g-upgrade-blocked: out='$OUT' reason=$REASON"; fail=1
fi

# (h) same as (g) with CKS_JEV_ALLOW_UPGRADE=1 -> opus
LOG="$TMPROOT/logs/h.jsonl"
OUT=$(run_handler "$(payload cks:writer)" CKS_JEV_ROUTING=on TYPESAFE_API_KEY=test CKS_JEV_LOG="$LOG" \
  CKS_JEV_BASE_URL="$BASE_URL" CKS_JEV_ALLOW_UPGRADE=1)
MODEL=$(printf '%s' "$OUT" | jq -r '.hookSpecificOutput.updatedInput.model' 2>/dev/null)
REASON=$(tail -n 1 "$LOG" 2>/dev/null | jq -r '.reason' 2>/dev/null)
if [ "$MODEL" = "opus" ] && [ "$REASON" = "upgraded" ]; then
  echo "PASS h-allow-upgrade: model=opus, reason=upgraded"
else
  echo "FAIL h-allow-upgrade: model=$MODEL reason=$REASON out=$OUT"; fail=1
fi

# (i) exempt cks:chief-of-staff — no output, no log, no HTTP call
LOG="$TMPROOT/logs/i.jsonl"
BEFORE=$(wc -l < "$COUNTER" | xargs)
OUT=$(run_handler "$(payload cks:chief-of-staff)" CKS_JEV_ROUTING=on TYPESAFE_API_KEY=test CKS_JEV_LOG="$LOG" CKS_JEV_BASE_URL="$BASE_URL")
if [ -z "$OUT" ] && [ ! -s "$LOG" ] && [ "$(calls_since "$BEFORE")" = 0 ]; then
  echo "PASS i-exempt: no output, no log, no call made"
else
  echo "FAIL i-exempt: out='$OUT' log_exists=$([ -s "$LOG" ] && echo yes || echo no) calls=$(calls_since "$BEFORE")"; fail=1
fi

# (j) general-purpose (unknown role) with Jev sonnet -> emits sonnet
set_ctrl '{"status":200,"answers":{"tier":{"choice":"sonnet","confidence":0.85,"probabilities":{}},"high_stakes":{"noul":0.1}},"usage":{"input_tokens":10,"output_tokens":5}}'
LOG="$TMPROOT/logs/j.jsonl"
OUT=$(run_handler "$(payload general-purpose)" CKS_JEV_ROUTING=on TYPESAFE_API_KEY=test CKS_JEV_LOG="$LOG" CKS_JEV_BASE_URL="$BASE_URL")
MODEL=$(printf '%s' "$OUT" | jq -r '.hookSpecificOutput.updatedInput.model' 2>/dev/null)
if [ "$MODEL" = "sonnet" ]; then
  echo "PASS j-unknown-role: model=sonnet emitted"
else
  echo "FAIL j-unknown-role: model=$MODEL out=$OUT"; fail=1
fi

# (k) mock returns 500 — no output, fail_open
set_ctrl '{"status":500}'
LOG="$TMPROOT/logs/k.jsonl"
OUT=$(run_handler "$(payload cks:builder)" CKS_JEV_ROUTING=on TYPESAFE_API_KEY=test CKS_JEV_LOG="$LOG" CKS_JEV_BASE_URL="$BASE_URL")
REASON=$(tail -n 1 "$LOG" 2>/dev/null | jq -r '.reason' 2>/dev/null)
if [ -z "$OUT" ] && case "$REASON" in fail_open:*) true;; *) false;; esac; then
  echo "PASS k-http-500: no output, reason=$REASON"
else
  echo "FAIL k-http-500: out='$OUT' reason=$REASON"; fail=1
fi

# (l) mock sleeps past CKS_JEV_TIMEOUT=1 — no output, fail_open, returns within ~3s
set_ctrl '{"status":200,"sleep":3,"answers":{"tier":{"choice":"haiku","confidence":0.9,"probabilities":{}},"high_stakes":{"noul":0.1}},"usage":{}}'
LOG="$TMPROOT/logs/l.jsonl"
START=$(date +%s)
OUT=$(run_handler "$(payload cks:builder)" CKS_JEV_ROUTING=on TYPESAFE_API_KEY=test CKS_JEV_LOG="$LOG" \
  CKS_JEV_BASE_URL="$BASE_URL" CKS_JEV_TIMEOUT=1)
ELAPSED=$(( $(date +%s) - START ))
REASON=$(tail -n 1 "$LOG" 2>/dev/null | jq -r '.reason' 2>/dev/null)
if [ -z "$OUT" ] && case "$REASON" in fail_open:*) true;; *) false;; esac && [ "$ELAPSED" -le 6 ]; then
  echo "PASS l-timeout: no output, reason=$REASON, elapsed=${ELAPSED}s"
else
  echo "FAIL l-timeout: out='$OUT' reason=$REASON elapsed=${ELAPSED}s"; fail=1
fi

# (m) top-level session_id + tool_use_id on the payload -> both land in the log line
set_ctrl '{"status":200,"answers":{"tier":{"choice":"haiku","confidence":0.9,"probabilities":{}},"high_stakes":{"noul":0.1}},"usage":{}}'
LOG="$TMPROOT/logs/m.jsonl"
IN=$(printf '{"tool_name":"Agent","cwd":"%s","session_id":"s-test","tool_use_id":"toolu_test","tool_input":{"subagent_type":"cks:builder","description":"Do the thing","prompt":"Do the thing well"}}' "$TMPROOT/cwd")
OUT=$(run_handler "$IN" CKS_JEV_ROUTING=on TYPESAFE_API_KEY=test CKS_JEV_LOG="$LOG" CKS_JEV_BASE_URL="$BASE_URL")
LINE=$(tail -n 1 "$LOG" 2>/dev/null)
SID=$(printf '%s' "$LINE" | jq -r '.session_id' 2>/dev/null)
TID=$(printf '%s' "$LINE" | jq -r '.tool_use_id' 2>/dev/null)
if [ "$SID" = "s-test" ] && [ "$TID" = "toolu_test" ]; then
  echo "PASS m-join-keys: session_id=s-test tool_use_id=toolu_test in log"
else
  echo "FAIL m-join-keys: session_id=$SID tool_use_id=$TID line=$LINE"; fail=1
fi

exit "$fail"
