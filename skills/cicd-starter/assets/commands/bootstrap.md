# /bootstrap

## What It Does
Adapts the `.claude/` folder pulled from `claude-starter` to the current project.
Scans existing skills, agents, commands, and tools — runs a short intake — then
rewrites all components to be project-specific. Generates a fresh CLAUDE.md.
Optionally adds new components not in the starter.

## Usage
```
/bootstrap
```

No arguments. Run this once after pulling claude-starter into a new project,
and again after any `git subtree pull` update.

## Steps Claude Executes

1. Scan `.claude/` — inventory all existing files by category
2. Report findings to user (skills found, agents found, etc.)
3. Run the short-form intake (project name, description, stack, workflows, rules)
4. Ask if new components are needed beyond what the starter provides
5. Adapt all existing files to the project context (descriptions, roles, steps)
6. Generate CLAUDE.md from scratch using intake answers
7. Generate any new components requested
8. Output completion report with full list of what was adapted/added
9. Suggest git subtree push command if new generic components were created

## Output
- Updated `.claude/` folder with all files adapted to the project
- Fresh `CLAUDE.md` at the project root
- Completion report listing every file touched
- Optional: git command to push new components back to claude-starter

## Idempotent
Safe to run multiple times. Re-running re-adapts from the current intake answers.
Only CLAUDE.md is fully regenerated — other files have only their project-specific
sections updated (descriptions, role names, trigger conditions, stack references).

## After Running
Review CLAUDE.md to confirm it reflects your project accurately.
If Railway deployment is needed, run `/deploy` to initialize the deployment config.
