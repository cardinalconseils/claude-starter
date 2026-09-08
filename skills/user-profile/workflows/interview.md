# Workflow: Profile Interview — three batches that fill `~/.cks/user-profile.md`

A short guided interview. Every batch is an `AskUserQuestion` call; wait for each batch
before the next. The interviewing role returns the profile block; the historian writes
`~/.cks/user-profile.md` (its write scope), which the session banner then shows.

## Batch 1 — Identity

1. "How should Claude address you?" — free text
2. "What is your role?" — Founder · Developer · Designer · Product Manager · Other
3. "What is your technical level?" — I write code · I can read code · I avoid code

## Batch 2 — Style

4. "How do you prefer Claude to communicate?" — Terse (caveman default) · Normal prose ·
   Detailed with context
5. "Describe your current project or domain (SaaS, e-commerce, internal tools…)" — free text

## Batch 3 — Preferences

6. "What do you want to optimize for?" — multi: Speed to ship · Code quality · UX polish ·
   Cost efficiency · Security
7. "What are your pet peeves?" — multi: Verbose explanations · Over-engineering ·
   Assumptions without asking · Too many clarifying questions
8. "One thing you wish Claude knew about you" — free text

## Profile block (exact format)

```markdown
# CKS User Profile

name: <value>
role: <value>
technical_level: <value>
communication_style: <value>
domain: <value>
optimize_for: <comma-separated values>
pet_peeves: <comma-separated values>
notes: <value>
```

Skipped question → "not specified". Return the block with the target path
`~/.cks/user-profile.md` and the dispatch needed to write it.
