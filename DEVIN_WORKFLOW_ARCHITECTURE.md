# Devin IDE Workflow Architecture (CKS-Inspired)

## Architecture Overview

A Devin IDE-native workflow system inspired by CKS principles, adapted for platform strengths.

## Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Workflow Orchestrator                     │
│  (Intent classification, routing, state management)         │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  Workflows    │    │   Agents      │    │  Knowledge    │
│  (5-phase)    │    │  (Specialist) │    │   Bases       │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  State Store    │
                    │  (Persistent)   │
                    └─────────────────┘
```

## 1. Workflow Orchestrator

### Responsibilities

- **Intent Classification:** Converse / Dispatch / Clarify
- **Workflow Routing:** Map user intent to appropriate workflow
- **State Management:** Track phase, status, artifacts
- **Iteration Control:** Handle iteration loops and gates
- **Context Recovery:** Restore state between sessions

### Implementation

```yaml
orchestrator:
  intent_classifier:
    model: "claude-3-5-sonnet"
    confidence_threshold: 0.8
    classes:
      - converse: "questions, advice, chat"
      - dispatch: "lifecycle actions (create, build, deploy)"
      - clarify: "ambiguous intent"

  workflow_router:
    mappings:
      "create|start|new": workflow:discover
      "plan|design": workflow:design
      "sprint|build|implement": workflow:sprint
      "review|retro": workflow:review
      "deploy|release|ship": workflow:release
      "status|progress": action:show_status

  state_manager:
    storage: "devin_ide_state"
    schema: "workflow_state"
    persistence: "filesystem"
    recovery: "automatic"
```

### Intent Classification Logic

```python
def classify_intent(user_message, context):
    """
    Classify user message into Converse/Dispatch/Clarify
    """
    # Check for question patterns
    if is_question(user_message):
        return "converse"

    # Check for lifecycle verbs
    intent = extract_intent(user_message)
    confidence = calculate_confidence(intent, context)

    if confidence < 0.8:
        return "clarify"

    return "dispatch"
```

## 2. Workflow System

### 5-Phase Workflows

Each workflow is a self-contained unit with:

- **Entry criteria:** What must be true to start
- **Steps:** Ordered list of actions
- **Exit criteria:** What must be true to complete
- **Artifacts:** Outputs to persist
- **Iteration triggers:** When to loop back

### Phase 1: Discover Workflow

```yaml
workflow:
  name: discover
  description: "Gather requirements and understand what to build"
  entry_criteria:
    - feature_defined: true
    - project_initialized: true

  steps:
    - name: "gather_problem_statement"
      agent: "discoverer"
      knowledge_base: "requirements_gathering"

    - name: "collect_user_stories"
      agent: "discoverer"
      knowledge_base: "user_stories"

    - name: "define_scope"
      agent: "discoverer"
      knowledge_base: "scope_definition"

    - name: "specify_api_surface"
      agent: "discoverer"
      knowledge_base: "api_design"

    - name: "define_acceptance_criteria"
      agent: "discoverer"
      knowledge_base: "acceptance_criteria"

    - name: "identify_constraints"
      agent: "discoverer"
      knowledge_base: "constraint_analysis"

    - name: "create_test_plan"
      agent: "discoverer"
      knowledge_base: "testing_strategy"

    - name: "define_uat_scenarios"
      agent: "discoverer"
      knowledge_base: "uat_planning"

    - name: "specify_definition_of_done"
      agent: "discoverer"
      knowledge_base: "definition_of_done"

    - name: "define_kpis"
      agent: "discoverer"
      knowledge_base: "kpi_definition"

    - name: "identify_dependencies"
      agent: "discoverer"
      knowledge_base: "dependency_analysis"

    - name: "determine_architecture_tier"
      agent: "discoverer"
      knowledge_base: "architecture_tiers"

  exit_criteria:
    - all_elements_complete: true
    - stakeholder_alignment: true
    - feasibility_confirmed: true

  artifacts:
    - name: "context"
      format: "markdown"
      path: ".phases/{phase_id}/CONTEXT.md"

  iteration_triggers:
    - event: "requirements_changed"
      action: "restart_workflow"
    - event: "new_constraints"
      action: "restart_workflow"
    - event: "stakeholder_feedback"
      action: "restart_workflow"
