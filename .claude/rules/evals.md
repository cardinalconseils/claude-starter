# Evals Rules

## Mandatory Behavior

When any feature description, CONTEXT.md, PLAN.md, or user message signals an LLM/AI component, the sprint planner and executor MUST run evals at the appropriate lifecycle gate. This is not a suggestion — it fires deterministically on pattern match.

## Trigger Patterns

Match is case-insensitive. Any single match is sufficient.

**LLM and AI signals**
- `LLM`, `language model`, `AI feature`, `AI component`
- `Claude`, `GPT`, `Gemini`, `prompt`, `system prompt`, `prompt engineering`
- `RAG`, `retrieval-augmented`, `memory store`, `vector search`, `embeddings`, `semantic search`
- `tool_use`, `tool use`, `function calling`, `structured output`, `JSON mode`, `response_format`
- `chatbot`, `chat interface`, `conversational`, `AI agent`, `autonomous agent`
- `guardrails`, `safety filter`, `refusal`, `content policy`
- `LLM-as-judge`, `LLM judge`, `eval`, `evals`

**Bootstrap and adopt signals**
- Project includes an AI/LLM component detected during `/cks:bootstrap` or `/cks:adopt`

## Required Behavior by Lifecycle Gate

### Sprint [3c] — Build Gate → Smoke Tier

Before declaring build complete:
1. Run smoke evals: `/cks:evals --type={detected_type} --tier=smoke "{feature}"`
2. Show results inline — "evals pass" with no table is not evidence
3. Block if any smoke case fails — a failing smoke eval is a build failure

### Sprint [4a] — Review Gate → Standard Tier

Before opening or approving a PR for an AI feature:
1. Run standard evals: `/cks:evals --type={detected_type} --tier=standard "{feature}"`
2. Paste the results table into the PR body
3. Block merge if pass rate < 95%

### Release [5c] — Production Gate → Comprehensive Tier

Before deploying to production:
1. Run comprehensive evals: `/cks:evals --type={detected_type} --tier=comprehensive "{feature}"`
2. Block release if pass rate < 90%

### Bootstrap / Adopt — Scaffold

When an AI/LLM component is detected:
1. Create `.evals/golden/{feature-name}/` with placeholder `README.md` explaining the structure
2. Create `.evals/judge-prompt.md` from the template in `skills/evals/SKILL.md`
3. Note in the sprint plan: "Smoke evals must be scaffolded before first commit"

## Eval Type Detection

When type is not specified by the user, infer from the feature:

| Feature Signal | Recommended Eval Type |
|---|---|
| Memory / RAG / vector store | `memory` |
| Direct LLM API call producing prose | `api` |
| Tool use / function calling | `tool` |
| Any prompt change | `regression` |
| User-facing chatbot / guardrails | `safety` |
| JSON mode / structured output | `structured` |

If ambiguous, ask. Do not silently pick a type.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "There's no golden set yet, I'll skip evals" | Scaffold the golden set. The evals agent will prompt the user to confirm cases before running. |
| "It's an early prototype, evals are overkill" | Smoke evals are 3 cases and <2 min. Skip them and you ship unknown quality. |
| "We can add evals after launch" | Post-launch evals reveal what's already broken in production. Run smoke pre-merge. |
| "The prompts didn't change, no need for regression evals" | Model versions change. Context windows shift. Run regression on every AI feature PR. |
| "LLM-as-judge is circular" | Judge uses a separate prompt, temperature=0, explicit rubric. Not circular. |
| "Standard evals block the PR — I'll add them later" | Later never comes. Wire evals into the PR as evidence. They are required. |
