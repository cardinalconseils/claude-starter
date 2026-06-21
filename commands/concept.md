---
description: "Evaluate a concept for CKS plugin (or project) feasibility — enters plan mode first, then reads external resources (URLs, GitHub repos, articles, transcripts), brainstorms, scores across business value, technology fit, and data impact. Produces FEASIBILITY.md."
argument-hint: "[concept description | URL | GitHub repo URL | pasted article/transcript]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
  - EnterPlanMode
  - WebFetch
---

# /cks:concept — Concept Feasibility Evaluator

Evaluate whether a new concept (command, agent, skill, hook, workflow, rule, or integration) is worth adding to the CKS plugin — or to a CKS-powered project. Also evaluates whether an existing concept should be replaced, enhanced, or pruned.

ALWAYS enters plan mode first. Then reads and deeply understands any external resource before evaluation begins.

## Dispatch

```
# Step 1: Enter plan mode (ALWAYS FIRST — deterministic, non-negotiable)
EnterPlanMode

# Step 2: Detect input type
Examine $ARGUMENTS:
  - URL starting with http:// or https:// (including github.com) → type: url
  - Large text block > 100 words (pasted article, transcript, guide) → type: text
  - Short description (< 100 words, no URL) → type: description
  - Empty → AskUserQuestion:
      question: "What concept do you want to evaluate?"
      header: "Concept Input"
      options:
        - label: "Paste a URL or GitHub repo"
          description: "Article, blog post, GitHub repo, or docs page to extract concept from"
        - label: "Paste a transcript or guide"
          description: "YouTube transcript, PDF extract, or long-form text"
        - label: "Describe the concept"
          description: "Short description of what you want to evaluate"
        - label: "Prune an existing concept"
          description: "Evaluate retiring a command, agent, or skill with no replacement"

# Step 3: Dispatch orchestrator with input type flagged
Agent(
  subagent_type="cks:concept-orchestrator",
  prompt="Input: {$ARGUMENTS or user answer}. Input type: {url|text|description|prune}. Run the full pipeline: ingest external resource if applicable, detect mode, classify type, scan codebase, run supersession scan, run brainstorming interactively, confirm refined concept, dispatch 3 parallel pillar workers, aggregate, write FEASIBILITY.md, display scorecard."
)
```

## Quick Reference

```
/cks:concept                        — prompts for concept description
/cks:concept "add voice transcription skill"   — evaluates immediately
/cks:concept "add Stripe webhook retry"        — works in plugin or project
```

## What It Produces

`.concept/{slug}/FEASIBILITY.md` — scored feasibility report with:
- External Resource summary (when URL or text input provided)
- Business Value (1–5) with evidence
- Technology Fit (1–5) with evidence
- Data Impact (1–5) with evidence
- Continuous Improvement Impact (supersession decision + net surface change)
- Overall score + Go / Defer / Reject recommendation
- Klein pre-mortem risks (for Go verdicts)
- Next step (branch name for plugin mode; `/cks:new` for project mode)

## When to Use

- When you find a new tool, library, framework, or guide and want to extract a CKS concept from it
- Before `/cks:new` — validate the concept is worth a full discovery cycle
- When you have an idea for a new CKS command, agent, or skill
- When evaluating whether an existing concept should be replaced, enhanced, or pruned
- When evaluating whether to add a feature to a project that uses CKS
