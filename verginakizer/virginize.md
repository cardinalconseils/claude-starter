# /virginize

## What It Does
Takes one or more project-specific `.claude/` files and strips all project-specific
content — replacing names, URLs, env vars, and stack references with generic tokens —
making them starter-ready for `claude-starter`. Shows a diff before saving anything.

## Usage
```
/virginize
```

No arguments. Claude will ask which files to process.

## Accepts
- Single file: one skill, agent, command, or tool
- Multiple files: list them — Claude processes all in one session
- Any combination of file types

## Steps Claude Executes

1. Ask user which files to virginize (paths or names)
2. Read all files in full
3. Scan each for project-specific content — report findings per file
4. Show before/after diff for each file — wait for confirmation
5. Apply replacements: project names → `[PROJECT_NAME]`, URLs → `[PROJECT_URL]`, etc.
6. Verify output passes quality checks (zero project-specific content remaining)
7. Write virginized files to `starter-ready/` folder preserving subfolder structure
8. Print git commands to add them to `claude-starter`

## Output Location
```
starter-ready/
├── skills/    ← virginized skills
├── agents/    ← virginized agents
├── commands/  ← virginized commands
└── tools/     ← virginized tools
```

## Guarantees
- Never modifies original files — virginized copies go to `starter-ready/`
- Never saves without showing diff first
- Preserves full file structure — only content values change
- Quality check: zero project-specific strings in output

## Example
```
/virginize
→ Which files? 
→ .claude/agents/deployer.md, .claude/commands/deploy.md

Scanning deployer.md... 7 project-specific strings found
Scanning deploy.md... 3 project-specific strings found

[shows diff for each]

✓ 2 files virginized → starter-ready/
  git commands to add to claude-starter →  [printed]
```
