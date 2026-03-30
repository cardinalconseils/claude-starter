---
name: retrospective
description: >
  Self-learning retrospective agent — analyzes what worked and what didn't after shipping,
  extracts conventions, patterns, and gotchas, tracks velocity metrics, and proposes CLAUDE.md
  updates. Creates compound improvement: every ship cycle makes the next one better.
  Use when: "retro", "retrospective", "what did we learn", "session review", "improve workflow",
  "what went wrong", "analyze this session", or automatically after /cks:ship completes.
  Also triggers on: "update conventions", "what patterns are we using", "track velocity".
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
model: sonnet
---

# Retrospective — Self-Learning After Every Ship

Analyzes completed work to extract learnings that improve future cycles. The compound interest
of AI-assisted development: every ship makes the next one faster and higher quality.

## Flow

```
trigger → gather data → check deployment health → analyze patterns → extract learnings → save → propose updates
```

## Mode Detection

| Condition | Mode | Behavior |
|-----------|------|----------|
| `--auto` flag or invoked from ship workflow | **Auto** | Lightweight, no interaction, focuses on data |
| No arguments | **Interactive** | Guided reflection with user Q&A |
| `--metrics` flag | **Metrics** | Show velocity dashboard only |

## Auto Mode (Post-Ship)

Runs automatically after `/cks:ship` completes. Reads artifacts, analyzes patterns,
saves learnings. No user interaction.

Read workflow: `workflows/auto-retro.md`

## Interactive Mode

User-invoked via `/cks:retro`. Shows recent work summary, asks reflection questions,
combines user input with automated analysis.

Read workflow: `workflows/interactive-retro.md`

## Metrics Mode

Quick dashboard of velocity metrics from `.learnings/metrics.md`.

Display:
```
Velocity Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Phases completed:    {total}
  Avg phase duration:  {time}
  Retry rate:          {%} ({retries}/{total_verifications})
  Ship success rate:   {%}
  Conventions added:   {count}
  Gotchas documented:  {count}

  Recent velocity:
  Phase {NN}: {name} — {duration} ({retries} retries)
  Phase {NN}: {name} — {duration} ({retries} retries)
  Phase {NN}: {name} — {duration} ({retries} retries)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Observability Configuration

The retro can pull deployment logs and production metrics to enrich its analysis.
Configure in `.learnings/observability.md` (created on first use or manually):

```yaml
---
# Observability sources — ordered by priority
# Each source is checked post-deploy for errors, latency changes, and anomalies
sources:
  # Platform deployment logs (auto-detected from project config)
  - type: vercel
    enabled: true           # Uses Vercel MCP: get_runtime_logs, get_deployment
    window: 15m             # Check logs from deploy time + 15 minutes
    error-threshold: 5      # Flag if more than N errors in window

  - type: railway
    enabled: true           # Uses Railway CLI: railway logs
    window: 15m
    error-threshold: 5

  - type: cloudflare
    enabled: false          # Uses Cloudflare MCP: workers_analytics_search
    window: 15m

  - type: supabase
    enabled: false          # Uses Supabase MCP: get_logs, get_advisors
    window: 15m

  # LLM/AI observability
  - type: langsmith
    enabled: false
    api-url: "https://api.smith.langchain.com"  # Override for self-hosted
    # Requires LANGSMITH_API_KEY in .env.local
    window: 30m
    check:
      - trace-errors        # Failed LLM calls
      - latency-p99         # Latency spikes
      - token-usage         # Cost anomalies

  # Generic log endpoint (any service with a REST API)
  - type: webhook
    enabled: false
    url: ""                 # Your log/monitoring API endpoint
    method: GET
    headers:
      Authorization: "Bearer ${LOG_API_KEY}"
    jq-filter: ".errors | length"  # jq expression to extract error count
    error-threshold: 0

# Auto-detect: if true, retro will try to detect the deployment platform
# from project files (vercel.json, railway.toml, wrangler.toml) and enable
# the matching source automatically
auto-detect: true

# Skip observability entirely if no sources are configured/available
skip-if-unavailable: true
---

# Observability Configuration

Configure which deployment and monitoring sources the retro checks after shipping.
Edit the frontmatter above to enable/disable sources and set thresholds.

## How It Works

After each ship, the retro:
1. Detects which platform the code was deployed to
2. Waits for the deploy to propagate (reads deployment status)
3. Pulls logs from the configured window (default: 15 min post-deploy)
4. Scans for errors, latency spikes, and anomalies
5. Includes findings in the retro session-log entry
6. Flags recurring post-deploy issues as GOTCHAs

## Available Source Types

| Type | MCP/Tool Used | What It Checks |
|------|---------------|----------------|
| vercel | Vercel MCP | Build logs, runtime logs, deployment status |
| railway | Railway CLI | Service logs, deploy status |
| cloudflare | Cloudflare MCP | Worker analytics, error rates |
| supabase | Supabase MCP | Database logs, advisor warnings |
| langsmith | WebFetch to API | LLM trace errors, latency, token costs |
| webhook | WebFetch to URL | Any custom monitoring endpoint |
```

## Output Structure

```
.learnings/
├── session-log.md          ← Append-only log of all retro entries (date-stamped)
├── conventions.md          ← Extracted conventions (candidates for CLAUDE.md)
├── gotchas.md              ← Project-specific pitfalls discovered
└── metrics.md              ← Velocity tracking (phases/session, retry rates)
```

### session-log.md Format

```markdown
# Session Log

