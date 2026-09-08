---
description: "Evaluate a concept for CKS plugin (or project) feasibility — enters plan mode first, then reads external resources (URLs, GitHub repos, articles, transcripts), brainstorms, scores across business value, technology fit, and data impact. Produces FEASIBILITY.md."
argument-hint: "[concept description | URL | GitHub repo URL | pasted article/transcript]"
allowed-tools:
  - Read
  - Skill
  - AskUserQuestion
  - EnterPlanMode
---

# /cks:concept — Concept Feasibility Evaluator

Evaluate whether a new concept (command, agent, skill, hook, workflow, rule, or
integration) is worth adding to CKS or a CKS-powered project — or whether an existing one
should be replaced, enhanced, or pruned.

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
        - "Paste a URL or GitHub repo" — article, blog post, repo, or docs page
        - "Paste a transcript or guide" — YouTube transcript, PDF extract, long-form text
        - "Describe the concept" — short description
        - "Prune an existing concept" — retire a command, agent, or skill with no replacement

# Step 3: Load the evaluation loop (Orchestrator Exception — pillars dispatch in parallel)
Skill(skill="cks:concept-evaluation")
```

Input: `{$ARGUMENTS or user answer}` · Input type: `{url|text|description|prune}`. The
skill's `SKILL-ORCHESTRATOR.md` ingests the resource, detects mode, classifies, runs the
supersession scan and interactive brainstorm, dispatches three `cks:strategist` pillar
scorers in one message, writes FEASIBILITY.md, shows the scorecard, and asks the Klein
pre-mortem gate on Go.

## Quick Reference

```
/cks:concept                                   — prompts for concept description
/cks:concept "add voice transcription skill"   — evaluates immediately
/cks:concept https://github.com/some/tool      — extracts the concept from a repo
```

## What It Produces

`.concept/{slug}/FEASIBILITY.md` — external resource summary, three pillar scores with
evidence, Continuous Improvement Impact, overall Go / Defer / Reject, Klein pre-mortem
risks (Go), next step (branch name in plugin mode, `/cks:new` in project mode).
