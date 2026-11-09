# CKS Core Principles for Devin IDE Adaptation

## The Philosophy

CKS encodes **senior engineering discipline** into AI workflows. The value is in the methodology, not the specific Claude Code implementation.

## Core Principles

### 1. Thin Dispatchers, Fat Agents

**Pattern:**
- Commands are thin dispatchers (~40 lines)
- Agents contain the domain logic
- Skills provide reusable expertise

**Devin IDE Adaptation:**
- Create lightweight command handlers
- Build domain-specific agents
- Extract reusable knowledge bases

### 2. 5-Phase Feature Lifecycle

**Pattern:**
```
discover → design → sprint → review → release
```

**Each Phase:**
- Clear entry/exit criteria
- Artifact-based state tracking
- Iteration loops for quality

**Devin IDE Adaptation:**
- Implement as 5 separate workflows
- Use Devin IDE's state management
- Build iteration guardrails

### 3. State on Disk, Context Resettable

**Pattern:**
- All state in `.prd/` directory
- Context can be cleared without losing progress
- Filesystem is source of truth

**Devin IDE Adaptation:**
- Use Devin IDE's persistent storage
- Design state schema for workflows
- Implement context recovery

### 4. Human-in-the-Loop Gates

**Pattern:**
- Critical decisions require confirmation
- Use `AskUserQuestion` for all decisions
- Never auto-proceed on ambiguous intent

**Devin IDE Adaptation:**
- Use Devin IDE's confirmation system
- Build decision points into workflows
- Require human approval at phase transitions

### 5. Quality Gates at Every Phase

**Pattern:**
- Each phase has verification step
- Artifacts must meet criteria before advancing
- Failed gates trigger iteration loops

**Devin IDE Adaptation:**
- Define acceptance criteria per phase
- Build verification steps into workflows
- Implement iteration logic

### 6. Minimal Impact, Root Cause Fixes

**Pattern:**
- Prefer single-line fixes
- Never over-engineer
- Fix the root cause, not symptoms

**Devin IDE Adaptation:**
- Train agents to prefer minimal changes
- Build code review guardrails
- Enforce simplicity checks

### 7. Progressive Disclosure

**Pattern:**
- Skills load workflows on demand
- Don't overwhelm with all knowledge upfront
- Context-sensitive help

**Devin IDE Adaptation:**
- Design modular knowledge bases
- Load domain expertise as needed
- Context-aware suggestions

### 8. Intent Classification

**Pattern:**
- Classify messages: Converse / Dispatch / Clarify
- Answer questions directly (Converse)
- Route actions to agents (Dispatch)
- Ask when ambiguous (Clarify)

**Devin IDE Adaptation:**
- Build intent classifier
- Implement routing logic
- Handle ambiguity gracefully

## The 5-Phase Lifecycle (Methodology)

### Phase 1: Discover

**Goal:** Understand what to build and why

**Artifacts:**
- Problem statement
- User stories
- Scope boundaries
- API surface
- Acceptance criteria
- Constraints
- Test plan
- UAT scenarios
- Definition of done
- KPIs
- Cross-project dependencies
- Architecture tier

**Exit Criteria:**
- All 11 elements documented
- Stakeholder alignment
- Feasibility confirmed

**Iteration Trigger:**
- Requirements change
- New constraints discovered
- Stakeholder feedback

### Phase 2: Design

**Goal:** Define how it will work

**Artifacts:**
- UX flows
- Screen designs
- Component specs
- Data models
- API contracts

**Exit Criteria:**
- UX flows approved
- Component specs complete
- Technical feasibility confirmed

**Iteration Trigger:**
- UX issues discovered
- Technical blockers
- Stakeholder design feedback

### Phase 3: Sprint

**Goal:** Build it

**Sub-phases:**
- 3a: Planning (technical design, task breakdown)
- 3b: TDD (test cases)
- 3c: Implementation
- 3d: Code review
- 3e: QA verification
- 3f: UAT
- 3g: Merge

**Exit Criteria:**
- All acceptance criteria passing
- Code reviewed and approved
- QA verified
- UAT signed off

**Iteration Trigger:**
- Logic bugs
- Test failures
- QA findings

### Phase 4: Review

**Goal:** Learn and decide

**Artifacts:**
- Sprint review summary
- Retrospective
- Backlog refinement
- Iteration decision

**Exit Criteria:**
- Review completed
- Retro documented
- Decision made (release/iterate)

**Iteration Decision:**
- "UX issues" → back to Phase 2
- "Logic bugs" → back to Phase 3
- "Requirements changed" → back to Phase 1
- "Ready to release" → forward to Phase 5

### Phase 5: Release

**Goal:** Ship it

**Environments:**
- Dev → Staging → RC → Production

