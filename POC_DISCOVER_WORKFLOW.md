# Proof of Concept: Discover Workflow for Devin IDE

## Overview

Minimal implementation of the Discover workflow (Phase 1) to validate the architecture.

## Prerequisites

- Devin IDE with workflow system
- State management API
- Agent system
- Confirmation/dialog system

## Implementation

### 1. State Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Workflow State",
  "type": "object",
  "properties": {
    "workflow_id": {"type": "string"},
    "feature_id": {"type": "string"},
    "feature_name": {"type": "string"},
    "current_phase": {"type": "string", "enum": ["discover", "design", "sprint", "review", "release"]},
    "phase_status": {"type": "string", "enum": ["not_started", "in_progress", "complete", "blocked"]},
    "current_step": {"type": "string"},
    "artifacts": {
      "type": "object",
      "properties": {
        "context": {"type": "string"},
        "design": {"type": ["string", "null"]},
        "plan": {"type": ["string", "null"]},
        "summary": {"type": ["string", "null"]},
        "verification": {"type": ["string", "null"]},
        "review": {"type": ["string", "null"]}
      }
    },
    "discover_elements": {
      "type": "object",
      "properties": {
        "problem_statement": {"type": ["string", "null"]},
        "user_stories": {"type": ["string", "null"]},
        "scope": {"type": ["string", "null"]},
        "api_surface": {"type": ["string", "null"]},
        "acceptance_criteria": {"type": ["string", "null"]},
        "constraints": {"type": ["string", "null"]},
        "test_plan": {"type": ["string", "null"]},
        "uat_scenarios": {"type": ["string", "null"]},
        "definition_of_done": {"type": ["string", "null"]},
        "kpis": {"type": ["string", "null"]},
        "dependencies": {"type": ["string", "null"]},
        "architecture_tier": {"type": ["string", "null"]}
      }
    },
    "last_action": {"type": "string"},
    "last_action_date": {"type": "string", "format": "date"},
    "next_action": {"type": "string"},
    "suggested_command": {"type": "string"}
  },
  "required": ["workflow_id", "feature_id", "feature_name", "current_phase", "phase_status"]
}
```

### 2. Discover Workflow Definition

```yaml
name: discover
description: "Gather 11 elements to understand what to build"
version: "1.0.0"

entry_criteria:
  - feature_defined: true

steps:
  - id: "problem_statement"
    name: "Problem Statement"
    description: "Define the problem this feature solves"
    agent: "discoverer"
    knowledge_base: "requirements_gathering"
    confirmation_required: true

  - id: "user_stories"
    name: "User Stories"
    description: "Write user stories from the user's perspective"
    agent: "discoverer"
    knowledge_base: "user_stories"
    confirmation_required: true

  - id: "scope"
    name: "Scope Definition"
    description: "Define what's in and out of scope"
    agent: "discoverer"
    knowledge_base: "scope_definition"
    confirmation_required: true

  - id: "api_surface"
    name: "API Surface"
    description: "Define the API endpoints and data structures"
    agent: "discoverer"
    knowledge_base: "api_design"
    confirmation_required: true

  - id: "acceptance_criteria"
    name: "Acceptance Criteria"
    description: "Define measurable acceptance criteria"
    agent: "discoverer"
    knowledge_base: "acceptance_criteria"
    confirmation_required: true

  - id: "constraints"
    name: "Constraints"
    description: "Identify technical, business, and time constraints"
    agent: "discoverer"
    knowledge_base: "constraint_analysis"
    confirmation_required: true

  - id: "test_plan"
    name: "Test Plan"
    description: "Define the testing strategy"
    agent: "discoverer"
    knowledge_base: "testing_strategy"
    confirmation_required: true

  - id: "uat_scenarios"
    name: "UAT Scenarios"
    description: "Define user acceptance test scenarios"
    agent: "discoverer"
    knowledge_base: "uat_planning"
    confirmation_required: true

  - id: "definition_of_done"
    name: "Definition of Done"
    description: "Define when the feature is considered complete"
    agent: "discoverer"
    knowledge_base: "definition_of_done"
    confirmation_required: true

  - id: "kpis"
    name: "KPIs"
    description: "Define key performance indicators"
    agent: "discoverer"
    knowledge_base: "kpi_definition"
    confirmation_required: true

  - id: "dependencies"
    name: "Dependencies"
    description: "Identify cross-project dependencies"
    agent: "discoverer"
    knowledge_base: "dependency_analysis"
    confirmation_required: true

  - id: "architecture_tier"
    name: "Architecture Tier"
    description: "Determine the architecture tier (Prototype/Pilot/Candidate/Production)"
    agent: "discoverer"
    knowledge_base: "architecture_tiers"
    confirmation_required: true

