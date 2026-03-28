# Workflow: Auto-Retrospective (Post-Ship)

## Overview

Lightweight, non-interactive retrospective that runs automatically after `/cks:ship`.
Gathers data from git history and PRD artifacts, analyzes patterns, extracts learnings,
and saves to `.learnings/`. No user interaction — everything is inferred.

## Prerequisites
- Just shipped work (invoked from ship workflow or autonomous mode)
- Git repository with recent commits

## Process

### Step 1: Gather Data

**1a. Determine scope:**

Read `.prd/PRD-STATE.md` to find the most recently shipped phase:
```
active_phase: {NN}
phase_status: shipped
last_action_date: {date}
```

If no `.prd/` exists, analyze the last session's git commits instead:
```bash
# Get today's commits (or last 24h of commits)
git log --since="24 hours ago" --oneline --stat --no-merges
```

**1b. Gather phase artifacts (if .prd/ exists):**

```
Read .prd/phases/{NN}-{name}/{NN}-CONTEXT.md     → what was planned
Read .prd/phases/{NN}-{name}/{NN}-PLAN.md         → how it was planned
Read .prd/phases/{NN}-{name}/{NN}-SUMMARY.md      → what was built
Read .prd/phases/{NN}-{name}/{NN}-VERIFICATION.md → what passed/failed
Read .prd/phases/{NN}-{name}/{NN}-REVIEW.md       → sprint review feedback + retrospective answers (if exists)
```

