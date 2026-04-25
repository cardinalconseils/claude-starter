# Workflow: OpenRouter Model Research & Human Selection

## Purpose

Research live model candidates for a specific task type, present ranked options to the human with pricing and trade-offs, and write the human's selection to config. AI proposes — human decides.

## Input

- Task description from the user or from `.kickstart/context.md`
- Task type from `skills/openrouter/references/task-profiles.md`

## Steps

### Step 1: Identify the Task

If the task type is not already known from context, ask:

```
AskUserQuestion:
  question: "What kind of AI task does this project need a model for?"
  options:
    - "Fast summarization or extraction (speed + cost matter most)"
    - "Complex reasoning or planning (quality matters most)"
    - "Code generation or review (reasoning + context length)"
    - "Structured output / JSON extraction (reliability matters)"
    - "Long-context analysis (very long documents or codebases)"
    - "Conversational / chatbot (balanced speed + quality)"
    - "Image or multimodal understanding"
    - "Other (describe)"
```

Map the answer to a task profile from `skills/openrouter/references/task-profiles.md`.

### Step 2: Fetch Live Model Catalog

Fetch the OpenRouter model catalog:
```
WebFetch: https://openrouter.ai/api/v1/models
```

Parse the response — each model has:
- `id` — provider/model-name (e.g., `anthropic/claude-haiku-4-5`)
- `pricing.prompt` — cost per token (input), multiply by 1M for $/M tokens
- `pricing.completion` — cost per token (output), multiply by 1M for $/M tokens
- `context_length` — max tokens
- `description` — capabilities summary

If the fetch fails, fall back to the catalog in `skills/openrouter/references/task-profiles.md` (known models section).

### Step 3: Filter & Rank Candidates

Using the task profile weights from `task-profiles.md`:

1. **Exclude** models with context_length below the task minimum
2. **Score** remaining models on: price rank, context size, known quality tier
3. **Select top 4–5 candidates** across different price tiers (at least one budget, one mid, one frontier)
4. **Research each candidate**: visit `https://openrouter.ai/models/{id}` to verify current details

Aim for diversity: don't present 5 Anthropic models. Cover 2–3 providers minimum.

### Step 4: Build Candidate Reports

For each candidate, construct a report card:

```
### {Model Display Name} — {provider/model-id}
- **Price:** ${input}/M input · ${output}/M output
- **Context:** {context_length} tokens
- **Best for:** {2-3 word strength summary}
- **Pros:** {2-3 specific strengths for THIS task type}
- **Cons:** {1-2 specific weaknesses or limitations}
- **URL:** https://openrouter.ai/models/{provider}/{model-id}
```

Price display rules:
- Under $0.10/M: show as "$0.0X/M" — highlight as budget option
- $0.10–$1.00/M: mid-tier
- Over $1.00/M: frontier — note premium

### Step 5: Present to Human

Display all candidate report cards in a single message (not via AskUserQuestion — show the full research first so the human can read URLs and details).

Then ask:

```
AskUserQuestion:
  question: "Which model do you want to use for {task type}?"
  options:
    - "{Model A} — {price summary}"
    - "{Model B} — {price summary}"
    - "{Model C} — {price summary}"
    - "{Model D} — {price summary}"
    - "None of these — I'll specify another model"
```

Wait for human selection. If "None of these", ask them to type the model ID.

### Step 6: Confirm & Write Config

Confirm the selection:
```
✅ Selected: {provider/model-id}
   Task: {task type}
   Price: ${input}/M in · ${output}/M out
```

Write to `.env.example` in the target project:
- Find the `OPENROUTER_MODEL_*` variable matching the task tier
- If it doesn't exist, append it with the selected model as value
- Add a comment with the model URL

```bash
# Fast tasks (summarization, extraction)
OPENROUTER_MODEL_FAST=google/gemini-flash-2.0  # https://openrouter.ai/models/google/gemini-flash-2.0
```

If `.env.example` doesn't exist yet, note the variable to add — don't create the file unilaterally.

### Step 7: Offer Additional Task Types

```
AskUserQuestion:
  question: "Do you need to select models for additional task types?"
  options:
    - "Yes — select another model for a different task type"
    - "No — done with model selection"
```

If yes, return to Step 1 for the next task type.

## Output

- Human-selected model IDs documented in `.env.example`
- Each selection confirmed with URL for human verification
- Task-to-model mapping ready for the stack summary in `.kickstart/stack.md`
