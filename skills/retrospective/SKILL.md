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

The retrospective agent **proposes** updates to CLAUDE.md and can auto-apply high-confidence ones.

Protocol:
1. Extract conventions from analysis. Score each as high/medium/low confidence.
2. Add ALL to `.learnings/conventions.md`

**Interactive mode** (`/cks:retro`):
3. Display each proposed convention to the user:
   ```
   Proposed CLAUDE.md update:

   ## Always Follow These Rules
   + - {new convention}

   Apply this? (yes / no / later)
   ```
4. If "yes" → apply the edit to CLAUDE.md, mark as "Applied" in conventions.md
5. If "no" → mark as "Rejected" in conventions.md
6. If "later" → mark as "Proposed" (reminded on next session)

**Auto mode** (`--auto`, after ship/autonomous):
3. **High-confidence** conventions (observed 2+ times, or directly from user retro feedback) → **auto-apply** to `.learnings/conventions.md` as "Applied" AND append to `.claude/rules/learnings.md` (auto-generated guardrail file)
4. **Medium/low-confidence** conventions → save as "Proposed" for next interactive retro
5. Display summary of what was auto-applied:
   ```
   Auto-applied {N} convention(s) to .claude/rules/learnings.md:
   - {convention 1}
   - {convention 2}
   ```

**CRITICAL: The learning must actually change behavior.** Every "Applied" convention must appear
in either CLAUDE.md or `.claude/rules/learnings.md` so that agents (executor, planner, designer)
read and follow it in the next phase. Conventions that sit only in `.learnings/conventions.md`
are invisible to agents and useless.

## Gotchas Protocol

When a gotcha is discovered (bug pattern, technology pitfall, domain-specific issue):
1. Add to `.learnings/gotchas.md` with date, phase, and description
2. Tag with relevant domain/technology keywords
3. Agents (executor, planner, designer) read gotchas.md at the start of each phase
   and warn about relevant entries matching their current domain/technology

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

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We don't have time for a retro" | Skipping retros means repeating mistakes. 15 minutes now saves hours next sprint. |
| "Everything went fine" | 'Fine' hides process improvements. Even successful sprints have learnings worth capturing. |
| "We'll remember for next time" | You won't. Write it down. Memory is unreliable; documented learnings compound. |

## Rules

1. **Never auto-edit CLAUDE.md directly** — in interactive mode, always propose and wait for approval. In auto mode, write high-confidence conventions to `.claude/rules/learnings.md` (agents read this automatically).
2. **Append-only session log** — never modify past entries
3. **Date everything** — all entries include timestamps for staleness detection
4. **Be specific** — conventions must be actionable ("Always use X when Y"), not vague ("Write good code")
5. **Confidence matters** — only propose CLAUDE.md updates for HIGH confidence conventions
6. **Track trends** — metrics should show whether things are improving over time