exit_criteria:
  - all_elements_complete: true

artifacts:
  - name: "context"
    format: "markdown"
    template: "context_template.md"
    path: ".phases/{feature_id}/CONTEXT.md"
```

### 3. Discoverer Agent

```yaml
name: discoverer
description: "Gathers requirements and understands what to build"
model: claude-3-5-sonnet

knowledge_bases:
  - requirements_gathering
  - user_stories
  - scope_definition
  - api_design
  - acceptance_criteria
  - constraint_analysis
  - testing_strategy
  - uat_planning
  - definition_of_done
  - kpi_definition
  - dependency_analysis
  - architecture_tiers

tools:
  - read_file
  - write_file
  - search_codebase
  - run_command
  - request_confirmation

system_prompt: |
  You are the Discoverer agent. Your role is to gather requirements and understand what to build.

  Your principles:
  - Ask clarifying questions when information is missing
  - Prefer concrete examples over abstract descriptions
  - Focus on the "why" before the "what"
  - Identify assumptions explicitly
  - Keep scope minimal

  Your constraints:
  - Always request confirmation for each element
  - Never assume technical details without asking
  - Flag risks and dependencies explicitly
  - Use the confirmation system for all decisions

  For each element:
  1. Read the relevant knowledge base
  2. Ask targeted questions via confirmation system
  3. Synthesize the answers into a clear description
  4. Update the state with the completed element
  5. Suggest the next step

  When all 11 elements are complete:
  1. Generate the CONTEXT.md artifact
  2. Update state to mark discover phase complete
  3. Suggest advancing to design phase
```

### 4. Knowledge Base: Requirements Gathering

```markdown
# Requirements Gathering

## Principles

1. **Problem First:** Start with the problem, not the solution
2. **User-Centric:** Frame from the user's perspective
3. **Measurable:** Make criteria quantifiable when possible
4. **Testable:** Every requirement should be verifiable
5. **Minimal:** Only include what's necessary for the first iteration

## Problem Statement Template

```
**Problem:** [What problem are we solving?]

**Impact:** [Who is affected and how?]

**Current State:** [What's the current situation?]

**Desired State:** [What does success look like?]

**Metrics:** [How will we measure success?]
```

## Examples

### Example 1: User Authentication

**Problem:** Users cannot securely access their accounts

**Impact:** 40% of users abandon signup when asked to create a password

**Current State:** No authentication system exists

**Desired State:** Users can sign up and login with email/password or social providers

**Metrics:** Signup completion rate increases to 60%

## Anti-Patterns

- **Solution-first:** "We need to add OAuth" (starts with solution)
- **Vague:** "Make it better" (not specific)
- **Assumption-heavy:** "Users want X" (without evidence)
- **Over-scoped:** Including nice-to-haves in first iteration

## Questions to Ask

1. Who is experiencing this problem?
2. How often does it occur?
3. What are the consequences of not solving it?
4. What have users tried to work around it?
5. What does success look like?
```

### 5. Context Template

```markdown
# Context: {feature_name}

**Feature ID:** {feature_id}
**Phase:** Discover
**Status:** Complete
**Date:** {date}

## 1. Problem Statement

{problem_statement}

## 2. User Stories

{user_stories}

## 3. Scope

**In Scope:**
{in_scope}

**Out of Scope:**
{out_scope}

## 4. API Surface

{api_surface}

## 5. Acceptance Criteria

{acceptance_criteria}

## 6. Constraints

{constraints}

## 7. Test Plan

{test_plan}

## 8. UAT Scenarios

{uat_scenarios}

## 9. Definition of Done

{definition_of_done}

## 10. KPIs

{kpis}

## 11. Dependencies

{dependencies}

## 12. Architecture Tier

{architecture_tier}

---

