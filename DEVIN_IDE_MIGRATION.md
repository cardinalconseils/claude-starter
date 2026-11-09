# CKS → Devin IDE Migration Plan

## Executive Summary

This document maps the CKS (Claude Code Starter Kit) architecture to Devin IDE concepts for reproduction.

## CKS Architecture Overview

CKS is a Claude Code plugin that provides:
- **173 agents** (YAML frontmatter + system prompt)
- **135 commands** (Markdown dispatchers)
- **657 skills** (domain expertise)
- **Hook system** (event-driven automation)
- **5-phase lifecycle**: discover → design → sprint → review → release

### Core Pattern

```
Command (thin dispatcher, ~40 lines)
  → Agent (skills: loaded at startup, tools: declared in frontmatter)
    → Skill (domain expertise, read by agent)
      → Workflow (progressive disclosure, read on demand)
Hook (automation: logging, guarding — no agent dispatch)
```

## Component Mapping

### 1. Commands → Devin IDE Commands

**CKS Structure:**
```markdown
---
description: "Command description"
argument-hint: "[args]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:command

Command body (thin dispatcher)
```

**Devin IDE Equivalent:**
- Devin IDE likely has a command system
- Map CKS commands to Devin IDE command format
- Preserve argument parsing and dispatch logic

**Migration Strategy:**
1. Extract command metadata (description, arguments, allowed tools)
2. Convert to Devin IDE command schema
3. Preserve thin dispatcher pattern
4. Update command count in README

### 2. Agents → Devin IDE Agents

**CKS Structure:**
```markdown
---
name: agent-name
subagent_type: cks:agent-name
description: "Agent description"
tools:
  - Read
  - Write
  - Bash
  - Agent
model: opus
color: purple
skills:
  - skill-name
  - another-skill
---

# Agent Name

System prompt instructions
```

**Devin IDE Equivalent:**
- Devin IDE likely has an agent system
- Map CKS agent frontmatter to Devin IDE agent schema
- Preserve skills loading and tool declarations
- Convert system prompts to Devin IDE format

**Migration Strategy:**
1. Extract agent metadata (name, tools, model, skills)
2. Convert to Devin IDE agent schema
3. Preserve skill loading mechanism
4. Update agent count in README

### 3. Skills → Devin IDE Skills/Knowledge

**CKS Structure:**
```
skills/
  skill-name/
    SKILL.md (frontmatter + domain knowledge)
    workflows/
      workflow-name.md
    references/
      reference.md
```

**Devin IDE Equivalent:**
- Devin IDE likely has a skills/knowledge system
- Map CKS skills to Devin IDE knowledge format
- Preserve progressive disclosure pattern
- Maintain domain expertise

**Migration Strategy:**
1. Extract skill metadata (name, description, allowed tools)
2. Convert to Devin IDE knowledge schema
3. Preserve workflow and reference structure
4. Update skill count in README

### 4. Hooks → Devin IDE Event Handlers

