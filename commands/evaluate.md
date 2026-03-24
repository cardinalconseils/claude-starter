---
description: Build the Process Evaluator feature — complete process card generation from text input
argument-hint: "[phase number]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - WebSearch
  - WebFetch
  - Skill
  - AskUserQuestion
  - TodoRead
  - TodoWrite
  - "mcp__*"
---

# /cks:evaluate — Build Process Evaluator Feature

<objective>
Plan and implement the Process Evaluator feature — the core value proposition of ProcessFlow AI. This takes raw text/documents and produces complete process cards with: executive summary, KPIs, benchmarks, SOPs, flow charts, tech stack, and bottleneck analysis.

This command creates a PRD for the feature and begins the autonomous implementation cycle.
</objective>

<execution_context>
@.claude/skills/prd/workflows/process-evaluator.md
@.claude/skills/prd/workflows/autonomous.md
</execution_context>

<process>

<step name="create_prd">
## 1. Create the Process Evaluator PRD

Read the feature spec from `.claude/skills/prd/workflows/process-evaluator.md`.

Initialize `.prd/` if needed, then create a PRD with these phases:

**Phase 01: Completeness Checker + Question Flow**
- Completeness scoring logic (5 required + 5 enrichment criteria)
- ClarificationRequest type and state management
- ChatBot integration for asking/receiving answers
- Partial evaluation persistence

**Phase 02: Full Card Generator**
- Single-pass Gemini evaluation prompt
- Executive summary generation + persistence
- Enhanced KPI generation (SMART, industry-aware)
- Benchmark and SOP generation with persistence
- Bottleneck analysis generation
- Process type extension in types.ts

**Phase 03: Enriched Flow Chart Generation**
- Improved node extraction from natural language
- Automatic role/department detection for lanes
- Gateway inference from conditional language
- BPMN-compliant node type assignment
- Re-layout with dagre after generation

**Phase 04: Smart ChatBot Integration**
- ChatBot reads process context from Firestore
- Conversational process building ("add a step", "change the KPIs")
- Re-evaluation of existing process cards
- Process-aware system prompt with tool use
</step>

<step name="run_cycle">
## 2. Run the Autonomous Cycle

After the PRD is created, run the full autonomous cycle:
discuss → plan → execute → verify → commit → ship

For each phase, the executor should:
- Read the process-evaluator.md workflow for detailed specs
- Read existing components (AdminPanel, ProcessFlow, ChatBot, types.ts)
- Follow the existing code patterns (Gemini API usage, Firestore CRUD, React components)
- Extend — don't replace — the existing OnboardingModal flow
</step>

</process>
