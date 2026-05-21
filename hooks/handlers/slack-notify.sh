#!/usr/bin/env bash
# slack-notify.sh — Post CKS phase/status updates to Slack webhook
# Fires on SubagentStop and Stop events. Silent if not configured.

PROJECT_ROOT="${CLAUDE_PROJECT_ROOT:-$PWD}"
CONFIG_FILE="$PROJECT_ROOT/.slack/config.json"

# Exit silently if config missing
if [ ! -f "$CONFIG_FILE" ]; then
  exit 0
fi

WEBHOOK_URL=$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('webhook_url',''))" "$CONFIG_FILE" 2>/dev/null)

# Exit if URL is missing or still a placeholder
if [ -z "$WEBHOOK_URL" ] || echo "$WEBHOOK_URL" | grep -q "YOUR\|REPLACE\|placeholder"; then
  exit 0
fi

PHASE="${CKS_PHASE:-update}"
STATUS="${CKS_STATUS:-complete}"
BRANCH=$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || echo "unknown")

PAYLOAD="{\"text\": \"CKS [$PHASE] on [$BRANCH] — $STATUS\"}"

curl -s -o /dev/null --max-time 5 -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"

exit 0