```

### Phase 2: Design Workflow

```yaml
workflow:
  name: design
  description: "Define UX flows and component specifications"
  entry_criteria:
    - discover_complete: true
    - context_artifact_exists: true

  steps:
    - name: "research_ux_patterns"
      agent: "designer"
      knowledge_base: "ux_research"

    - name: "create_user_flows"
      agent: "designer"
      knowledge_base: "user_flow_design"

    - name: "design_screens"
      agent: "designer"
      knowledge_base: "screen_design"
      tools:
        - "ui_generator"  # Devin IDE native or integrated

    - name: "specify_components"
      agent: "designer"
      knowledge_base: "component_specification"

    - name: "define_data_models"
      agent: "designer"
      knowledge_base: "data_modeling"

    - name: "specify_api_contracts"
      agent: "designer"
      knowledge_base: "api_contracts"

  exit_criteria:
    - ux_flows_approved: true
    - component_specs_complete: true
    - technical_feasibility: true

  artifacts:
    - name: "design"
      format: "markdown"
      path: ".phases/{phase_id}/DESIGN.md"
    - name: "screens"
      format: "json"
      path: ".phases/{phase_id}/screens.json"

  iteration_triggers:
    - event: "ux_issues"
      action: "restart_workflow"
    - event: "technical_blocker"
      action: "restart_workflow"
```

### Phase 3: Sprint Workflow

```yaml
workflow:
  name: sprint
  description: "Plan, implement, and verify the feature"
  entry_criteria:
    - design_complete: true
    - design_artifact_exists: true

  steps:
    - name: "technical_planning"
      agent: "planner"
      knowledge_base: "technical_design"

    - name: "task_breakdown"
      agent: "planner"
      knowledge_base: "task_breakdown"

    - name: "write_test_cases"
      agent: "planner"
      knowledge_base: "tdd"

    - name: "implementation"
      agent: "executor"
      knowledge_base: "implementation"
      iteration:
        max_attempts: 3
        verifier: "qa_agent"

    - name: "code_review"
      agent: "reviewer"
      knowledge_base: "code_review"

    - name: "qa_verification"
      agent: "verifier"
      knowledge_base: "qa_testing"

    - name: "uat"
      agent: "uat_agent"
      knowledge_base: "uat_testing"

    - name: "merge"
      agent: "executor"
      knowledge_base: "git_workflow"

  exit_criteria:
    - acceptance_criteria_passing: true
    - code_review_approved: true
    - qa_verified: true
    - uat_signed_off: true

  artifacts:
    - name: "plan"
      format: "markdown"
      path: ".phases/{phase_id}/PLAN.md"
    - name: "summary"
      format: "markdown"
      path: ".phases/{phase_id}/SUMMARY.md"
    - name: "verification"
      format: "markdown"
      path: ".phases/{phase_id}/VERIFICATION.md"

  iteration_triggers:
    - event: "logic_bugs"
      action: "restart_from_implementation"
    - event: "test_failures"
      action: "restart_from_implementation"
```

### Phase 4: Review Workflow

```yaml
workflow:
  name: review
  description: "Review work, learn, and decide next steps"
  entry_criteria:
    - sprint_complete: true
    - verification_artifact_exists: true

  steps:
    - name: "sprint_review"
      agent: "reviewer"
      knowledge_base: "sprint_review"

    - name: "retrospective"
      agent: "reviewer"
      knowledge_base: "retrospective"

    - name: "backlog_refinement"
      agent: "reviewer"
      knowledge_base: "backlog_management"

    - name: "iteration_decision"
      agent: "orchestrator"
      knowledge_base: "iteration_logic"

  exit_criteria:
    - review_complete: true
    - retro_documented: true
    - decision_made: true

  artifacts:
    - name: "review"
      format: "markdown"
      path: ".phases/{phase_id}/REVIEW.md"

  iteration_decision:
    ux_issues:
      action: "restart_workflow:design"
    logic_bugs:
      action: "restart_workflow:sprint"
    requirements_changed:
      action: "restart_workflow:discover"
    ready_to_release:
      action: "advance_workflow:release"