**Next Phase:** Design
**Command:** `workflow:start design`
```

### 6. Workflow Orchestrator (Simplified)

```python
class WorkflowOrchestrator:
    def __init__(self, state_manager, agent_registry):
        self.state_manager = state_manager
        self.agent_registry = agent_registry

    def start_workflow(self, workflow_name, feature_name):
        """Start a workflow"""
        state = {
            "workflow_id": generate_uuid(),
            "feature_id": f"F-{next_id()}",
            "feature_name": feature_name,
            "current_phase": workflow_name,
            "phase_status": "in_progress",
            "current_step": None,
            "artifacts": {},
            "discover_elements": {},
            "last_action": f"Started {workflow_name} workflow",
            "last_action_date": datetime.now().isoformat(),
            "next_action": "Begin first step",
            "suggested_command": f"workflow:step {workflow_name}:first"
        }
        self.state_manager.save(state)
        return state

    def execute_step(self, workflow_name, step_id):
        """Execute a single workflow step"""
        state = self.state_manager.load()
        workflow = self.load_workflow(workflow_name)
        step = self.get_step(workflow, step_id)

        # Update state
        state["current_step"] = step_id
        self.state_manager.save(state)

        # Dispatch agent
        agent = self.agent_registry.get(step["agent"])
        result = agent.execute(step, state)

        # Update state with result
        self.update_state_with_result(state, step_id, result)
        self.state_manager.save(state)

        return result

    def check_exit_criteria(self, workflow_name):
        """Check if workflow exit criteria are met"""
        state = self.state_manager.load()
        workflow = self.load_workflow(workflow_name)

        for criterion in workflow["exit_criteria"]:
            if not self.evaluate_criterion(criterion, state):
                return False

        return True

    def complete_workflow(self, workflow_name):
        """Mark workflow as complete"""
        state = self.state_manager.load()
        state["phase_status"] = "complete"
        state["last_action"] = f"Completed {workflow_name} phase"
        state["last_action_date"] = datetime.now().isoformat()
        state["next_action"] = "Advance to next phase"
        state["suggested_command"] = self.get_next_phase_command(workflow_name)
        self.state_manager.save(state)
```

### 7. Agent Execution (Simplified)

```python
class DiscovererAgent:
    def __init__(self, knowledge_base_registry, confirmation_system):
        self.kb_registry = knowledge_base_registry
        self.confirmation = confirmation_system

    def execute(self, step, state):
        """Execute a discover step"""
        # Load knowledge base
        kb = self.kb_registry.get(step["knowledge_base"])

        # Generate questions based on step
        questions = self.generate_questions(step["id"], kb)

        # Request confirmation with questions
        answers = self.confirmation.request(
            question=f"Complete {step['name']}?",
            options=self.format_questions(questions)
        )

        # Synthesize answers into element
        element = self.synthesize_element(step["id"], answers, kb)

        # Update state
        state["discover_elements"][step["id"]] = element

        return element

    def generate_questions(self, step_id, kb):
        """Generate questions for a step"""
        # Map step IDs to question templates
        question_templates = {
            "problem_statement": [
                "What problem are we solving?",
                "Who is affected?",
                "What's the impact?"
            ],
            "user_stories": [
                "Who are the users?",
                "What do they want to accomplish?",
                "Why do they want it?"
            ],
            # ... other steps
        }
        return question_templates.get(step_id, [])

    def synthesize_element(self, step_id, answers, kb):
        """Synthesize answers into a structured element"""
        # Use knowledge base patterns to format
        template = kb.get_template(step_id)
        return template.format(**answers)
```

### 8. Confirmation System

```python
class ConfirmationSystem:
    def request(self, question, options):
        """Request user confirmation"""
        confirmation = {
            "type": "confirmation",
            "question": question,
            "options": options,
            "required": True
        }
        # This would call Devin IDE's dialog API
        return self.send_to_dialog(confirmation)

    def format_questions(self, questions):
        """Format questions as selectable options"""
        options = []
        for i, question in enumerate(questions):
            options.append({
                "label": f"Q{i+1}: {question}",
                "description": "Provide answer",
                "action": "answer"
            })
        options.append({
            "label": "Complete element",
            "description": "Finish this step",
            "action": "complete"
        })
        return options
```

## Usage Example

```bash
# Start discover workflow
workflow:start discover "user authentication"

# Execute first step
workflow:step discover:problem_statement

# Continue through steps
workflow:step discover:user_stories
workflow:step discover:scope
# ... etc

# Check status
workflow:status

# Auto-advance (when all steps complete)
workflow:advance
```

## Testing Checklist

- [ ] State persists after workflow start
- [ ] Agent can be dispatched for each step
- [ ] Confirmation system receives user input
- [ ] Knowledge base is loaded correctly
- [ ] Elements are saved to state
- [ ] CONTEXT.md is generated when complete
- [ ] Exit criteria are evaluated correctly
- [ ] Workflow can be resumed after interruption
- [ ] State can be recovered on session restart

## Next Steps

1. Implement state manager using Devin IDE's storage API
2. Create agent registry and agent factory
3. Build knowledge base loader
4. Implement confirmation system integration
5. Create workflow loader from YAML
6. Test end-to-end with a simple feature
7. Expand to other phases (design, sprint, review, release)
