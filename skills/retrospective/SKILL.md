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
See `references/observability-config.md` for full configuration (sources: Vercel, Railway, Cloudflare, Supabase, LangSmith, webhook).

## Output Structure

Files written to `.learnings/`: session-log.md (append-only), conventions.md (CLAUDE.md candidates), gotchas.md (pitfalls), metrics.md (velocity).

See `references/output-formats.md` for complete templates and field formats.

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
