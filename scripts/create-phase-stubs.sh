#!/bin/bash
# scripts/create-phase-stubs.sh — Deterministically create .prd/phases/ stubs from features-catalog.md
#
# Usage: bash scripts/create-phase-stubs.sh
#
# Env vars (with defaults):
#   CATALOG    — path to features catalog markdown  (default: .bootstrap/features-catalog.md)
#   PHASES_DIR — path to phases output directory    (default: .prd/phases)
#
# Output: one line per created directory, plus a summary count.
# Exit 0 in all cases (catalog missing = silent skip).

CATALOG="${CATALOG:-.bootstrap/features-catalog.md}"
PHASES_DIR="${PHASES_DIR:-.prd/phases}"

if [ ! -f "$CATALOG" ]; then
  exit 0
fi

mkdir -p "$PHASES_DIR"

created=0

# Read table rows: | F-XX | Name | Status | Description |
# Skip header and separator lines (those containing "---")
while IFS='|' read -r _ fid name status description _; do
  # Trim whitespace
  fid=$(echo "$fid" | tr -d ' ')
  name=$(echo "$name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  status=$(echo "$status" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  description=$(echo "$description" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Must match F-XX pattern
  if ! echo "$fid" | grep -qE '^F-[0-9]+$'; then
    continue
  fi

  # Extract numeric part and zero-pad to 2 digits
  num=$(echo "$fid" | sed 's/F-//')
  nn=$(printf '%02d' "$num")

  # Convert name to kebab-case: lowercase, replace non-alphanumeric with hyphens, trim hyphens
  kebab=$(echo "$name" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9]/-/g' \
    | sed 's/--*/-/g' \
    | sed 's/^-//;s/-$//')

  dir="${PHASES_DIR}/${nn}-${kebab}"
  mkdir -p "$dir"

  context_file="${dir}/CONTEXT.md"
  if [ ! -f "$context_file" ]; then
    cat > "$context_file" <<CONTEXT
# ${name}

**Phase:** ${nn}
**Status:** ${status}
**Description:** ${description}
**Source:** auto-cataloged (cks:adopt / cks:bootstrap)

> Phase stub — run \`/cks:new\` and select this feature to start Phase 1 Discovery.
CONTEXT
    echo "created: $dir"
    created=$((created + 1))
  fi
done < <(grep -E '^\|[[:space:]]*F-[0-9]' "$CATALOG")

echo "phase stubs created: $created"
