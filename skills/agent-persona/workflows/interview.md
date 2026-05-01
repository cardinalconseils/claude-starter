# Interview Workflow — Populating the Persona Cards

Run by the `persona-interviewer` agent, dispatched by `/cks:persona`.
ALL questions MUST be `AskUserQuestion` tool calls — never text output.

Text output = dead questions the user must type back.
Tool call = interactive prompt the user clicks through.

## Before Starting

Use `Read` to check the current state of:
- `skills/agent-persona/persona-card.md`
- `skills/agent-persona/behavior-rules.md`
- `skills/agent-persona/knowledge-index.md`

If any file contains non-placeholder content (fields have real values), ask before proceeding:

AskUserQuestion: "Cards already exist. What would you like to do?"
Options: ["Update existing values", "Start fresh (overwrite)"]

## Phase 1 — Persona Card

### Q1: Role name

AskUserQuestion:
- question: "What role should this agent play? Describe it in a few words."
- examples: "Senior Legal Advisor", "Friendly Customer Support Rep", "Technical Coach"

Record as `role`.

### Q2: Purpose

AskUserQuestion:
- question: "In one sentence, what does this agent do and for whom?"
- example: "Helps small business owners understand legal contracts without jargon"

Record as `purpose`.

### Q3: Tone

AskUserQuestion:
- question: "How should this agent communicate? Select descriptors."
- type: multiple-choice, multi-select
- options: ["formal", "casual", "empathetic", "direct", "precise", "warm",
             "technical", "educational", "concise", "thorough", "other (I'll describe)"]

If "other": follow-up AskUserQuestion for custom descriptors.
Record as `tone` (comma-separated).

### Q4: Always behaviors (required — minimum 1)

AskUserQuestion:
- question: "What should this agent ALWAYS do, no matter what? First behavior:"
- example: "Always cite sources when giving legal information"

Record the answer. Then loop:

AskUserQuestion:
- question: "Add another 'always' behavior, or move on?"
- options: ["Add another", "Move on"]

If "Add another": ask for the next behavior and record it. Repeat until "Move on".

**Enforcement:** If the user tries to move on with zero entries recorded, re-ask Q4:
"At least one 'always' behavior is required. What should this agent always do?"
Do not proceed until at least one entry is recorded.

Record as `always` bulleted list.

### Q5: Never behaviors (required — minimum 1)

AskUserQuestion:
- question: "What should this agent NEVER do? First constraint:"
- example: "Never give a definitive legal verdict — always recommend professional review"

Record the answer. Then loop:

AskUserQuestion:
- question: "Add another 'never' constraint, or move on?"
- options: ["Add another", "Move on"]

If "Add another": ask for the next constraint and record it. Repeat until "Move on".

**Enforcement:** If the user tries to move on with zero entries recorded, re-ask Q5:
"At least one 'never' constraint is required. What should this agent never do?"
Do not proceed until at least one entry is recorded.

Record as `never` bulleted list.

### Q6: Escalation triggers (optional)

AskUserQuestion:
- question: "When should this agent stop and hand off to a human? (or skip)"
- options: ["Add a trigger", "Skip — use default"]

If "Add a trigger": ask for the trigger, record it, then loop with "Add another or done?".
If "Skip": record default: "When the user explicitly requests a human."

Record as `escalate` bulleted list.

## Phase 2 — Behavior Rules (optional)

### Q7: Reasoning patterns

AskUserQuestion:
- question: "How should this agent think through problems? Add a reasoning habit for this role. (or skip)"
- options: ["Add a rule", "Skip"]
- format: "When [situation], [reasoning pattern]"
- example: "When asked for advice, always check for known risks before responding"

If "Add a rule": ask for the rule, record it, then loop with "Add another or done?".
If "Skip": leave `behavior-rules.md` at template defaults.

Record as `rules` bulleted list.

## Phase 3 — Knowledge Index (optional)

### Q8: Knowledge sources

AskUserQuestion:
- question: "Does this agent need access to specific documents or databases? (or skip)"
- options: ["Add a source", "Skip"]

If "Skip": leave `knowledge-index.md` at template defaults.

For each source, ask in sequence:

**Q8a: Source name**
AskUserQuestion: "What is the name of this knowledge source?"

**Q8b: Location**
AskUserQuestion: "Where is '[source name]' stored? (file path, URL, or API endpoint)"

**Q8c: Retrieval strategy**
AskUserQuestion:
- question: "How should the agent access '[source name]'?"
- options:
  - "Static — small file, inject at session start (< ~50 pages)"
  - "RAG — large/dynamic content, query a vector store at runtime"
  - "Fine-tune — behavior-critical, registered trained model endpoint"

**Q8d: Notes (optional)**
AskUserQuestion:
- question: "Any notes about '[source name]'? (scope, freshness — or skip)"
- options: ["Add notes", "Skip"]

After each source:
AskUserQuestion: "Add another knowledge source, or finish?"
Options: ["Add another", "Finish"]

## Validation Before Writing

Before writing any file, verify required fields are non-empty:

1. `role` — non-empty string
2. `purpose` — non-empty string
3. `tone` — at least one descriptor
4. `always` — at least one item (enforced in Q4 loop)
5. `never` — at least one item (enforced in Q5 loop)

If any required field is empty (can happen if user found a workaround), re-ask the
relevant question. Do not write partial cards.

## Writing the Cards

Use the `Write` tool to overwrite all three files with the collected values substituted
into the template structure:

1. Write `<base_path>/persona-card.md` — replace placeholder comments with collected values
2. Write `<base_path>/behavior-rules.md` — replace placeholder with collected rules list
3. Write `<base_path>/knowledge-index.md` — replace commented examples with collected sources

Where `<base_path>` is:
- `skills/agent-persona/` in interview mode (this project)
- `<scaffold_path>/skills/agent-persona/` in scaffold mode

After writing, report:
```
Persona configured. Cards written to:
- <base_path>/persona-card.md
- <base_path>/behavior-rules.md
- <base_path>/knowledge-index.md

To activate this persona, add `agent-persona` to an agent's `skills:` frontmatter:

  skills:
    - core-behaviors
    - agent-persona

To update later, run /cks:persona again.
```

## Scaffold Mode

Scaffold mode is triggered when the command passes `scaffold_path` to the agent.

Behavior difference from interview mode:
- Before running the interview, copy the entire `skills/agent-persona/` directory
  from the CKS repo to `<scaffold_path>/skills/agent-persona/` using the `Bash` tool:
  `cp -r skills/agent-persona/ <scaffold_path>/skills/agent-persona/`
- If `<scaffold_path>/skills/agent-persona/` already exists, check with the user:
  AskUserQuestion: "skills/agent-persona/ already exists at <scaffold_path>. Overwrite?"
  Options: ["Yes, overwrite", "No, cancel"]
- Set `base_path = <scaffold_path>/skills/agent-persona/` for all card writes
- All interview questions and validation are identical to interview mode
