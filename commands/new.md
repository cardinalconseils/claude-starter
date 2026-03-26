---
description: "Create a new feature and start the 5-phase lifecycle — discover → design → sprint → review → release"
argument-hint: "[feature description]"
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

# /cks:new — New Feature → 5-Phase Lifecycle

<objective>
Create a new feature entry from the project roadmap (or a fresh brief), then immediately enter Phase 1: Discovery. If run in autonomous mode, chains through all 5 phases without stopping.
</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/new-project.md
@${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/autonomous.md
</execution_context>

<process>

<step name="initialize">
## 1. Initialize Project (if needed)

Check if `.prd/` exists:

**If no `.prd/`:** Run the new-project workflow to create PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md. Gather project context from the codebase (read CLAUDE.md, package.json, README.md).

**If `.prd/` exists:** Read existing state. Skip initialization.
</step>

<step name="select_feature">
## 2. Select or Create Feature

**If `$ARGUMENTS` provided:** Use it as the feature brief.

**If no arguments:** Read PRD-ROADMAP.md for available features.

```
AskUserQuestion({
  questions: [{
    question: "Which feature would you like to build?",
    header: "New Feature",
    multiSelect: false,
    options: [
      // Dynamically populated from PRD-ROADMAP.md:
      { label: "PRD-001: {feature name}", description: "{brief from roadmap}" },
      { label: "PRD-002: {feature name}", description: "{brief from roadmap}" },
      // Always include:
      { label: "New feature", description: "Describe a feature not on the roadmap" }
    ]
  }]
})
```

If "New feature" selected → ask for brief via AskUserQuestion with text input option.
</step>

<step name="create_feature">
## 3. Create Feature Entry

1. Create phase directory: `.prd/phases/{NN}-{kebab-name}/`
2. Update PRD-STATE.md: active_phase = {NN}, status = discovering
3. Update PRD-ROADMAP.md: add phase as "Discovering"

**VALIDATION — MANDATORY:** After creating the feature entry, verify ALL of the following before proceeding to Step 4:

1. Directory `.prd/phases/{NN}-{kebab-name}/` exists
2. `PRD-STATE.md` has been updated: `active_phase` equals `{NN}` and `status` equals `discovering`
3. `PRD-ROADMAP.md` contains an entry for Phase `{NN}`

**If any check fails:**
```
Feature creation validation failed:
  Directory: {exists/missing}
  STATE.md active_phase: {value or "not set"}
  ROADMAP.md entry: {present/missing}

  Retrying creation...
```
Re-attempt the creation. If it fails twice, stop and report the error. Do NOT proceed to Step 4 with an incomplete feature setup.
</step>

<step name="enter_discovery">
## 4. Enter Phase 1: Discovery

Immediately invoke the discover workflow:

```
Skill(skill="discover", args="{NN}")
```

This runs Phase 1 interactively. After discovery completes, the user runs `/clear` then `/cks:next` to advance to Phase 2 (Design).
</step>

<step name="completion_signal">
## 5. Completion Signal

When `/cks:new` finishes, report what was created:

```
/cks:new complete
━━━━━━━━━━━━━━━━━
  Feature: {NN} — {name}
  Directory: .prd/phases/{NN}-{kebab-name}/
  State: discovering
  Roadmap: updated
```

This signal confirms to the calling workflow (kickstart, bootstrap, or manual) that the feature was successfully created.
</step>

</process>

<guardrails>
- Use AskUserQuestion for feature selection — never assume
- If roadmap has features, present them as options
- Create proper directory structure before entering discovery
- Update STATE.md after every step — enables resume via /cks:next if interrupted
- ALWAYS validate the feature directory exists before invoking discover
- ALWAYS display the completion signal — callers depend on it for validation
</guardrails>
