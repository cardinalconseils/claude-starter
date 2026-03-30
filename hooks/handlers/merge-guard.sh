#!/bin/bash
# CKS Merge Guard — blocks commits if confidence gates are incomplete
# Runs as a PreToolUse hook on Bash when git commit is detected
# Cost: zero tokens — pure bash, grep/awk on markdown

# Find the current phase directory from PRD-STATE.md
STATE_FILE=".prd/PRD-STATE.md"
if [ ! -f "$STATE_FILE" ]; then
  # No PRD state — not in a CKS lifecycle, allow commit
  exit 0
fi

# Extract active phase directory (look for phase dirs in .prd/phases/)
PHASE_DIR=$(find .prd/phases/ -maxdepth 1 -type d 2>/dev/null | sort | tail -1)
if [ -z "$PHASE_DIR" ] || [ "$PHASE_DIR" = ".prd/phases/" ]; then
  # No active phase — allow commit
  exit 0
fi

# Look for CONFIDENCE.md in the phase directory
CONFIDENCE_FILE="${PHASE_DIR}/CONFIDENCE.md"
if [ ! -f "$CONFIDENCE_FILE" ]; then
  # No confidence ledger — not in a sprint with gates, allow commit
  exit 0
fi

# Parse gate results: count applicable gates and their status
TOTAL_APPLICABLE=0
TOTAL_PASSED=0
MISSING_GATES=""
FAILED_GATES=""

while IFS='|' read -r _ num gate applies status evidence timestamp _; do
  # Clean whitespace
  applies=$(echo "$applies" | xargs)
  status=$(echo "$status" | xargs)
  gate=$(echo "$gate" | xargs)

  # Skip non-applicable gates
  if [ "$applies" = "N/A" ] || [ "$applies" = "{auto}" ] || [ -z "$applies" ]; then
    continue
  fi

  if [ "$applies" = "YES" ]; then
    TOTAL_APPLICABLE=$((TOTAL_APPLICABLE + 1))

    case "$status" in
      PASS|SKIP:user-approved)
        TOTAL_PASSED=$((TOTAL_PASSED + 1))
        ;;
      "-")
        MISSING_GATES="${MISSING_GATES}  ✗ ${gate}: not run\n"
        ;;
      FAIL)
        FAILED_GATES="${FAILED_GATES}  ✗ ${gate}: FAILED\n"
        ;;
    esac
  fi
done < <(grep -E '^\| [0-9]' "$CONFIDENCE_FILE")

# If no applicable gates found (template not filled), allow commit
if [ "$TOTAL_APPLICABLE" -eq 0 ]; then
  exit 0
fi

# Check if all gates passed
if [ "$TOTAL_PASSED" -eq "$TOTAL_APPLICABLE" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "CKS Merge Guard — CLEAR"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Confidence: ${TOTAL_PASSED}/${TOTAL_APPLICABLE} gates (100%)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
fi

# Gates incomplete — block the commit
PERCENTAGE=$(( (TOTAL_PASSED * 100) / TOTAL_APPLICABLE ))
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CKS Merge Guard — BLOCKED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Confidence: ${TOTAL_PASSED}/${TOTAL_APPLICABLE} gates (${PERCENTAGE}%)"
echo ""

if [ -n "$MISSING_GATES" ]; then
  echo "Not run:"
  echo -e "$MISSING_GATES"
fi

if [ -n "$FAILED_GATES" ]; then
  echo "Failed:"
  echo -e "$FAILED_GATES"
fi

echo "Complete all gates before committing."
echo "Ledger: ${CONFIDENCE_FILE}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Exit 2 = block the tool call
exit 2