```

### Phase 5: Release Workflow

```yaml
workflow:
  name: release
  description: "Deploy feature through environments"
  entry_criteria:
    - review_complete: true
    - decision: "ready_to_release"

  steps:
    - name: "deploy_dev"
      agent: "deployer"
      knowledge_base: "deployment"
      environment: "dev"

    - name: "health_check_dev"
      agent: "deployer"
      knowledge_base: "health_checks"

    - name: "deploy_staging"
      agent: "deployer"
      knowledge_base: "deployment"
      environment: "staging"

    - name: "e2e_tests"
      agent: "verifier"
      knowledge_base: "e2e_testing"

    - name: "deploy_rc"
      agent: "deployer"
      knowledge_base: "deployment"
      environment: "rc"

    - name: "configure_monitoring"
      agent: "deployer"
      knowledge_base: "monitoring"

    - name: "deploy_production"
      agent: "deployer"
      knowledge_base: "deployment"
      environment: "production"

    - name: "post_deploy_verification"
      agent: "deployer"
      knowledge_base: "health_checks"

  exit_criteria:
    - deployed_to_production: true
    - monitoring_green: true
    - no_critical_issues: true

  quality_gates:
    - name: "health_checks"
      criteria: "all_passing"
    - name: "monitoring"
      criteria: "configured_and_green"
    - name: "rollback_plan"
      criteria: "documented"
```

## 3. Agent System

### Agent Template

```yaml
agent:
  name: "{agent_name}"
  description: "{agent description}"

  model: "claude-3-5-sonnet"  # or platform-specific

  knowledge_bases:
    - "{knowledge_base_name}"

  tools:
    - "read_file"
    - "write_file"
    - "edit_file"
    - "run_command"
    - "search_codebase"

  system_prompt: |
    You are the {agent_name} agent.
    Your role: {role_description}
    Your constraints:
    - Prefer minimal changes
    - Always explain your reasoning
    - Ask for confirmation on destructive changes
    - Never skip quality gates

    When you encounter ambiguity, use the confirmation system.
    When you complete a task, update the state.
```

### Specialist Agents

```yaml
agents:
  discoverer:
    role: "Gather requirements and understand what to build"
    knowledge_bases:
      - requirements_gathering
      - user_stories
      - scope_definition
      - api_design
      - acceptance_criteria

  designer:
    role: "Define UX flows and component specifications"
    knowledge_bases:
      - ux_research
      - user_flow_design
      - screen_design
      - component_specification

  planner:
    role: "Create technical plans and task breakdowns"
    knowledge_bases:
      - technical_design
      - task_breakdown
      - tdd

  executor:
    role: "Implement features following the plan"
    knowledge_bases:
      - implementation
      - git_workflow
    constraints:
      - "minimal_changes"
      - "tdd_first"

  verifier:
    role: "Verify quality and acceptance criteria"
    knowledge_bases:
      - qa_testing
      - acceptance_criteria

  reviewer:
    role: "Review code and conduct retrospectives"
    knowledge_bases:
      - code_review
      - retrospective
      - sprint_review

  deployer:
    role: "Deploy features through environments"
    knowledge_bases:
      - deployment
      - health_checks
      - monitoring
```

## 4. Knowledge Base System

### Knowledge Base Structure

```
knowledge/
  requirements_gathering/
    principles.md
    patterns.md
    examples.md

  user_stories/
    templates.md
    best_practices.md

  scope_definition/
    techniques.md
    anti_patterns.md

  ... (one per domain)
```

### Knowledge Base Template

```markdown
# {Knowledge Base Name}

## Principles

- Principle 1
- Principle 2

## Patterns

- Pattern 1: Description
- Pattern 2: Description

## Examples

### Example 1
Context: ...
Solution: ...
Outcome: ...

## Anti-Patterns

- Anti-pattern 1: Why it's bad
- Anti-pattern 2: Why it's bad

## References

