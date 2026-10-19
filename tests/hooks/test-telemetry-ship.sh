#!/bin/bash
# telemetry-ship.sh only POSTs to Supabase when CKS_TELEMETRY_SINK=supabase and a config
# is present; it queues on failure and never echoes the service key. A local stdlib mock
# server stands in for the Supabase REST endpoint, same pattern as test-jev-model-router.sh.
# Usage: bash tests/hooks/test-telemetry-ship.sh [path/to/telemetry-ship.sh]
# Exit 0 = all pass.

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
HANDLER="${1:-$ROOT/scripts/telemetry-ship.sh}"
HANDLER=$(cd "$(dirname "$HANDLER")" && pwd)/$(basename "$HANDLER")
DRAIN="$ROOT/scripts/control-plane-drain.sh"
[ -f "$HANDLER" ] || { echo "FAIL: handler not found: $HANDLER"; exit 1; }
command -v python3 >/dev/null 2>&1 && command -v curl >/dev/null 2>&1 \
  || { echo "FAIL: python3 and curl are required"; exit 1; }

TMPROOT=$(mktemp -d "${TMPDIR:-/tmp}/telemetry-ship-test-XXXXXX")
fail=0

# ── mock Supabase REST server ───────────────────────────────────────────────
CTRL="$TMPROOT/ctrl.json"
REQUESTS="$TMPROOT/requests.jsonl"
: > "$REQUESTS"
echo '{"status":201}' > "$CTRL"

MOCK="$TMPROOT/mock_server.py"
cat > "$MOCK" <<'PY'
import http.server, json, socketserver, sys

port, ctrl_path, req_path = int(sys.argv[1]), sys.argv[2], sys.argv[3]

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0) or 0)
        body = self.rfile.read(length).decode("utf-8", "replace")
        try:
            with open(req_path, "a") as f:
                f.write(json.dumps({"path": self.path, "body": body}) + "\n")
        except Exception:
            pass
        try:
            ctrl = json.load(open(ctrl_path))
        except Exception:
            ctrl = {}
        status = ctrl.get("status", 201)
        self.send_response(status)
        self.send_header("Content-Length", "0")
        self.end_headers()

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

python3 "$MOCK" "$PORT" "$CTRL" "$REQUESTS" &
SERVER_PID=$!
cleanup() { kill "$SERVER_PID" 2>/dev/null; rm -rf "$TMPROOT"; }
trap cleanup EXIT

for _ in $(seq 1 50); do
  curl -s -o /dev/null "http://127.0.0.1:$PORT/" 2>/dev/null
  [ -f "$REQUESTS" ] && break
  sleep 0.1
done

BASE_URL="http://127.0.0.1:$PORT"
# Not a real credential shape (no sk_/ghp_/xoxb- prefix) — a synthetic marker string
# so the test can grep for a leak without tripping the repo's own secret-pattern guards.
FAKE_KEY="telemetry-ship-test-marker-98765"

setup_project() {  # $1 dir -> writes a control-plane config pointing at the mock server
  mkdir -p "$1/.cks/control-plane"
  cat > "$1/.cks/control-plane/config.yaml" <<CFG
supabase_url: ${BASE_URL}
supabase_service_key: ${FAKE_KEY}
CFG
}

req_count() { wc -l < "$REQUESTS" 2>/dev/null | xargs; }

# (a) sink off — no request made, exit 0
DIR="$TMPROOT/a"; setup_project "$DIR"
BEFORE=$(req_count)
OUT=$(cd "$DIR" && env -u CKS_TELEMETRY_SINK bash "$HANDLER" tool '{"tool":"Bash","session_id":"s1"}' 2>&1)
RC=$?
if [ "$RC" = 0 ] && [ "$(req_count)" = "$BEFORE" ] && [ -z "$OUT" ]; then
  echo "PASS a-sink-off: no request, exit 0"
else
  echo "FAIL a-sink-off: rc=$RC requests_delta=$(( $(req_count) - BEFORE )) out='$OUT'"; fail=1
