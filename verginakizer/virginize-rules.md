# Virginize Rules — Extended Reference

Edge cases, examples, and per-file-type guidance for the /virginize command.

---

## Token Replacement Reference

| Detected pattern | Replace with | Notes |
|---|---|---|
| Specific project name | `[PROJECT_NAME]` | All occurrences, all cases |
| Production URL | `[PROJECT_URL]` | Strip https:// too if isolated |
| Staging URL | `[STAGING_URL]` | |
| Specific env var name | `[ENV_VAR_NAME]` | Name only, never values |
| DB name | `[DATABASE_NAME]` | |
| Table name | `[TABLE_NAME]` | Only if project-specific |
| Railway service name | `[RAILWAY_SERVICE]` | |
| GitHub repo URL | `[GITHUB_REPO_URL]` | |
| Branch name (project-specific) | `[MAIN_BRANCH]` | Keep "main" / "master" as-is |
| Team/person name | `[TEAM]` or `[OWNER]` | |
| Specific file path | `[PROJECT_PATH]` | |
| Stack tool (if project-specific) | `[STACK_TOOL]` | Only if not universally applicable |

---

## Per-File-Type Rules

### Skills (skills/*.md)

```yaml
# BEFORE
description: >
  Use in ServiConnect when generating call routing reports or
  partner handoff summaries as .docx files.

# AFTER
description: >
  Use when generating structured documents, reports, or summaries
  as .docx files for any project requiring Word document output.
```

- Frontmatter `description:` → always fully rewritten, no project context
- Body instructions → keep generic; replace only hardcoded strings
- If the skill references a specific API endpoint → replace with `[API_ENDPOINT]`

### Agents (agents/*.md)

```markdown
# BEFORE
## Role
Reviews PRs in the ServiConnect repo, focusing on Telnyx voice routing
logic and n8n webhook validity.

## Triggers
- When a PR is opened targeting the `serviconnect-api` package
- When routing logic in `/src/router/` is modified

# AFTER
## Role
Reviews pull requests in [PROJECT_NAME], focusing on [STACK_TOOL]
integration patterns and core business logic correctness.

## Triggers
- When a PR is opened targeting the primary application package
- When core routing or business logic files are modified
```

- Role → keep the agent's capability, remove the project scope
- Triggers → keep the trigger pattern, replace specific paths/names
- Constraints → keep all "never do" rules — they're usually generic
- Handoff → replace specific team/person names with `[TEAM]`

### Commands (commands/*.md)

```markdown
# BEFORE
## Steps Claude Executes
1. Run `npm test` in /packages/serviconnect-api
2. Check Telnyx webhook signature validation tests pass
3. Report failures to #serviconnect-dev Slack channel

# AFTER
## Steps Claude Executes
1. Run the project test suite in the primary application package
2. Verify integration and unit tests pass
3. Report failures with full error output
```

- Steps → replace specific commands with generic descriptions
- Keep the step COUNT and structure identical
- Arguments table → replace specific arg names if project-specific
- Example section → replace with `[PROJECT_NAME]` placeholder example

### Tools (tools/*.md)

```markdown
# BEFORE
## Connection
Railway service: serviconnect-prod
Project ID: abc123xyz
Dashboard: https://railway.app/project/abc123xyz

# AFTER
## Connection
Railway service: [RAILWAY_SERVICE]
Project ID: [RAILWAY_PROJECT_ID]
Dashboard: https://railway.app/project/[RAILWAY_PROJECT_ID]
```

- All IDs, tokens, project-specific identifiers → tokenize
- Capability descriptions → keep as-is (generic by nature)
- Setup instructions → keep, they're universal

---

## What NOT to Virginize

Some content looks project-specific but is actually generic — do NOT replace:

- Common package names (`npm`, `node_modules`, `requirements.txt`)
- Standard branch names (`main`, `master`, `develop`)
- Universal file names (`package.json`, `Dockerfile`, `.env`)
- Standard HTTP methods, status codes
- Generic tool names (`Railway`, `Supabase`, `GitHub`) — these are universal
- Standard directory conventions (`/src`, `/dist`, `/tests`)

---

## Multi-File Session

When virginizing multiple files in one session:

1. Scan ALL files first — report findings for all before touching any
2. Present a combined confirmation:
   ```
   Ready to virginize 3 files:
     skills/my-skill.md    → 4 replacements
     agents/deployer.md    → 7 replacements
     commands/deploy.md    → 3 replacements
   
   Proceed with all? (yes / review one by one)
   ```
3. If "yes" → virginize all, output to `starter-ready/`
4. If "review one by one" → show per-file diff and confirm each

---

## Edge Case: Partially Generic Files

Some files may be 80% generic already (e.g., a docx skill with only the description needing a rewrite). In this case:

- Report: "This file is mostly starter-ready. Only 1 change needed."
- Show the single change
- Don't over-engineer — minimal surgery is better

## Edge Case: File Has No Project-Specific Content

```
Scanning: .claude/skills/docx.md
  ✓ No project-specific content detected
  ✓ Already starter-ready

No changes needed. Copy directly to claude-starter.
```

Output the file unchanged with a note that it needed no virginization.