**CKS Structure:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/handlers/session-start.sh"
      }
    ],
    "PreToolUse": [
      {
        "matcher": "tool == \"Bash\"",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/handlers/destructive-op-guard.sh"
          }
        ]
      }
    ]
  }
}
```

**Devin IDE Equivalent:**
- Devin IDE likely has an event system
- Map CKS hooks to Devin IDE event handlers
- Preserve guard logic and automation
- Convert shell scripts to Devin IDE format

**Migration Strategy:**
1. Extract hook metadata (event type, matcher, command)
2. Convert to Devin IDE event handler schema
3. Preserve guard logic (destructive-op, secrets-scan, etc.)
4. Convert shell scripts to native Devin IDE logic where possible

### 5. State Management → Devin IDE State

**CKS State Files:**
- `.prd/PRD-STATE.md` (project state)
- `.prd/PRD-ROADMAP.md` (feature roadmap)
- `.prd/PRD-PROJECT.md` (project metadata)
- `.cks/concierge-state.json` (conversation state)
- `.prd/phases/{NN}-{slug}/` (phase artifacts)

**Devin IDE Equivalent:**
- Devin IDE likely has a state management system
- Map CKS state files to Devin IDE state schema
- Preserve state machine transitions
- Maintain artifact tracking

**Migration Strategy:**
1. Extract state schema from CKS tools/
2. Convert to Devin IDE state format
3. Preserve state machine logic
4. Maintain artifact tracking

## 5-Phase Lifecycle Implementation

### Phase 1: Discover
**CKS:** `/cks:discover` → `prd-discoverer` agent → 11 elements
**Devin IDE:** Map to equivalent command/agent flow

### Phase 2: Design
**CKS:** `/cks:design` → `prd-designer` agent → Stitch MCP screens
**Devin IDE:** Map to equivalent command/agent flow (may need different screen generation)

### Phase 3: Sprint
**CKS:** `/cks:sprint` → planner → executor → verifier (convergence loop)
**Devin IDE:** Map to equivalent command/agent flow

### Phase 4: Review
**CKS:** `/cks:review` → feedback + retro + iteration decision
**Devin IDE:** Map to equivalent command/agent flow

### Phase 5: Release
**CKS:** `/cks:release` → env promotion + quality gates
**Devin IDE:** Map to equivalent command/agent flow

## Key Differences to Address

### 1. Plugin vs Native
- **CKS:** Claude Code plugin (installed via `/plugin add`)
- **Devin IDE:** Likely native integration
- **Impact:** Installation process, plugin.json manifest

### 2. MCP Integration
- **CKS:** Uses MCP servers (Stitch, GitHub, etc.)
- **Devin IDE:** May have different integration model
- **Impact:** Screen generation, GitHub sync, etc.

### 3. Shell Script Hooks
- **CKS:** Bash scripts for hook handlers
- **Devin IDE:** May prefer native code
- **Impact:** Hook implementation language

### 4. Model Routing
- **CKS:** Custom model strategy (opus/sonnet/haiku per tier)
- **Devin IDE:** May have different model selection
- **Impact:** Agent model assignments

## Migration Steps

### Phase 1: Foundation
1. Create Devin IDE project structure
2. Set up basic command/agent/skill schemas
3. Implement state management system
4. Create event handler framework

### Phase 2: Core Agents
1. Migrate concierge agent (intent routing)
2. Migrate PRD orchestrator (lifecycle driver)
3. Migrate phase-specific agents (discoverer, designer, etc.)
4. Test agent dispatch and skill loading

### Phase 3: Commands
1. Migrate core commands (/cks:new, /cks:discover, etc.)
2. Migrate utility commands (/cks:status, /cks:help, etc.)
3. Test command parsing and dispatch
4. Update command documentation

### Phase 4: Skills
1. Migrate core skills (prd, concierge, caveman, etc.)
2. Migrate domain skills (authentication, payments, etc.)
3. Test skill loading and workflow execution
4. Update skill documentation

### Phase 5: Hooks
1. Migrate SessionStart hook (status display)
2. Migrate PreToolUse hooks (guards)
3. Migrate PostToolUse hooks (logging)
4. Migrate Stop hook (cleanup)
5. Test event handler execution

### Phase 6: Integration
1. Implement 5-phase lifecycle end-to-end
2. Test iteration loops
3. Test state persistence
4. Test multi-session coordination
5. Documentation and examples

## Success Criteria

- [ ] All 173 agents migrated and functional
- [ ] All 135 commands migrated and functional
- [ ] Core skills (top 50) migrated and functional
- [ ] Hook system operational
- [ ] 5-phase lifecycle working end-to-end
- [ ] State management functional
- [ ] Iteration loops working
- [ ] Documentation complete

## Open Questions

1. **Devin IDE Command Schema:** What is the exact format for commands in Devin IDE?
2. **Devin IDE Agent Schema:** What is the exact format for agents in Devin IDE?
3. **Devin IDE Skill System:** Does Devin IDE have a skills/knowledge system? How does it work?
4. **Devin IDE Event System:** What events does Devin IDE support? How are handlers registered?
5. **Devin IDE State Management:** How does Devin IDE handle persistent state?
6. **MCP Integration:** Does Devin IDE support MCP servers? If not, what's the alternative?
7. **Model Selection:** How does Devin IDE handle model selection for agents?

## Next Steps

1. **Research Devin IDE APIs:** Document Devin IDE's command, agent, skill, event, and state systems
2. **Create Proof of Concept:** Implement a minimal CKS-like flow in Devin IDE (e.g., single command → single agent → single skill)
3. **Iterative Migration:** Migrate components incrementally, testing each before moving to the next
4. **Documentation:** Create Devin IDE-specific documentation as migration progresses

## References

- CKS CLAUDE.md: `/Users/pmc/Documents/DEV/Claude-Starter/CLAUDE.md`
- CKS AGENTS.md: `/Users/pmc/Documents/DEV/Claude-Starter/AGENTS.md`
- CKS Plugin Manifest: `/Users/pmc/Documents/EV/Claude-Starter/.claude-plugin/plugin.json`
- CKS Hooks Config: `/Users/pmc/Documents/DEV/Claude-Starter/hooks/hooks.json`
- CKS PRD Skill: `/Users/pmc/Documents/DEV/Claude-Starter/skills/prd/SKILL.md`
- CKS Concierge Skill: `/Users/pmc/Documents/DEV/Claude-Starter/skills/concierge/SKILL.md`
