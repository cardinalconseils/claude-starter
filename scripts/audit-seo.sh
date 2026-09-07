#!/usr/bin/env bash
# scripts/audit-seo.sh — Verify on-page SEO signals in built HTML output
# Usage: bash scripts/audit-seo.sh
# Requires: pnpm build to have been run (or runs it automatically)
# Note: Uses POSIX-compatible grep (no -P flag) for macOS/Linux portability
#
# CUSTOMIZATION: Update the location grep on line 42 to match your project's city.

set -euo pipefail

DIST="dist"
PASS=0
FAIL=0

echo "=== SEO Audit: On-Page Signals ==="
echo ""

# Build if dist/ doesn't exist
if [ ! -d "$DIST" ]; then
  echo "Building site..."
  pnpm build || { echo "FAIL: Build failed"; exit 1; }
fi

# Extract <title> content using sed (portable, no -P flag needed)
extract_title() {
  sed -n 's/.*<title>\([^<]*\)<\/title>.*/\1/p' "$1" 2>/dev/null | head -1
}

# Extract meta description content using sed
extract_description() {
  sed -n 's/.*<meta name="description" content="\([^"]*\)".*/\1/p' "$1" 2>/dev/null | head -1
}

# OSEO-01: Title tags contain pipe separator + brand
echo "--- OSEO-01: Title Tags ---"
TITLE_ISSUES=0
while IFS= read -r file; do
  title=$(extract_title "$file")
  if [ -n "$title" ]; then
    if ! echo "$title" | grep -q '|'; then
      echo "  FAIL: No pipe separator in title: $file -> $title"
      TITLE_ISSUES=$((TITLE_ISSUES + 1))
    fi
    # TODO: Replace '[CITY]' below with your project's target city
    if ! echo "$title" | grep -qi '[CITY]'; then
      echo "  FAIL: No location in title: $file -> $title"
      TITLE_ISSUES=$((TITLE_ISSUES + 1))
    fi
    len=${#title}
    if [ "$len" -lt 20 ] || [ "$len" -gt 70 ]; then
      echo "  WARN: Title length $len chars (target 30-60): $file -> $title"
    fi
  fi
done < <(find "$DIST" -name "*.html" -type f)
if [ "$TITLE_ISSUES" -eq 0 ]; then
  echo "  PASS: All titles have pipe separator and location"
  PASS=$((PASS + 1))
else
  FAIL=$((FAIL + 1))
fi

# OSEO-02: Meta descriptions exist and are under 160 chars
echo ""
echo "--- OSEO-02: Meta Descriptions ---"
META_ISSUES=0
while IFS= read -r file; do
  # Skip AMP files — they don't use SEOHead
  relpath="${file#$DIST/}"
  if echo "$relpath" | grep -q '^amp/'; then
    continue
  fi
  desc=$(extract_description "$file")
  if [ -z "$desc" ]; then
    echo "  FAIL: No meta description: $file"
    META_ISSUES=$((META_ISSUES + 1))
  else
    len=${#desc}
    if [ "$len" -gt 160 ]; then
      echo "  FAIL: Meta description too long ($len chars): $file"
      META_ISSUES=$((META_ISSUES + 1))
    fi
  fi
done < <(find "$DIST" -name "*.html" -type f)
if [ "$META_ISSUES" -eq 0 ]; then
  echo "  PASS: All meta descriptions present and under 160 chars"
  PASS=$((PASS + 1))
else
  FAIL=$((FAIL + 1))
fi

# OSEO-03: OG tags present (skip AMP files)
echo ""
echo "--- OSEO-03: Open Graph Tags ---"
OG_ISSUES=0
while IFS= read -r file; do
  relpath="${file#$DIST/}"
  if echo "$relpath" | grep -q '^amp/'; then
    continue
  fi
  if ! grep -q 'og:type' "$file" 2>/dev/null; then
    echo "  FAIL: Missing og:type: $file"
    OG_ISSUES=$((OG_ISSUES + 1))
  fi
  if ! grep -q 'og:title' "$file" 2>/dev/null; then
    echo "  FAIL: Missing og:title: $file"
    OG_ISSUES=$((OG_ISSUES + 1))
  fi
done < <(find "$DIST" -name "*.html" -type f)
if [ "$OG_ISSUES" -eq 0 ]; then
  echo "  PASS: All pages have OG type and title"
  PASS=$((PASS + 1))
else
  FAIL=$((FAIL + 1))
fi

# OSEO-05: QuickAnswer blocks on service and area pages
echo ""
echo "--- OSEO-05: Quick Answer Blocks ---"
QA_ISSUES=0
for dir in "$DIST/services" "$DIST/service-areas"; do
  if [ -d "$dir" ]; then
    while IFS= read -r file; do
      # Skip index pages
      relpath="${file#$DIST/}"
      if echo "$relpath" | grep -qE '(services|service-areas)/index\.html$'; then
        continue
      fi
      if ! grep -q 'bg-green-50' "$file" 2>/dev/null; then
        echo "  FAIL: No QuickAnswer block: $file"
        QA_ISSUES=$((QA_ISSUES + 1))
      fi
    done < <(find "$dir" -name "*.html" -type f)
  fi
done
if [ "$QA_ISSUES" -eq 0 ]; then
  echo "  PASS: All service/area pages have QuickAnswer blocks"
  PASS=$((PASS + 1))
else
  FAIL=$((FAIL + 1))
fi

# OSEO-07: FAQPage schema on service and area pages
echo ""
echo "--- OSEO-07: FAQPage Schema ---"
FAQ_ISSUES=0
for dir in "$DIST/services" "$DIST/service-areas"; do
  if [ -d "$dir" ]; then
    while IFS= read -r file; do
      relpath="${file#$DIST/}"
      if echo "$relpath" | grep -qE '(services|service-areas)/index\.html$'; then
        continue
      fi
      if ! grep -q 'FAQPage' "$file" 2>/dev/null; then
        echo "  FAIL: No FAQPage schema: $file"
        FAQ_ISSUES=$((FAQ_ISSUES + 1))
      fi
    done < <(find "$dir" -name "*.html" -type f)
  fi
done
if [ "$FAQ_ISSUES" -eq 0 ]; then
  echo "  PASS: All service/area pages have FAQPage schema"
  PASS=$((PASS + 1))
else
  FAIL=$((FAIL + 1))
fi

# OSEO-08: "Last updated" on content pages
echo ""
echo "--- OSEO-08: Freshness Dates ---"
FRESH_ISSUES=0
for dir in "$DIST/services" "$DIST/service-areas"; do
  if [ -d "$dir" ]; then
    while IFS= read -r file; do
      relpath="${file#$DIST/}"
      if echo "$relpath" | grep -qE '(services|service-areas)/index\.html$'; then
        continue
      fi
      if ! grep -q 'Last updated' "$file" 2>/dev/null; then
        echo "  FAIL: No 'Last updated' text: $file"
        FRESH_ISSUES=$((FRESH_ISSUES + 1))
      fi
    done < <(find "$dir" -name "*.html" -type f)
  fi
done
if [ "$FRESH_ISSUES" -eq 0 ]; then
  echo "  PASS: All service/area pages show freshness date"
  PASS=$((PASS + 1))
else
  FAIL=$((FAIL + 1))
fi

# Summary
echo ""
echo "=== Summary ==="
echo "PASS: $PASS / $((PASS + FAIL))"
echo "FAIL: $FAIL / $((PASS + FAIL))"
if [ "$FAIL" -gt 0 ]; then
  echo "STATUS: ISSUES FOUND"
  exit 1
else
  echo "STATUS: ALL CHECKS PASSED"
  exit 0
fi
