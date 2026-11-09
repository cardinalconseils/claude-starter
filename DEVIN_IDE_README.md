# CKS-Inspired Workflow System for Devin IDE

## Overview

A Devin IDE-native workflow system inspired by CKS (Claude Code Starter Kit) principles, adapted for platform strengths rather than direct migration.

## Philosophy

**Extract the patterns, not the code.**

CKS encodes senior engineering discipline into a Claude Code plugin. The value is in the methodology (5-phase lifecycle, quality gates, human-in-the-loop), not the specific implementation. This document provides a Devin IDE-native implementation that follows CKS principles while leveraging Devin IDE's capabilities.

## Documents

### 1. CKS Principles
**File:** `CKS_PRINCIPLES.md`

Core principles extracted from CKS:
- Thin dispatchers, fat agents
- 5-phase feature lifecycle
- State on disk, context resettable
- Human-in-the-loop gates
- Quality gates at every phase
- Minimal impact, root cause fixes
- Progressive disclosure
- Intent classification

### 2. Workflow Architecture
**File:** `DEVIN_WORKFLOW_ARCHITECTURE.md`

Complete architecture for Devin IDE:
- Workflow Orchestrator (intent classification, routing, state management)
- 5-Phase Workflows (discover, design, sprint, review, release)
- Agent System (specialist agents with knowledge bases)
- Knowledge Base System (domain expertise)
- State Management (persistent state schema)
- Event System (guards, logging)
- Confirmation System (human-in-the-loop)

### 3. Proof of Concept
**File:** `POC_DISCOVER_WORKFLOW.md`

Minimal implementation of the Discover workflow:
- State schema (JSON)
- Discover workflow definition (YAML)
- Discoverer agent template
- Knowledge base example (requirements gathering)
- Context template (markdown)
- Simplified orchestrator and agent execution
- Usage examples
- Testing checklist

### 4. Agent Templates
**File:** `DEVIN_AGENT_TEMPLATES.md`

Templates for all specialist agents:
- Base agent template
- Discoverer agent (requirements gathering)
- Designer agent (UX and components)
- Planner agent (technical design and TDD)
- Executor agent (implementation)
- Verifier agent (QA and acceptance criteria)
- Reviewer agent (code review and retro)
- Deployer agent (deployment through environments)
- Orchestrator agent (coordination and routing)

## Quick Start

### 1. Understand the Architecture

Read `DEVIN_WORKFLOW_ARCHITECTURE.md` to understand:
- Component relationships
- Data flow
- State management
- Event system

### 2. Implement the Foundation

Follow the implementation priority from the architecture document:
1. State schema and storage
2. State machine implementation
3. Basic orchestrator (intent classification)
4. Confirmation system

### 3. Build the First Workflow

Use `POC_DISCOVER_WORKFLOW.md` as a guide:
1. Implement state manager using Devin IDE's storage API
2. Create agent registry and agent factory
3. Build knowledge base loader
4. Implement confirmation system integration
5. Create workflow loader from YAML
6. Test end-to-end with a simple feature

### 4. Expand to Other Phases

After Discover is working:
1. Design workflow (use agent templates)
2. Sprint workflow (planner, executor, verifier)
3. Review workflow (reviewer, iteration logic)
4. Release workflow (deployer, quality gates)

## Key Differences from CKS

### What We Kept

- **5-phase lifecycle:** discover → design → sprint → review → release
- **Human-in-the-loop:** Confirmation at critical decisions
- **Quality gates:** Verification at each phase
- **State on disk:** Persistent, recoverable state
- **Specialist agents:** One agent per domain
- **Minimal changes:** Prefer simple fixes
- **Iteration loops:** Handle feedback gracefully

### What We Changed

- **Platform-native:** Uses Devin IDE's APIs instead of Claude Code plugin system
- **YAML over Markdown:** Workflow definitions in YAML for better parsing
- **JSON state:** Structured state schema instead of markdown
- **Simplified hooks:** Event system instead of shell scripts
- **Knowledge bases:** Explicit knowledge base system instead of skill frontmatter
- **Confirmation system:** Uses Devin IDE's dialog system

