---
description: "Token optimization — configure cost-saving defaults and audit context usage"
argument-hint: "[--audit | --apply | --status]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# /cks:optimize — Token & Cost Optimization

Audit and configure token usage to reduce costs without sacrificing quality.

## Usage

```
/cks:optimize              → Audit current config + suggest improvements
/cks:optimize --apply      → Apply recommended settings
/cks:optimize --status     → Show current token/cost settings
```

## Steps Claude Executes

### 1. Audit Current Configuration

Check `~/.claude/settings.json` and project `.claude/settings.json` for:

| Setting | Default | Recommended | Savings |
|---------|---------|-------------|---------|
| `model` | opus | **sonnet** (for 80% of tasks) | ~60% cost reduction |
| `MAX_THINKING_TOKENS` | 31,999 | **10,000** | ~70% thinking cost reduction |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | 95 | **50** | Better quality in long sessions |

### 2. Context Budget Audit

Count what's consuming your context window:

```
Context Budget Breakdown:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
System prompt:        ~{n}K tokens
MCP tool schemas:     ~{n}K tokens ({count} tools)
Agent descriptions:   ~{n}K tokens ({count} agents)
Loaded skills:        ~{n}K tokens
CLAUDE.md:            ~{n}K tokens
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Estimated available:  ~{n}K of 200K
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Rules of thumb:**
- Keep MCP servers under 10 per project
- Keep total active tools under 80
- Agent descriptions load ALWAYS (even unused) — keep them concise
- Skills load on trigger — these are fine to have many of

### 3. MCP Server Audit

List enabled MCP servers and flag unused ones:
- Check which MCPs were actually invoked in recent sessions
- Suggest disabling unused MCPs in project `.claude/settings.json`:

```json
{
  "disabledMcpServers": ["unused-server-1", "unused-server-2"]
}
```

### 4. Compaction Strategy

Explain when to compact manually vs letting auto-compact run:

**Compact NOW (between phases):**
- After `/cks:discover` completes → before `/cks:design`
- After `/cks:design` completes → before `/cks:sprint`
- After debugging → before continuing feature work
- After research/exploration → before implementation

**DON'T compact:**
- Mid-implementation (you lose file paths, variable names, partial state)
- During code review (you lose the diff context)
- While debugging (you lose the error trace)

### 5. Daily Workflow Tips

```
Cost-Saving Workflow:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/model sonnet     → Default for most tasks
/model opus       → Complex architecture, deep debugging
/clear            → Between unrelated tasks (free, instant)
/compact          → At phase boundaries
/cost             → Check spending during session
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Output

```
Token Optimization Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Current model:       {model}
Thinking tokens:     {current} → recommended {recommended}
Auto-compact:        {current}% → recommended {recommended}%
MCP servers:         {count} active ({count} could be disabled)
Context available:   ~{n}K of 200K

Estimated savings:   ~{percent}% cost reduction

Recommended changes:
  1. {change + rationale}
  2. {change + rationale}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Constraints

- Never change settings without `--apply` flag or user confirmation
- Always show before/after comparison
- Don't recommend Haiku for complex tasks — it degrades quality
- Sonnet handles 80%+ of coding tasks well; Opus for architecture and deep reasoning
