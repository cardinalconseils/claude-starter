# claude-starter

A reusable `.claude/` architecture — skills, agents, commands, and tools — designed to be pulled into any project via git subtree and adapted with a single `/bootstrap` command.

---

## What's Inside

```
.claude/
├── skills/          ← Reusable Claude skill definitions
├── agents/          ← Sub-agent role definitions
├── commands/        ← Slash commands (including /bootstrap)
└── tools/           ← Tool and integration references
```

No project-specific content. Everything is a template ready to be adapted.

---

## Full Product Lifecycle

```
/kickstart → /bootstrap → /prd:discuss → /prd:plan → /prd:execute → /prd:verify → /prd:ship
 discover     scaffold     refine         plan         build          test          deliver
```

| Command | What It Does |
|---------|-------------|
| `/kickstart` | Takes an idea through guided Q&A, optional market research (Perplexity), optional monetization analysis, then generates PRD + ERD + architecture. Hands off to `/bootstrap`. |
| `/bootstrap` | Adapts all `.claude/` files to the project. Generates `CLAUDE.md`. |
| `/monetize` | Business model evaluation — scores 12 revenue models with competitor research. |
| `/prd:discuss` | Deep-dive a specific feature with interactive discovery. |
| `/prd:plan` | Write the execution plan from discovery context. |
| `/prd:execute` | Build the feature. |
| `/prd:verify` | Check acceptance criteria pass. |
| `/prd:ship` | Commit, PR, review, deploy. |
| `/prd:autonomous` | Chain discuss → plan → execute → verify → ship automatically. |

## How to Use

### 1. Pull into an existing project

From the root of your git project:

```bash
git subtree add \
  --prefix .claude \
  https://github.com/cardinalconseils/claude-starter.git main \
  --squash
```

> **Note:** This must be run inside an existing git repository. If your project isn't a git repo yet, run `git init && git commit --allow-empty -m "init"` first.

### 2. Start your project

**Starting from an idea?** Run `/kickstart` — it guides you through discovery, generates design artifacts, and hands off to `/bootstrap`.

**Already know your project?** Run `/bootstrap` directly — it asks 5 questions and adapts every file to your project context.

```
/kickstart "An AI-powered invoice tool for freelancers"
# or
/bootstrap
```

### 3. Optional: API keys

Add to `.env.local` for deep research and monetization features:
```
PERPLEXITY_API_KEY=your-key-here
```

### 4. Keep it updated

```bash
# Pull new components from starter
git subtree pull \
  --prefix .claude \
  https://github.com/cardinalconseils/claude-starter.git main \
  --squash

# Then re-adapt
/bootstrap
```

### 5. Contribute back

Built something useful in a project? Push it back:

```bash
# Make sure the file is generic (no project-specific content)
git subtree push \
  --prefix .claude \
  https://github.com/cardinalconseils/claude-starter.git main
```

---

## Design Principles

- **Starter = generic only** — zero project-specific content ever lives here
- **Bootstrap = adaptation layer** — project context is applied at bootstrap time, not stored here
- **/bootstrap is idempotent** — safe to run after every `git subtree pull`
- **Subtree over submodule** — projects are self-contained; no runtime external dependency

---

## Adding to the Starter

1. Build and test the component in a project
2. Strip all project-specific references → make it generic
3. `git subtree push --prefix .claude https://github.com/cardinalconseils/claude-starter.git main`
4. Tag a release if it's a significant addition: `git tag v1.x.0`
