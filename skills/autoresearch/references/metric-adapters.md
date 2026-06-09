---
name: metric-adapters
description: "Metric command patterns for autoresearch — eval pass rate, bundle KB, web vitals, LLM token cost, accessibility"
---

# Metric Adapters

Each adapter: command to run, parse rule, comparison direction. The command runs identically every iteration.

## Adapter 1 — Eval Pass Rate

**Trigger:** metric contains "eval", "pass rate", "cks:evals"

**Route:** `Agent(subagent_type="cks:evals-runner", prompt="Run smoke evals. Return pass rate 0.0–1.0 on last line.")`

**Parse:** last `[0-9]+\.[0-9]+` or `[0-9]+%` → normalize to 0.0–1.0

**Direction:** higher = better

## Adapter 2 — Bundle Size

**Trigger:** metric contains "bundle", "webpack", "build size", "gzip"

```bash
# Next.js first-load JS
npm run build 2>&1 | grep "First Load JS" | head -1 | awk '{gsub(/kB/,""); print $NF}'
# Generic
du -k dist/ | tail -1 | awk '{print $1}'
```

**Parse:** last numeric token (strip kB/KB suffixes)

**Direction:** lower = better

## Adapter 3 — Web Vitals (Lighthouse)

**Trigger:** metric contains "lighthouse", "vitals", "LCP", "performance score"

```bash
npx lighthouse http://localhost:3000 --output=json --quiet 2>/dev/null \
  | jq '.categories.performance.score * 100'
```

**Parse:** JSON numeric field

**Direction:** scores → higher = better; timing (LCP ms) → lower = better

**Prereq:** Start dev server before starting the loop.

## Adapter 4 — LLM Token Cost

**Trigger:** metric contains "token", "cost", "LLM cost"

```bash
python3 -c "import tiktoken; enc=tiktoken.get_encoding('cl100k_base'); print(len(enc.encode(open('prompts/system.md').read())))"
```

**Direction:** lower = better

## Adapter 5 — Accessibility

**Trigger:** metric contains "accessibility", "a11y", "axe"

```bash
npx lighthouse http://localhost:3000 --output=json --quiet 2>/dev/null \
  | jq '.categories.accessibility.score * 100'
```

**Direction:** higher = better (axe violation count: lower = better)

## Generic Fallback

Run metric command, find last line with a bare number, use it. Direction: lower = better (default). If 2 consecutive iterations produce no parseable output → exit with instructions to fix the metric command.
