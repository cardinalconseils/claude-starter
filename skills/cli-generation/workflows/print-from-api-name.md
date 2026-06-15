# Workflow: Generate from API Name

## When to Use

User provided `--api <name>` or selected a named API via `AskUserQuestion`.

## Steps

### 1. Run the generator

```bash
printing-press print --api <name>
```

Capture exit code. If non-zero: show the error line (not full stdout) and stop.

### 2. Locate output

```bash
ls ~/printing-press/library/<name>/
```

Confirm: `SKILL.md`, `cmd/`, `mcp/` all present.

### 3. File the integration summary

Write `.prd/phases/{NN}/integrations/<name>.md` (if inside sprint):

```markdown
# Integration: <name> API

- CLI binary: `~/printing-press/library/<name>/cmd/<name>`
- MCP server: `~/printing-press/library/<name>/mcp/`
- Claude skill: `~/printing-press/library/<name>/SKILL.md`
- Generated: {ISO date}
- Compact flag: `<name> <subcommand> --compact` for agent-optimized output
```

### 4. Report to user

```
CLI generation complete.

API:    <name>
CLI:    ~/printing-press/library/<name>/cmd/<name>  ✓
MCP:    ~/printing-press/library/<name>/mcp/        ✓
Skill:  ~/printing-press/library/<name>/SKILL.md    ✓
Filed:  .prd/phases/{NN}/integrations/<name>.md     ✓
```
