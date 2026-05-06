---
name: {{DOMAIN_SLUG}}
domain: {{DOMAIN}}
description: "{{DOMAIN}} skill for {{PROJECT}} — defines how Claude executes recurring {{DOMAIN}} tasks"
---

# {{DOMAIN}} — Skill

## Purpose

Describe what this domain covers in 1-2 sentences. What kind of work lives here?

## Recurring Tasks

### Task: {{TASK_1}}

**When**: Describe the trigger — when does this task happen?

**Output**: What does Claude produce? (file, report, message, etc.)

**Instructions**:
1. Step one
2. Step two
3. Step three

**Quality bar**: What does "done" look like?

---

### Task: {{TASK_2}}

**When**: 

**Output**: 

**Instructions**:
1. 
2. 

**Quality bar**: 

---

## Context Sources

Where does Claude look for input when running these tasks?

- `memory/wiki/` — [what to look for]
- `memory/raw/` — [what staging material to check]
- [other sources]

## Output Destinations

Where do results go?

- Final deliverables → `memory/output/`
- Reusable knowledge → `memory/wiki/`
- Work in progress → `memory/raw/`