Extract from artifacts:
- Acceptance criteria count and pass/fail
- Technologies and integrations mentioned
- File paths referenced in plan vs actually changed
- Any retry indicators (multiple SUMMARY files, failed verification)
- Sprint review assessment: feature-check, quality-check, metrics-check results (from REVIEW.md)
- User retrospective answers: wins, frustrations, next-time items (from REVIEW.md ### Retrospective section)
- Use sprint review issues and user frustrations to enrich "Issues Encountered" in session-log
- Use user wins to enrich "What Worked" in session-log
- If REVIEW.md does not exist, skip — maintains backward compatibility with phases shipped without review

**1c. Gather git data:**

```bash
# Commits for this phase (if on a feature branch)
git log --oneline --stat --no-merges $(git merge-base HEAD main)..HEAD

# Or if on main, commits since last tag/ship
git log --oneline --stat --no-merges --since="{last_ship_date}"

# Files changed most frequently
git log --since="{phase_start}" --name-only --no-merges | sort | uniq -c | sort -rn | head -20

# Commit message patterns
git log --since="{phase_start}" --format="%s" --no-merges
```

**1d. Check for .context/ usage:**

```bash
# Which context briefs were referenced during this phase
ls .context/*.md 2>/dev/null
```

### Step 2: Deployment Health Check

Check production health after the ship. This step is skipped if no observability sources are configured or available.

**2a. Load observability config:**

Read `.learnings/observability.md` if it exists, parse YAML frontmatter.
If no config exists, use `auto-detect: true` defaults — check for platform indicators:

```bash
# Auto-detect deployment platform
if [ -f "vercel.json" ] || [ -f ".vercel/project.json" ]; then
  PLATFORM="vercel"
elif [ -f "railway.toml" ] || [ -f "railway.json" ]; then
  PLATFORM="railway"
elif [ -f "wrangler.toml" ]; then
  PLATFORM="cloudflare"
else
  PLATFORM="none"
fi
```

**2b. Check deployment status:**

For each enabled source:

**Vercel:**
```
mcp__claude_ai_Vercel__list_deployments(limit: 1)  → get latest deployment
mcp__claude_ai_Vercel__get_deployment(deploymentId: "{id}")  → check status (READY/ERROR)
mcp__claude_ai_Vercel__get_runtime_logs(deploymentId: "{id}")  → scan for errors
mcp__claude_ai_Vercel__get_deployment_build_logs(deploymentId: "{id}")  → check build issues
```

**Railway:**
```bash
railway logs --service {service} --limit 100 2>&1
# Parse for ERROR, FATAL, WARN, panic, exception, traceback
```

**Cloudflare:**
```
mcp__cloudflare__workers_analytics_search(query: "errors last 15 minutes")
mcp__cloudflare__analytics_get()
```

**Supabase:**
```
mcp__claude_ai_Supabase__get_logs(projectId: "{id}", type: "api")
mcp__claude_ai_Supabase__get_advisors(projectId: "{id}")  → check for performance warnings
```

**LangSmith** (if enabled and `LANGSMITH_API_KEY` in env):
```bash
# Check for failed traces in the last 30 minutes
curl -s "https://api.smith.langchain.com/api/v1/runs" \
  -H "x-api-key: $LANGSMITH_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "filter": "eq(status, \"error\")",
    "limit": 20,
    "start_time": "{deploy_time_iso}"
  }'
```

Also check latency and token usage:
```bash
# Get run stats for cost/latency monitoring
curl -s "https://api.smith.langchain.com/api/v1/runs/stats" \
  -H "x-api-key: $LANGSMITH_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "start_time": "{deploy_time_iso}",
    "end_time": "{deploy_time_plus_window_iso}"
  }'
```

Extract: total_tokens, total_cost, latency_p99, error_count.

**Generic webhook** (if configured):
```bash
curl -s -X {method} "{url}" \
  -H "{headers}" \
  | jq '{jq-filter}'
```

**2c. Analyze deployment results:**

For each source that returned data:

```
deploy_health = {
  platform: "{detected}",
  status: "healthy|degraded|errors",
  errors_in_window: {count},
  error_samples: [{message, timestamp}],  # Top 5 errors
  latency: "normal|elevated|spike",
  warnings: [{message}],
  llm_observability: {                     # Only if LangSmith enabled
    trace_errors: {count},
    latency_p99: "{ms}",
    total_tokens: {count},
    estimated_cost: "${amount}",
    anomalies: [{description}]
  }
}
```

**Categorize deploy health:**
- **Healthy**: 0 errors, normal latency, no warnings
- **Degraded**: < error-threshold errors, or elevated latency, or minor warnings
- **Errors**: >= error-threshold errors, or critical warnings, or failed deployment

**2d. Generate deployment learnings:**

If errors detected:
- **GOTCHA**: "Post-deploy error: {error_message}. Occurs after shipping {type_of_change}."
- If same error appeared in previous retros → **CONVENTION**: "Always {mitigation} before shipping {type_of_change}"

If latency spike detected:
- **GOTCHA**: "Latency spike ({X}ms → {Y}ms) detected after shipping {phase_name}"

If LLM cost anomaly:
- **GOTCHA**: "Token usage spiked to {X} (${cost}) after {phase_name} — check prompt efficiency"

If everything healthy:
- Note: "Deploy healthy — no issues in {window} window"

### Step 3: Analyze Patterns

**2a. Hotspot detection:**

Files changed more than 3 times in a phase are hotspots. Categorize:
- **Iteration hotspot**: File was refined multiple times (normal for new features)
- **Bug hotspot**: File was fixed multiple times (potential design issue)
- **Config hotspot**: Config file changed repeatedly (missing environment setup?)

**2b. Verification analysis:**

Parse VERIFICATION.md for:
- Total criteria checked
- Pass count, fail count
- For failures: extract the reason
- Was there a retry? (indicates first attempt had issues)

Categorize failures:
- **Missing implementation**: Criterion not addressed
- **Bug**: Implementation doesn't work correctly
- **Integration**: Works alone but fails with other components
- **Test gap**: No test coverage for the criterion

**2c. Commit pattern analysis:**

```
Commit messages → categorize:
  feat: → new code written
  fix: → bug encountered and fixed
  refactor: → code restructured
  chore: → tooling/config changes

Ratio analysis:
  High feat:fix ratio → clean implementation
  High fix:feat ratio → encountered many bugs
  Many refactor: → design changed during implementation
```

**2d. Duration estimation:**

```
Phase start: first commit timestamp after discuss/plan
Phase end: ship commit timestamp
Duration: end - start
```

### Step 4: Extract Learnings

Based on analysis, generate structured learnings:

**CONVENTION candidates (HIGH confidence):**
Look for patterns that:
- Appeared consistently across multiple files
- Avoided problems (files following the pattern had fewer fixes)
- Were established during this phase and should persist

Examples:
- "All API routes in this project use {pattern} for error handling"
- "Database queries always go through {service file}, never called directly"
- "Component files are co-located with their tests in {structure}"

**PATTERN observations:**
- Technology patterns used ("Used Zod for all API validation")
- Architecture patterns ("Feature-based folder structure, not layer-based")
- Testing patterns ("Integration tests for API routes, unit tests for utilities")

**GOTCHA discoveries:**
Look for:
- Files that were fixed multiple times (what was the root cause?)
- Verification failures (what was missed?)
- Unexpected changes (files not in the plan that had to be changed)

Examples:
- "Supabase RLS policies must be updated when adding new tables — easy to forget"
- "Next.js server actions can't be called from client components directly"
- "Stripe webhook signatures fail in dev without ngrok"

**VELOCITY metrics:**
```
phase_number: {NN}
phase_name: "{name}"
duration: "{estimate}"
total_commits: {N}
feat_commits: {N}
fix_commits: {N}
refactor_commits: {N}
files_changed: {N}
hotspots: [{file, change_count}]
verification_pass: {N}/{total}
verification_retries: {0|1}
deploy_platform: "{platform}"
deploy_health: "{healthy|degraded|errors|skipped}"
deploy_errors: {N}
llm_trace_errors: {N}        # if LangSmith
llm_latency_p99: "{ms}"      # if LangSmith
llm_cost: "${amount}"         # if LangSmith
```

### Step 5: Save Learnings

**4a. Create .learnings/ if needed:**
```bash
mkdir -p .learnings
```

**4b. Append to session-log.md:**

If file doesn't exist, create it with header:
```markdown
# Session Log

Append-only record of retrospective entries.
```

Append new entry:
```markdown

---

## {YYYY-MM-DD} — Phase {NN}: {name}

**Duration:** {estimate}
**Commits:** {total} ({feat} feat, {fix} fix, {refactor} refactor)
**Verification:** {pass}/{total} passed ({retries} retries)

### What Worked
{List patterns that led to clean implementation — files with no fix commits}

### Deployment Health
- **Platform:** {platform or "not detected"}
- **Status:** {healthy|degraded|errors|skipped}
- **Errors:** {count} in {window} window
- **Notable:** {error summary or "clean deploy"}
{If LangSmith enabled:}
- **LLM traces:** {error_count} errors, p99: {latency}ms, cost: ${amount}

### Issues Encountered
{List problems found — verification failures, hotspots, unexpected changes, deploy errors}

### Learnings
{Each learning with category tag}
- **CONVENTION**: {description}
- **PATTERN**: {description}
- **GOTCHA**: {description}

### Hotspots
| File | Changes | Type |
|------|---------|------|
| {path} | {count} | {iteration/bug/config} |
```

**4c. Update conventions.md:**

For each HIGH confidence convention extracted:
- Check if it already exists in conventions.md (avoid duplicates)
- If new → add under "Proposed" section
- Include source phase and confidence

**4d. Update gotchas.md:**

For each gotcha discovered:
- Check for duplicates
- Add under appropriate category (or create new category)

**4e. Update metrics.md:**

Add new row to per-phase history table.
Recalculate summary metrics (averages, trends).

Trend calculation:
```
Compare last 3 phases:
  Duration trend: decreasing = improving, increasing = concerning
  Retry rate: decreasing = improving
  Fix ratio: decreasing = cleaner implementation
```

### Step 6: Summary Display

```
Retrospective: Phase {NN} — {name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Duration:     {estimate}
  Commits:      {total} ({feat}F {fix}X {refactor}R)
  Verification: {pass}/{total} ✓ ({retries} retries)
  Deploy:       {platform} — {healthy ✓ | degraded ⚠ | errors ✗ | skipped —}
  Hotspots:     {count} files

{If LangSmith data available:}
  LLM Health:   {trace_errors} errors | p99: {latency}ms | ${cost}

  Learnings extracted:
    Conventions: {count} ({new_proposals} new proposals)
    Patterns:    {count}
    Gotchas:     {count}

  Saved to: .learnings/session-log.md

{If deploy errors found:}
  Deploy issues detected:
    - {error summary 1}
    - {error summary 2}
  These have been logged as GOTCHAs.

{If new convention proposals:}
  New convention proposals for CLAUDE.md:
    - {convention 1}
    - {convention 2}
  Review with: /cks:retro

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

1. **Non-interactive** — This is auto mode. No questions, no prompts.
2. **Append-only** — Never modify past session-log entries.
3. **Conservative conventions** — Only flag HIGH confidence conventions. Better to miss one than propose a bad rule.
4. **Git-safe** — Only read git data, never modify the repository.
5. **Graceful degradation** — If any data source is missing, skip that analysis and note it.
