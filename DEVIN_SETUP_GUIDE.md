# Devin IDE Setup Guide — CKS-Inspired Workflow System

## What You Get

A 5-phase feature lifecycle (discover → design → sprint → review → release) adapted from CKS for Devin IDE, using:

- **Windsurf IDE workflows** (`.devin/workflows/`) — slash commands in your IDE
- **Devin Playbooks** (`devin-playbooks/`) — reusable prompts for Devin sessions
- **Devin Knowledge** (`devin-knowledge/`) — persistent context across sessions
- **State management** (`.devin/`) — JSON state schema and artifact templates

## Quick Start

### For Vibe Coders (Don't Want to Think About Commands?)

**You only need one thing: `/vibe-build`**

Just type `/vibe-build` and describe what you want. The system handles everything:
- Figures out if it's a new feature or a bug fix
- Runs all 5 phases automatically
- Only stops to ask you questions or confirm risky actions
- Auto-advances between phases — you never run commands
- Explains everything in plain English
- Shows you a clear "DONE!" message when finished

**In Windsurf IDE:** Type `/vibe-build` and describe what you want to build.

**In Devin:** Copy "Playbook 0: Vibe Build" from `devin-playbooks/PLAYBOOKS.md`, paste it as your prompt, and replace `[describe what you want to build]` with your idea.

### For Everyone Else

### 1. Workflows Are Ready

The `.devin/workflows/` directory is already created. In Windsurf IDE, you can now use:
- `/vibe-build` — **Just tell me what you want** (handles everything automatically)
- `/audit` — Audit codebase for quality, security, performance, and maintainability
- `/investigate` — Investigate an issue — find root cause, explain, propose fix
- `/new-feature` — Create a feature and start discover
- `/discover` — Phase 1: Gather requirements
- `/design` — Phase 2: UX and component design
- `/sprint` — Phase 3: Plan, implement, verify, merge
- `/review` — Phase 4: Review and iteration decision
- `/release` — Phase 5: Deploy through environments
- `/lifecycle` — Run all 5 phases autonomously
- `/status` — Show project dashboard

### 2. Set Up Devin Knowledge

Add knowledge items from `devin-knowledge/KNOWLEDGE_ITEMS.md` to Devin's Knowledge system:
1. Go to Devin Settings & Library → Knowledge
2. Click "Create Knowledge"
3. For each item in the file:
   - Set the trigger description
   - Paste the content
   - Pin to all repositories (or specific repos)

### 3. Set Up Devin Playbooks

Use playbooks from `devin-playbooks/PLAYBOOKS.md` in Devin sessions:
1. Copy the playbook content
2. Paste as your prompt in a Devin session
3. Replace `[feature_name]` and `[describe your feature]` with your details

### 4. Configure Devin Repo

Follow `devin-config/REPO_SETUP.md` to configure Devin's environment:
1. Go to Devin's Machine → Add repository
2. Follow the setup wizard
3. Use the Additional Notes from the config file

## File Structure

```
.devin/
  workflows/              — Windsurf IDE slash commands
    new-feature.md        — /new-feature
    discover.md           — /discover
    design.md             — /design
    sprint.md             — /sprint
    review.md             — /review
    release.md            — /release
    lifecycle.md          — /lifecycle
    status.md             — /status
  templates/              — Artifact templates
    context-template.md
    design-template.md
    plan-template.md
    verification-template.md
    review-template.md
    release-template.md
  state-schema.json       — JSON schema for state
  initial-state.json      — Default state file

devin-playbooks/
  PLAYBOOKS.md            — 10 reusable Devin prompts

devin-knowledge/
  KNOWLEDGE_ITEMS.md      — 9 knowledge items to add to Devin

devin-config/
  REPO_SETUP.md           — Devin repo configuration guide
```

## How It Works

### In Windsurf IDE (Cascade)

Use the slash commands directly:
```
/new-feature "user authentication"
/discover
/design
/sprint
/review
/release
/status
```

### In Devin (Cognition)

Use playbooks as prompts:
1. Start a Devin session
2. Paste the relevant playbook from `devin-playbooks/PLAYBOOKS.md`
3. Devin follows the workflow, reads state, and produces artifacts

### State Persistence

State is stored in `.phases/PRD-STATE.json`. Both Windsurf IDE and Devin read/write the same state file, so you can switch between tools seamlessly.

## CKS → Devin Mapping

| CKS Component | Devin Equivalent | Location |
|---------------|------------------|----------|
| Commands (135) | Workflows (8) | `.devin/workflows/` |
| Agents (173) | Playbooks (10) | `devin-playbooks/` |
| Skills (657) | Knowledge items (9) | `devin-knowledge/` |
| Hooks (28) | Repo config | `devin-config/` |
| State (.prd/) | State (.phases/) | `.devin/state-schema.json` |
| CLAUDE.md | AGENTS.md | Auto-read by Devin |

## Key Differences from CKS

### Simplified
- 8 workflows instead of 135 commands
- 10 playbooks instead of 173 agents
- 9 knowledge items instead of 657 skills
- File-based state instead of complex state machine

### Preserved
- 5-phase lifecycle (discover → design → sprint → review → release)
- Human-in-the-loop gates at phase transitions
- Quality gates at each phase
- TDD discipline
- Minimal changes principle
- Iteration loops with convergence
- State persistence and recovery
- Intent classification (Converse/Dispatch/Clarify)

### Adapted
- YAML workflow definitions → Markdown with frontmatter
- Claude Code plugin → Windsurf IDE native workflows
- MCP integration → Devin's native integrations
- Shell script hooks → Devin repo config
- Agent dispatch → Playbook prompts

## Testing the Setup

1. **Test workflows:** Run `/status` in Windsurf IDE — should show "No active feature"
2. **Test new feature:** Run `/new-feature "test feature"` — should create state and start discover
3. **Test state:** Check `.phases/PRD-STATE.json` was created
4. **Test Devin:** Paste a playbook into a Devin session — should follow the workflow
5. **Test knowledge:** Add a knowledge item to Devin — should be recalled when relevant

## Troubleshooting

### Workflow not appearing
- Ensure `.devin/workflows/` directory exists
- Restart Windsurf IDE
- Check workflow file has valid YAML frontmatter

### State not persisting
- Ensure `.phases/` directory is writable
- Check JSON is valid in `PRD-STATE.json`
- Verify state schema matches `.devin/state-schema.json`

### Devin not following workflow
- Ensure playbooks are pasted completely
- Check that Devin has repo access
- Verify knowledge items are added with correct triggers

## Next Steps

1. **Try it out:** Run `/new-feature "your first feature"` in Windsurf IDE
2. **Add knowledge:** Add all 9 knowledge items to Devin's Knowledge system
3. **Customize:** Edit workflows in `.devin/workflows/` to match your project
4. **Iterate:** Adjust playbooks based on what works well with Devin