- Link to external resources
- Link to internal docs
```

## 5. State Management

### State Schema

```json
{
  "workflow_id": "uuid",
  "feature_id": "F-01",
  "feature_name": "user-auth",
  "current_phase": "discover",
  "phase_status": "in_progress",
  "state_machine": {
    "current_state": "discovering",
    "previous_state": "not_started",
    "valid_transitions": [
      "discovered",
      "blocked"
    ]
  },
  "artifacts": {
    "context": ".phases/01-user-auth/CONTEXT.md",
    "design": null,
    "plan": null,
    "summary": null,
    "verification": null,
    "review": null
  },
  "iteration": {
    "count": 0,
    "max_iterations": 3,
    "last_iteration_reason": null
  },
  "last_action": "Started discovery phase",
  "last_action_date": "2024-01-01",
  "next_action": "Complete problem statement",
  "suggested_command": "workflow:discover step:problem_statement",
  "blockers": [],
  "metadata": {
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z",
    "created_by": "user"
  }
}
```

### State Machine

```python
STATE_MACHINE = {
    "not_started": ["discovering"],
    "discovering": ["discovered", "blocked"],
    "discovered": ["designing"],
    "blocked": ["discovering", "designing", "sprinting"],
    "designing": ["designed", "iterating_design"],
    "designed": ["sprinting"],
    "iterating_design": ["designing"],
    "sprinting": ["sprinted", "iterating_sprint"],
    "sprinted": ["reviewing"],
    "iterating_sprint": ["sprinting"],
    "reviewing": ["reviewed", "iterating_discover"],
    "reviewed": ["releasing"],
    "iterating_discover": ["discovering"],
    "releasing": ["released"],
    "released": []
}
```

## 6. Event System

### Event Types

```yaml
events:
  workflow_started:
    triggers:
      - log_event
      - update_state

  step_completed:
    triggers:
      - log_event
      - update_artifacts
      - check_exit_criteria

  phase_completed:
    triggers:
      - log_event
      - update_state
      - notify_user

  iteration_triggered:
    triggers:
      - log_event
      - update_iteration_count
      - reset_to_phase

  workflow_blocked:
    triggers:
      - log_event
      - update_state
      - notify_user

  workflow_completed:
    triggers:
      - log_event
      - update_state
      - notify_user
      - cleanup
```

### Guard Rails

```yaml
guards:
  destructive_operations:
    - tool: "run_command"
      matcher: "rm -rf"
      action: "require_confirmation"
      message: "This will delete files. Confirm?"

  secrets_detection:
    - tool: "write_file"
      matcher: "api_key|secret|password"
      action: "block_and_warn"
      message: "Potential secret detected. Use environment variables."

  minimal_changes:
    - tool: "edit_file"
      action: "check_diff_size"
      threshold: 100  # lines
      message: "Large change detected. Consider breaking into smaller changes."

  quality_gates:
    - phase: "sprint"
      step: "implementation"
      action: "require_tests"
      message: "Tests must pass before proceeding."
```

## 7. Confirmation System

### Confirmation Flow

```python
def request_confirmation(question, options):
    """
    Request user confirmation with selectable options
    """
    confirmation = {
        "question": question,
        "options": options,
        "required": True
    }
    return send_confirmation(confirmation)
```

### Confirmation Template

```yaml
confirmation:
  question: "Phase 1 — Discover: CONTEXT.md missing. Run or skip?"
  header: "Phase 1 Gate"
  options:
    - label: "Run Discover (Recommended)"
      description: "Gather all 11 elements"
      action: "workflow:start:discover"
    - label: "Skip — already done"
      description: "Use existing CONTEXT.md"
      action: "workflow:skip:discover"
    - label: "Skip — not needed"
      description: "Proceed without discovery"
      action: "workflow:advance:design"
```

## Implementation Priority

### Phase 1: Core Infrastructure
1. State schema and storage
2. State machine implementation
3. Basic orchestrator (intent classification)
4. Confirmation system

### Phase 2: First Workflow
1. Discover workflow (11 elements)
2. Discoverer agent
3. Requirements knowledge base
4. Artifact generation

### Phase 3: Expand Workflows
1. Design workflow
2. Sprint workflow
3. Designer, planner, executor agents
4. Additional knowledge bases

### Phase 4: Orchestration
1. Review workflow
2. Release workflow
3. Iteration logic
4. Workflow routing

### Phase 5: Quality
1. Guard rails
2. Event system
3. Monitoring
4. Documentation

## Integration Points

### Devin IDE Specific

Replace these with actual Devin IDE capabilities:

- **Storage:** Use Devin IDE's persistent storage API
- **Commands:** Use Devin IDE's command registration
- **Agents:** Use Devin IDE's agent system
- **UI Generator:** Use Devin IDE's native or integrated UI tools
- **Confirmation:** Use Devin IDE's dialog system
- **Events:** Use Devin IDE's event hooks

### External Integrations

- **Git:** Use platform's git integration
- **Deployment:** Use CI/CD platform or custom scripts
- **Monitoring:** Use observability platform
- **Testing:** Use platform's test runner

## Success Criteria

- [ ] State persists across sessions
- [ ] 5-phase workflows operational
- [ ] Intent classification working
- [ ] Confirmation system functional
- [ ] Iteration loops working
- [ ] Quality gates enforced
- [ ] Guard rails active
- [ ] Context recovery working