**Quality Gates:**
- Health checks pass
- Monitoring configured
- Rollback plan ready
- Documentation updated

**Exit Criteria:**
- Deployed to production
- Monitoring green
- No critical issues

## Agent Design Patterns

### 1. Specialist Agents

**Pattern:** One agent per domain
- prd-discoverer (discovery)
- prd-designer (design)
- prd-executor (implementation)
- prd-verifier (QA)

**Devin IDE Adaptation:**
- Create domain-specific Devin IDE agents
- Define clear responsibilities
- Avoid god agents

### 2. Orchestrator Agents

**Pattern:** One agent to coordinate others
- prd-orchestrator (lifecycle driver)
- concierge (intent router)

**Devin IDE Adaptation:**
- Build workflow orchestrators
- Define coordination logic
- Handle error recovery

### 3. Skill Loading

**Pattern:** Agents declare skills in frontmatter
- Skills loaded at startup
- Domain expertise on demand

**Devin IDE Adaptation:**
- Define knowledge base schema
- Implement skill loading mechanism
- Allow dynamic expertise

## State Management Pattern

### Filesystem as Truth

**CKS Pattern:**
```markdown
.prd/
  PRD-STATE.md (current phase, status, next action)
  PRD-ROADMAP.md (feature list, status)
  PRD-PROJECT.md (project metadata)
  phases/
    {NN}-{slug}/
      {NN}-CONTEXT.md (discovery artifact)
      {NN}-DESIGN.md (design artifact)
      {NN}-PLAN.md (sprint plan)
      {NN}-SUMMARY.md (implementation summary)
      {NN}-VERIFICATION.md (QA results)
      {NN}-REVIEW.md (review findings)
```

**Devin IDE Adaptation:**
- Use Devin IDE's storage system
- Define state schema (JSON/YAML)
- Implement artifact tracking
- Support context recovery

### State Machine

**CKS Pattern:**
```
not_started → discovering → discovered → designing → designed →
  sprinting → sprinted → reviewing → reviewed → releasing → released
                ↑            ↑           ↑
                └────────────┴───────────┘
                   iteration loop
```

**Devin IDE Adaptation:**
- Implement state machine in workflow
- Define transition rules
- Handle iteration loops
- Prevent invalid transitions

## Hook System Pattern

**CKS Pattern:**
- SessionStart: Show status
- PreToolUse: Guard destructive ops
- PostToolUse: Log actions
- Stop: Cleanup and warn

**Devin IDE Adaptation:**
- Use Devin IDE's event system
- Implement guard rails
- Add logging
- Handle cleanup

## Common Anti-Patterns to Avoid

### 1. Fat Commands
**Bad:** 200-line command with domain logic
**Good:** 40-line dispatcher that calls an agent

### 2. God Agents
**Bad:** One agent that does everything
**Good:** Specialist agents with clear responsibilities

### 3. Context Bloat
**Bad:** Never clearing context, growing to 100K tokens
**Good:** State on disk, reset context between phases

### 4. Auto-Proceed
**Bad:** Assuming intent and proceeding without confirmation
**Good:** Classify intent, confirm when ambiguous

### 5. Skipping Gates
**Bad:** Bypassing quality gates for speed
**Good:** Enforce gates, allow iteration loops

## Implementation Priority

### Phase 1: Foundation
1. Define state schema for Devin IDE
2. Create 5-phase workflow templates
3. Build basic agent templates
4. Implement state machine

### Phase 2: Core Workflows
1. Discover workflow (11 elements)
2. Design workflow (UX + components)
3. Sprint workflow (plan → build → QA)
4. Review workflow (retro + decision)
5. Release workflow (env promotion)

### Phase 3: Orchestration
1. Intent classifier (Converse/Dispatch/Clarify)
2. Workflow orchestrator
3. Iteration loop logic
4. Error recovery

### Phase 4: Quality
1. Verification steps per phase
2. Guard rails (destructive ops, secrets)
3. Code review patterns
4. Minimal change enforcement

### Phase 5: Polish
1. Progress dashboards
2. Context recovery
3. Documentation
4. Examples

## Success Metrics

- [ ] 5-phase lifecycle operational
- [ ] State persistence working
- [ ] Iteration loops functional
- [ ] Human gates enforced
- [ ] Quality gates passing
- [ ] Minimal changes enforced
- [ ] Context recovery working

## Next Steps

1. **Research Devin IDE capabilities:** What workflow system exists? How do agents work? What's the state model?
2. **Design state schema:** Define the JSON/YAML structure for tracking phases and artifacts
3. **Build first workflow:** Start with Discover phase (simplest, most valuable)
4. **Test iteration:** Ensure state persists and context can be recovered
5. **Expand to other phases:** Design, Sprint, Review, Release
