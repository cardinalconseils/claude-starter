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

### 2. Adapt to your project

Open Claude Code in your project and run:

```
/bootstrap
```

Claude will scan the `.claude/` folder, ask you 5 questions, and adapt every file to your project context. CLAUDE.md is generated fresh.

### 3. Keep it updated

```bash
# Pull new components from starter
git subtree pull \
  --prefix .claude \
  https://github.com/cardinalconseils/claude-starter.git main \
  --squash

# Then re-adapt
/bootstrap
```

### 4. Contribute back

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
