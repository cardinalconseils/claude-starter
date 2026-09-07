#!/bin/bash
# SubagentStop — append one outcome line per dispatch to .prd/logs/agents/<role>.jsonl.
# post-tool-trace only sees the literal tool name "Agent", so without this no role
# has a win/loss record (telemetry Layer 2). Exit 0 always; silent outside CKS projects.

INPUT=$(cat 2>/dev/null)
[ -d ".prd/logs" ] || exit 0
PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
printf '%s' "$INPUT" | bash "$PLUGIN_ROOT/scripts/agent-trace.sh" 2>/dev/null
exit 0
