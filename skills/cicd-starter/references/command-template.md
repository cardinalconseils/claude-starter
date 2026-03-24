# Command Template Reference

Use this template for each command file in `.claude/commands/`.

---

## Template

```markdown
# /[command-name]

## What It Does
[1–2 sentences describing the exact action this command performs in this project.]

## Usage
```
/[command-name] [optional-argument]
```

## Arguments
| Argument | Required | Description |
|----------|----------|-------------|
| `[arg1]` | Yes/No | [what it is] |

(Omit table if command takes no arguments)

## Steps Claude Executes

1. [First action]
2. [Second action]
3. [Third action — include validation, error handling, output]

## Output
[What Claude produces or reports when the command completes]

## Example
```
/[command-name] [example-arg]
```
[What happens when this is run — 1–2 sentences]

## Constraints
- [What this command must NOT do]
- [Scope limit]
```

---

## Naming Convention

- File: `[command-name].md` — matches the slash command exactly
- Header: `/[command-name]`

## Adaptation Rules

- Steps must be specific to the project stack — not "run tests" but "run `npm test` and report failures in the format the CI system expects"
- Output section must describe actual artifacts, not generic descriptions
- If the command touches production, add an explicit confirmation step
- Commands suggested via "suggest" mode should be appropriate to the stack:
  - Next.js → /build /test /deploy /lint /preview
  - Python API → /test /migrate /deploy /lint /docs
  - n8n → /activate /test-workflow /export /deploy
  - Generic → /deploy /test /review /docs