### What We Removed

- **MCP dependency:** Platform-specific integrations instead
- **Shell script hooks:** Native event handlers
- **Plugin manifest:** No plugin.json needed
- **173 agents:** Focused on 8 core agents
- **657 skills:** Focused on core knowledge bases

## Implementation Checklist

### Phase 1: Foundation
- [ ] Research Devin IDE's storage API
- [ ] Research Devin IDE's agent system
- [ ] Research Devin IDE's command system
- [ ] Research Devin IDE's dialog/confirmation system
- [ ] Implement state schema
- [ ] Implement state manager
- [ ] Implement state machine
- [ ] Implement basic orchestrator

### Phase 2: Discover Workflow
- [ ] Implement discoverer agent
- [ ] Create requirements knowledge base
- [ ] Implement workflow loader
- [ ] Implement confirmation integration
- [ ] Test discover workflow end-to-end
- [ ] Verify state persistence
- [ ] Verify context recovery

### Phase 3: Other Workflows
- [ ] Implement designer agent
- [ ] Implement planner agent
- [ ] Implement executor agent
- [ ] Implement verifier agent
- [ ] Implement reviewer agent
- [ ] Implement deployer agent
- [ ] Test each workflow independently
- [ ] Test workflow transitions

### Phase 4: Orchestration
- [ ] Implement intent classifier
- [ ] Implement workflow router
- [ ] Implement iteration logic
- [ ] Test full lifecycle end-to-end
- [ ] Test iteration loops
- [ ] Test error recovery

### Phase 5: Quality
- [ ] Implement guard rails
- [ ] Implement event system
- [ ] Add logging
- [ ] Add monitoring
- [ ] Create documentation
- [ ] Create examples

## Success Criteria

- [ ] State persists across sessions
- [ ] 5-phase workflows operational
- [ ] Intent classification working
- [ ] Confirmation system functional
- [ ] Iteration loops working
- [ ] Quality gates enforced
- [ ] Guard rails active
- [ ] Context recovery working
- [ ] End-to-end lifecycle tested

## Open Questions

Before implementation, research these Devin IDE capabilities:

1. **Storage API:** How does Devin IDE handle persistent storage?
2. **Agent System:** How do you define and register agents in Devin IDE?
3. **Command System:** How do you define commands in Devin IDE?
4. **Dialog System:** How do you request user confirmation in Devin IDE?
5. **Event System:** What events does Devin IDE support? How to register handlers?
6. **UI Generation:** Does Devin IDE have native UI generation, or need integration?
7. **Model Selection:** How does Devin IDE handle model selection for agents?

## Next Steps

1. **Research:** Answer the open questions above by exploring Devin IDE's documentation and APIs
2. **Proof of Concept:** Implement the Discover workflow using the POC document
3. **Iterate:** Expand to other phases based on learnings from the POC
4. **Document:** Update these documents with Devin IDE-specific details as you implement

## References

- Original CKS: `/Users/pmc/Documents/DEV/Claude-Starter/`
- CKS Principles: `CKS_PRINCIPLES.md`
- Workflow Architecture: `DEVIN_WORKFLOW_ARCHITECTURE.md`
- Discover POC: `POC_DISCOVER_WORKFLOW.md`
- Agent Templates: `DEVIN_AGENT_TEMPLATES.md`
- Original Migration Plan: `DEVIN_IDE_MIGRATION.md` (for reference only)

## Support

For questions about:
- **Architecture:** See `DEVIN_WORKFLOW_ARCHITECTURE.md`
- **Implementation details:** See `POC_DISCOVER_WORKFLOW.md`
- **Agent design:** See `DEVIN_AGENT_TEMPLATES.md`
- **CKS principles:** See `CKS_PRINCIPLES.md`
