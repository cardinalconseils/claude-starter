#!/bin/bash
# scripts/north-star-status.sh — Goals:/Budget: banner lines for session-start.
# `--json` emits {north_star, budget_pct} for the status packet. Exit 0 always —
# a missing file is a prompt to the user, never a hook failure.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
[ -f "$SCRIPT_DIR/hq-path.sh" ] && . "$SCRIPT_DIR/hq-path.sh"

NS_PATH=$(cks_north_star_path 2>/dev/null)
GOALS=0
[ -n "$NS_PATH" ] && GOALS=$(awk '/^## /{g=($0 ~ /[Gg]oals/)} g && /^- /{n++} END{print n+0}' "$NS_PATH" 2>/dev/null)

BUDGET_FILE=".finops/BUDGET.md"
CEILING=""; CURRENCY=""; PCT=""
if [ -f "$BUDGET_FILE" ]; then
  CEILING=$(grep -im1 'monthly ceiling' "$BUDGET_FILE" | sed 's/.*[Cc]eiling[^0-9]*//' | grep -oE '^[0-9]+(\.[0-9]+)?')
  CURRENCY=$(grep -im1 'currency' "$BUDGET_FILE" | sed 's/.*[Cc]urrency:\**//' | grep -oE '[A-Z]{3}' | head -1)
  BURN=$(grep -E '^- [0-9]{4}-[0-9]{2}-[0-9]{2} \|' "$BUDGET_FILE" | awk -F'|' '{gsub(/[^0-9.]/,"",$3); s+=$3} END{print s+0}')
  [ -n "$CEILING" ] && [ "$CEILING" != "0" ] && PCT=$(awk -v b="$BURN" -v c="$CEILING" 'BEGIN{printf "%d", (b*100/c)+0.5}')
fi

if [ "${1:-}" = "--json" ]; then
  printf '{"north_star":"%s","budget_pct":%s}\n' "$NS_PATH" "${PCT:-null}"
  exit 0
fi

if [ -n "$NS_PATH" ]; then
  echo "Goals:   North Star: ${NS_PATH} (${GOALS} goals)"
else
  echo "Goals:   No North Star — run /cks:chief to set this quarter's goals"
fi
if [ -n "$PCT" ]; then
  echo "Budget:  ${CEILING} ${CURRENCY:-???}/mo, ${PCT}% burned"
else
  echo "Budget:  No budget — /cks:bootstrap writes .finops/BUDGET.md"
fi
exit 0
