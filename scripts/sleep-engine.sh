#!/bin/bash
# SkillOpt subprocess wrapper — Python version check + skillopt invocation
# Usage:
#   sleep-engine.sh --input FILE --output FILE --skill NAME
#   sleep-engine.sh --apply-proposal --input FILE --target FILE

SKILLOPT_VERSION="0.1.0"
MODE=""
INPUT_FILE=""
OUTPUT_FILE=""
TARGET_FILE=""
SKILL_NAME=""

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --apply-proposal) MODE="apply"; shift ;;
    --input) INPUT_FILE="$2"; shift 2 ;;
    --output) OUTPUT_FILE="$2"; shift 2 ;;
    --target) TARGET_FILE="$2"; shift 2 ;;
    --skill) SKILL_NAME="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# Binary presence check — per external-tool-integration.md rule 1
if ! command -v skillopt >/dev/null 2>&1; then
  cat <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    pipx install skillopt
Why:    /cks:sleep requires the skillopt binary on PATH. Not found in $PATH.
Then:   re-run /cks:sleep
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  exit 1
fi

# Python 3.10+ check
PY_MAJOR=$(python3 -c "import sys; print(sys.version_info.major)" 2>/dev/null || echo 0)
PY_MINOR=$(python3 -c "import sys; print(sys.version_info.minor)" 2>/dev/null || echo 0)
if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 10 ]; }; then
  echo "ERROR: Python 3.10+ required (found ${PY_MAJOR}.${PY_MINOR})" >&2
  exit 2
fi

# Version detection — prefer skillopt --version, fall back to pip show
SKILLOPT_VER=$(skillopt --version 2>/dev/null | head -1 | xargs)
if [ -z "$SKILLOPT_VER" ]; then
  SKILLOPT_VER=$(pip show skillopt 2>/dev/null | grep "^Version:" | awk '{print $2}')
fi
if [ -z "$SKILLOPT_VER" ]; then
  cat <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    pipx install skillopt
Why:    /cks:sleep requires the skillopt binary on PATH. Not found in $PATH.
Then:   re-run /cks:sleep
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  exit 1
fi

# Version drift check — per external-tool-integration.md rule 3
SLEEP_CONFIG=".cks/sleep-config.json"
if [ -f "$SLEEP_CONFIG" ] && command -v jq >/dev/null 2>&1; then
  CACHED_VER=$(jq -r '.skillopt_version_seen // ""' "$SLEEP_CONFIG" 2>/dev/null)
  if [ -n "$CACHED_VER" ] && [ "$CACHED_VER" != "$SKILLOPT_VER" ]; then
    cat <<EOF
· · · · · · · · · · · · · · · · · · · · · · · ·
💡 SUGGESTION
· · · · · · · · · · · · · · · · · · · · · · · ·
skillopt updated: ${CACHED_VER} → ${SKILLOPT_VER}
Review changelog: https://github.com/cardinalconseils/claude-starter/CHANGELOG.md
· · · · · · · · · · · · · · · · · · · · · · · ·
EOF
  fi
  # Update cached version — atomic write via temp file
  TMP_CONFIG=$(mktemp)
  jq --arg v "$SKILLOPT_VER" '.skillopt_version_seen = $v' "$SLEEP_CONFIG" > "$TMP_CONFIG" 2>/dev/null && mv "$TMP_CONFIG" "$SLEEP_CONFIG" || rm -f "$TMP_CONFIG"
fi

if [ "$MODE" = "apply" ]; then
  # Apply a proposal diff to a target file
  [ -z "$INPUT_FILE" ] || [ -z "$TARGET_FILE" ] && { echo "ERROR: --input and --target required for apply mode" >&2; exit 1; }
  python3 - "$INPUT_FILE" "$TARGET_FILE" << 'PYEOF'
import sys, re, pathlib

proposal = pathlib.Path(sys.argv[1]).read_text()
target_path = pathlib.Path(sys.argv[2])
target = target_path.read_text()

# Parse Before/After blocks
pattern = r'### Section: (.+?)\n\*\*Before:\*\*\n(.*?)\n\*\*After:\*\*\n(.*?)(?=\n### Section:|\Z)'
matches = re.findall(pattern, proposal, re.DOTALL)

if not matches:
    print("No Before/After blocks found in proposal", file=sys.stderr)
    sys.exit(4)

result = target
for section, before, after in matches:
    before = before.strip()
    after = after.strip()
    if before in result:
        result = result.replace(before, after, 1)
    else:
        print(f"WARN: section '{section.strip()}' before-block not found — skipping", file=sys.stderr)

target_path.write_text(result)
print(f"Applied {len(matches)} section(s) to {sys.argv[2]}")
PYEOF
  exit $?
fi

# Generate proposal mode
[ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_FILE" ] && { echo "ERROR: --input and --output required" >&2; exit 1; }

python3 - "$INPUT_FILE" "$OUTPUT_FILE" "$SKILL_NAME" "$SKILLOPT_VER" << 'PYEOF'
import sys, json, pathlib

input_data = json.loads(pathlib.Path(sys.argv[1]).read_text())
output_path = pathlib.Path(sys.argv[2])
skill_name = sys.argv[3] if len(sys.argv) > 3 else "unknown"
skillopt_ver = sys.argv[4] if len(sys.argv) > 4 else ""

try:
    from skillopt import sleep as skillopt_sleep
    proposal = skillopt_sleep(
        skill_content=input_data["skill_content"],
        task_examples=input_data.get("task_examples", []),
        seed=input_data.get("seed", "00000000"),
        held_out_count=input_data.get("held_out_count", 5),
    )
    output_path.write_text(proposal)
    print(f"Proposal written: {len(proposal)} bytes")
except Exception as e:
    print(f"ERROR: skillopt_sleep failed: {e}", file=sys.stderr)
    sys.exit(1)
PYEOF
PROPOSAL_EXIT=$?

# Persist version for sleep-runner to embed in result JSON (AC-1.2)
mkdir -p .sleep
echo "$SKILLOPT_VER" > .sleep/.skillopt-version-cache 2>/dev/null || true

exit $PROPOSAL_EXIT