Append-only record of retrospective entries.

---

## {date} — Phase {NN}: {name}

**Duration:** {time from first discuss to ship}
**Retries:** {count}
**Verification result:** {PASS|FAIL→PASS|FAIL}

### What Worked
- {pattern or approach that succeeded}

### Issues Encountered
- {problem}: {what happened} → {how it was resolved}

### Learnings
- **CONVENTION**: {rule extracted}
- **PATTERN**: {pattern identified}
- **GOTCHA**: {pitfall discovered}

### Deployment Health
- **Platform:** {vercel|railway|cloudflare|...}
- **Status:** {healthy|degraded|errors detected}
- **Errors in window:** {count} ({window} post-deploy)
- **Latency:** {normal|elevated|spike detected}
- **Notable logs:** {summary of any errors or warnings}

### LLM Observability (if applicable)
- **Trace errors:** {count}
- **P99 latency:** {value}
- **Token usage:** {total} ({cost estimate})
- **Anomalies:** {description or "none"}

### Files Most Changed
| File | Changes | Category |
|------|---------|----------|
| {path} | {count} | {iteration/bug/config} |

---
```

### conventions.md Format

```markdown
# Conventions

Extracted from retrospective analysis. Each convention is a candidate for CLAUDE.md.

## Applied
{Conventions already added to CLAUDE.md}

- [x] {Convention} — applied {date}

## Proposed
{Conventions waiting for review}

- [ ] {Convention} — proposed {date}, confidence: {HIGH|MEDIUM}
  - Source: Phase {NN} retro — {brief reason}
```

### gotchas.md Format

```markdown
# Gotchas

Project-specific pitfalls discovered during development.

## {Category}

### {Gotcha title}
- **Discovered:** Phase {NN} ({date})
- **What happened:** {description}
- **Fix:** {how to avoid}
- **Files affected:** {list}
```

### metrics.md Format

```markdown
# Velocity Metrics

## Summary
| Metric | Value | Trend |
|--------|-------|-------|
| Total phases | {N} | — |
| Avg duration | {time} | {up/down/stable} |
| Retry rate | {%} | {up/down/stable} |
| Ship success | {%} | {up/down/stable} |

## Per-Phase History
| Phase | Name | Duration | Retries | Verification | Deploy Health | Ship |
|-------|------|----------|---------|--------------|---------------|------|
| {NN} | {name} | {time} | {N} | {PASS/FAIL} | {healthy/degraded/errors} | {date} |
```

## CLAUDE.md Update Protocol

The retrospective agent **proposes** updates to CLAUDE.md but **never auto-edits** it.

Protocol:
1. Extract high-confidence conventions from analysis
2. Add to `.learnings/conventions.md` under "Proposed"
3. Display the proposed addition to the user:
   ```
   Proposed CLAUDE.md update:

   ## Always Follow These Rules
   + - {new convention}

   Apply this? (yes / no / later)
   ```
4. If "yes" (interactive mode) → apply the edit, move to "Applied" in conventions.md
5. If "auto" mode → only save to conventions.md, don't prompt
6. On next interactive `/cks:retro` → remind about pending proposals

## Integration Points

| Integration | How |
|-------------|-----|
| `/cks:ship` | After ship completes → `Skill(skill="retro", args="--auto")` |
| `/cks:autonomous` | After final ship → auto-retro on all phases |
| SessionStart hook | If `.learnings/conventions.md` has pending proposals → remind |
| Stop hook | If `.learnings/session-log.md` updated today → show count |

## Error Handling

| Failure | Behavior |
|---------|----------|
| No `.prd/` directory | Skip PRD-specific analysis, do git-only analysis |
| No git history | Skip git analysis, only analyze PRD artifacts |
| Empty verification | Note "no verification data" in retro entry |
| CLAUDE.md doesn't exist | Propose creating it with discovered conventions |
| Observability source unavailable | Skip that source, note in session-log |
| Deploy logs show errors | Flag as GOTCHA, include error summary in session-log |
| LangSmith API key missing | Skip LLM observability, note "LLM traces not available" |
| No deploy detected | Skip deployment health entirely, note "no deployment found" |

## Customization

This skill ships with opinionated defaults. Review and adapt to your needs:

- **Metrics tracked**: Which velocity/quality metrics to capture — edit SKILL.md
- **CLAUDE.md proposals**: Threshold for proposing convention updates — edit SKILL.md
- **Convention extraction**: Patterns detected as conventions — edit SKILL.md
- **Auto-trigger**: Whether retro runs automatically after `/cks:release` — edit SKILL.md
- **allowed-tools**: Currently `Read, Write, Edit, Grep, Glob, Bash`. Add tools if needed.
- **model**: Currently `sonnet`. Remove to use your default model.

## Rules

1. **Never auto-edit CLAUDE.md** — always propose and wait for approval (except in auto mode where proposals are just saved)
2. **Append-only session log** — never modify past entries
3. **Date everything** — all entries include timestamps for staleness detection
4. **Be specific** — conventions must be actionable ("Always use X when Y"), not vague ("Write good code")
5. **Confidence matters** — only propose CLAUDE.md updates for HIGH confidence conventions
6. **Track trends** — metrics should show whether things are improving over time
