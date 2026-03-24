# /bootstrap Command Reference

Detailed per-file adaptation logic for bootstrap mode.

---

## Pre-flight Scan

Before showing the intake, scan `.claude/` and report:

```bash
# Claude should mentally execute this logic:
ls .claude/skills/    → list all *.md files
ls .claude/agents/    → list all *.md files
ls .claude/commands/  → list all *.md files
ls .claude/tools/     → list all *.md files
test -f CLAUDE.md     → exists or not
```

Output to user:
```
📁 .claude/ scan complete
   Skills   (3): docx, n8n-workflows, supabase
   Agents   (2): reviewer, deployer
   Commands (2): deploy, test
   Tools    (1): railway
   CLAUDE.md: ❌ Missing — will be generated
```

---

## Per-File Adaptation Logic

### CLAUDE.md
Always generate fresh. Never adapt an existing CLAUDE.md — it may be the generic template.
→ Use `claude-md-template.md` with intake answers.

### skills/*.md

For each skill file:
1. Read the `description:` frontmatter
2. Identify project-irrelevant generic phrases (e.g., "Use when working with any project")
3. Rewrite to add project context: "Use in [PROJECT_NAME] when..."
4. If the skill references tools not in the project stack → add a note: "Note: In [PROJECT_NAME], this skill is used with [STACK_TOOL]"
5. Body of the skill: leave untouched

Example transformation:
```yaml
# BEFORE (generic)
description: >
  Use this skill when creating Word documents or .docx files.

# AFTER (project-adapted)
description: >
  Use in ServiConnect when generating client-facing call reports, 
  agent handoff summaries, or partner documentation as .docx files.
```

### agents/*.md

For each agent file:
1. Rewrite `## Role` — add the project name and specific responsibility
2. Rewrite `## Triggers` — replace generic triggers with real scenarios from Q4
3. Keep `## Tools`, `## Inputs`, `## Outputs`, `## Constraints`, `## Handoff` — only update project-specific references (URLs, service names, DB names)

Example:
```markdown
# BEFORE
## Role
Reviews code changes and provides feedback.

# AFTER
## Role
Reviews pull requests in the ServiConnect repo, focusing on voice routing 
logic correctness, Telnyx API integration patterns, and n8n workflow validity.
```

### commands/*.md

For each command file:
1. Rewrite `## What It Does` — add project name and specific action
2. Rewrite `## Steps Claude Executes` — replace generic steps with stack-specific commands
   - "run tests" → "run `npm test` in /packages/api and report failures"
   - "deploy" → "run `./deploy.sh --env production` and tail Railway logs"
3. Update `## Example` — use a realistic project example, not a placeholder

### tools/*.md

For each tool file:
1. Update any hardcoded service names to match the project
2. Update env var names to match Q9
3. Update URLs/endpoints to match the project's actual services
4. Keep tool capability descriptions unchanged

---

## New Component Generation (during bootstrap)

If user requests new components not in the starter:

| Component | Action |
|-----------|--------|
| New skill | Run skill intake (name, purpose, triggers) → generate SKILL.md → add to `.claude/skills/` |
| New agent | Run agent intake (name, role, tools needed) → generate agent.md using agent-template.md |
| New command | Run command intake (name, what it does, steps) → generate command.md using command-template.md |
| New tool | Ask: tool name, what API/service, key operations → generate tool.md |

After generating new components, ask: "Push this to claude-starter as well?" 
If yes → provide the git subtree push command.

---

## Bootstrap Completion Report

After all files are adapted, output:

```
✓ Bootstrap complete for [PROJECT_NAME]

  Generated:
  └── CLAUDE.md

  Adapted:
  ├── skills/docx.md          (description updated)
  ├── skills/n8n-workflows.md (description + stack refs updated)
  ├── skills/supabase.md      (description + DB name updated)
  ├── agents/reviewer.md      (role + triggers scoped)
  ├── agents/deployer.md      (role + Railway service name updated)
  ├── commands/deploy.md      (steps updated for Node + Railway)
  └── commands/test.md        (steps updated for npm test)

  Added:
  └── skills/serviconnect-routing.md (new)

Next steps:
  • Review CLAUDE.md and confirm it reflects your project correctly
  • Run /deploy to push to Railway (if configured)
  • To push new components back to claude-starter:
    git subtree push --prefix .claude https://github.com/you/claude-starter.git main
```