fi

# (b) sink on, server up — one POST to /rest/v1/events, body carries kind + dedupe_key,
# and the service key never appears in stdout or stderr
DIR="$TMPROOT/b"; setup_project "$DIR"
BEFORE=$(req_count)
OUT=$(cd "$DIR" && CKS_TELEMETRY_SINK=supabase bash "$HANDLER" tool '{"tool":"Bash","session_id":"s1","tool_use_id":"toolu_1"}' 2>&1)
RC=$?
LAST_REQ=$(tail -n 1 "$REQUESTS" 2>/dev/null)
PATH_OK=$(printf '%s' "$LAST_REQ" | python3 -c "import sys,json; print(json.load(sys.stdin)['path'].startswith('/rest/v1/events'))" 2>/dev/null)
BODY=$(printf '%s' "$LAST_REQ" | python3 -c "import sys,json; print(json.load(sys.stdin)['body'])" 2>/dev/null)
KIND_OK=$(printf '%s' "$BODY" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('kind')=='tool' and bool(d.get('dedupe_key')))" 2>/dev/null)
if [ "$RC" = 0 ] && [ "$(req_count)" = "$((BEFORE + 1))" ] && [ "$PATH_OK" = "True" ] \
  && [ "$KIND_OK" = "True" ] && ! printf '%s' "$OUT" | grep -q "$FAKE_KEY"; then
  echo "PASS b-sink-on: one POST to /rest/v1/events, kind+dedupe_key present, no key leaked"
else
  echo "FAIL b-sink-on: rc=$RC requests=$(req_count) path_ok=$PATH_OK kind_ok=$KIND_OK body=$BODY out='$OUT'"; fail=1
fi

# (c) server down — queue file written, exit 0
DIR="$TMPROOT/c"; mkdir -p "$DIR/.cks/control-plane"
cat > "$DIR/.cks/control-plane/config.yaml" <<CFG
supabase_url: http://127.0.0.1:1
supabase_service_key: ${FAKE_KEY}
CFG
OUT=$(cd "$DIR" && CKS_TELEMETRY_SINK=supabase timeout 10 bash "$HANDLER" tool '{"tool":"Bash","session_id":"s1"}' 2>&1)
RC=$?
QFILE=$(ls "$DIR/.cks/control-plane/sync-queue/"events-*.json 2>/dev/null | head -1)
if [ "$RC" = 0 ] && [ -n "$QFILE" ] && [ -s "$QFILE" ]; then
  echo "PASS c-server-down: queue file written, exit 0"
else
  echo "FAIL c-server-down: rc=$RC qfile='$QFILE'"; fail=1
fi

# (d) drain routes events-* queue files to /rest/v1/events with ignore-duplicates
DIR="$TMPROOT/d"; setup_project "$DIR"
mkdir -p "$DIR/.cks/control-plane/sync-queue"
printf '{"kind":"tool","dedupe_key":"abc123","payload":{}}' > "$DIR/.cks/control-plane/sync-queue/events-1-1.json"
BEFORE=$(req_count)
( cd "$DIR" && bash "$DRAIN" >/dev/null 2>&1 )
LAST_REQ=$(tail -n 1 "$REQUESTS" 2>/dev/null)
DRAIN_PATH_OK=$(printf '%s' "$LAST_REQ" | python3 -c "import sys,json; print(json.load(sys.stdin)['path'])" 2>/dev/null)
if [ "$(req_count)" = "$((BEFORE + 1))" ] && [ "$DRAIN_PATH_OK" = "/rest/v1/events?on_conflict=dedupe_key" ] \
  && [ ! -f "$DIR/.cks/control-plane/sync-queue/events-1-1.json" ]; then
  echo "PASS d-drain-routes-events: POST to $DRAIN_PATH_OK, queue file cleared"
else
  echo "FAIL d-drain-routes-events: requests=$(req_count) path=$DRAIN_PATH_OK"; fail=1
fi

exit "$fail"
