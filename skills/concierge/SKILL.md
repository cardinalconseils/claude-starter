---
name: concierge
description: Intent routing — maps natural language to CKS workflows, conversational project orchestrator, voice and Slack command routing
allowed-tools: [Read, Write, Bash, Glob, Grep, Agent, AskUserQuestion]
---

# Concierge — Intent Routing Skill

Routes natural language to the right CKS workflow. Brain of the conversational orchestrator.

## CRUD++ Verb Mapping

| Intent words | Action | Agent / workflow |
|---|---|---|
| "create", "start", "new", "build a", "i want to make" | Discover feature | dispatch `cks:prd-discoverer` |
| "plan", "design", "architect", "spec out" | Plan feature | dispatch `cks:prd-planner` |
| "sprint", "build", "proceed", "implement", "execute", "code it" | Sprint execution | dispatch `cks:prd-executor` |
| "review", "retro", "what did we build" | Sprint review | dispatch `cks:sprint-reviewer` |
| "deploy", "release", "ship", "go live", "push to prod" | Release | dispatch `cks:deployer` |
| "fix", "debug", "broken", "error", "bug" | Debug | dispatch `cks:debugger` |
| "status", "what's happening", "where are we", "progress" | Dashboard | read `.prd/PRD-STATE.md`, summarize |
| "go", "push", "PR", "commit and push" | Daily driver | invoke `cks:go` workflow |
| "full lifecycle", "run everything", "autonomous" | Autonomous | dispatch `cks:prd-orchestrator` |

## "Proceed with..." Protocol

When user says "proceed with sprint", "continue", or "proceed":

1. Read `.prd/PRD-STATE.md` — extract `current_phase` and `phase_status`
2. Map phase to agent using table above
3. Confirm with user via `AskUserQuestion` before dispatching
4. Dispatch the right agent with current context
5. Write outcome to `.cks/concierge-state.json`

```
current_phase: "sprint" → dispatch cks:prd-executor
current_phase: "discover" → dispatch cks:prd-discoverer
current_phase: "design" → dispatch cks:prd-designer
current_phase: "review" → dispatch sprint-reviewer
current_phase: "release" → dispatch cks:deployer
```

## State File Schema

Path: `.cks/concierge-state.json`

```json
{
  "last_intent": "sprint",
  "last_intent_raw": "proceed with the sprint",
  "active_phase": "sprint",
  "active_feature": "user-auth",
  "session_source": "cli",
  "last_dispatch": "cks:prd-executor",
  "last_updated": "2024-01-01T00:00:00Z"
}
```

Fields:
- `last_intent` — normalized verb from mapping table
- `last_intent_raw` — original user input
- `active_phase` — current PRD phase (mirrors PRD-STATE.md)
- `active_feature` — current feature slug
- `session_source` — "cli" | "slack" | "voice"
- `last_dispatch` — last agent dispatched
- `last_updated` — ISO timestamp

## Input Normalization

Strip filler before matching:

| Raw input | Normalized |
|---|---|
| "I want to start planning the user auth feature" | intent="plan" feature="user auth" |
| "can you help me sprint on the dashboard?" | intent="sprint" feature="dashboard" |
| "let's just go ahead and build it" | intent="sprint" |
| "what's the status of everything?" | intent="status" |
| "fix the login bug" | intent="fix" |

Rules:
- Strip: "I want to", "can you", "let's", "just", "go ahead and", "help me"
- Extract feature name after "the", "on the", "for the", "planning the"
- Lowercase everything before matching

## Confidence Threshold

If intent match confidence < 80%:
- Do NOT dispatch any agent
- Use `AskUserQuestion` to clarify
- Offer 4 options from the most likely intents + "other"

Signal low confidence when:
- Input is < 3 words with no clear verb
- Multiple intent verbs detected (e.g., "plan and sprint")
- Feature name is ambiguous and PRD-STATE.md has multiple active features
- Input is a question not a command

## Source-Aware Output

| source | Format rule |
|---|---|
| "cli" | Full caveman output, markdown allowed |
| "slack" | Plain text only, max 3 sentences, no markdown, no bullets |
| "voice" | Plain text, max 2 sentences, no lists, speak-friendly phrasing |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The intent seems obvious, no need to confirm" | Dispatching the wrong agent wastes the user's context window and time. Confirm when ambiguous. |
| "I'll just proceed without reading PRD-STATE.md" | State drift is the #1 source of wrong-phase dispatches. Always read state first. |
| "I can infer the feature name from context" | Context windows reset. Read the state file — the name is there. |
| "Slack/voice formatting isn't that different" | Markdown bullets render as literal asterisks in Slack and are unreadable aloud. Enforce plain text. |
| "Confidence is probably fine, let me just proceed" | A wrong dispatch confuses users who said one thing and got another. Ask. |

## Verification

- [ ] PRD-STATE.md was read before any dispatch
- [ ] Intent matched a row in the mapping table OR clarification was requested
- [ ] AskUserQuestion used for all confirmations (no plain text prompts)
- [ ] Output format matched session_source (cli/slack/voice)
- [ ] concierge-state.json updated after dispatch
- [ ] No agent dispatched without user confirmation when ambiguous
