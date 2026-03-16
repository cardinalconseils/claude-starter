# /review

## What It Does
Triggers the Reviewer Agent on a pull request or set of files in [PROJECT_NAME].
Returns a structured code review with issues ranked by severity.

## Usage
```
/review [pr_url or file_path] [--focus security|performance|logic]
```

## Arguments
| Argument | Required | Description |
|----------|----------|-------------|
| `pr_url` or `file_path` | Yes | PR URL or specific file to review |
| `--focus` | No | Narrow review to a specific concern |

## Steps Claude Executes

1. Read the PR diff or file contents
2. Invoke the Reviewer Agent with the content and optional focus
3. Structure findings by severity: blocking / warning / suggestion
4. Return review with: summary, issues list, approval recommendation

## Output
```
Review: [PROJECT_NAME] — [PR title or file name]

Summary: [2-sentence overview]

Blocking (must fix before merge):
  • [Issue] — [file:line]

Warnings (should fix):
  • [Issue] — [file:line]

Suggestions (nice to have):
  • [Suggestion]

Recommendation: [Approve / Request Changes]
```

## Example
```
/review https://github.com/[org]/[repo]/pull/42
/review src/router/index.ts --focus logic
```

## Constraints
- Never approve if blocking issues exist
- Always include file and line reference for each issue
- Scope review strictly to what was changed — no out-of-scope critique
