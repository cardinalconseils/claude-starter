# Workflow: Generate from Website (Sniff Mode)

## When to Use

User provided `--url <url>` or described an API that isn't in the printing-press catalog.

## Steps

### 1. Sniff the schema

```bash
printing-press sniff <url>
```

Capture stdout. This produces a detected API name and schema summary.

### 2. Confirm with user

Use `AskUserQuestion`:

```
question: "printing-press detected '<detected-name>' at <url>. Proceed with this name?"
options:
  - "Yes — generate <detected-name>"
  - "No — let me provide a different name"
```

If user provides a different name, use it.

### 3. Generate

```bash
printing-press print --api <confirmed-name>
```

Then follow `print-from-api-name.md` steps 2–4.

## Notes

- Sniff mode works best on public API documentation pages
- If sniff exits non-zero, report the error and suggest using `--api <name>` with a manually chosen name instead
- Never retry sniff automatically — surface the error and let the user decide
