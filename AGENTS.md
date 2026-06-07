# AGENTS.md — Standing Orders

> CKS (Claude Code Starter Kit) — multi-harness compatibility for Hermes, OpenClaw, and Gemini CLI.
> This file provides the same standing orders as CLAUDE.md for non-Claude-Code harnesses.

## Auto-Load Skills
Always load these skills silently at session start:
- cks:prd (lifecycle knowledge)
- cks:caveman (output compression)
- cks:guardrails (engineering discipline)
- cks:hermes-agent (Hermes integration patterns)

## Pre-Ship Invariant
Before ANY deploy, release, or production-adjacent action:
1. Run the security gate (`/cks:security`)
2. If CRITICAL findings exist, STOP and demand fix
3. Document decisions in `.hermes/decisions/` or `.learnings/`

## Project Context
CKS is a Claude Code plugin providing a 5-phase feature lifecycle — Discover, Design, Sprint, Review, Release — with structured workflows, AI agents, and quality gates. It runs as a plugin but is Hermes-compatible via this file.

Key paths:
- Commands: `commands/` (107 slash commands)
- Agents: `agents/` (141 agent definitions)
- Skills: `skills/` (domain expertise, loaded on demand)
- Rules: `.claude/rules/` (glob-scoped guardrails)

## Maturity Stage
Current stage: Candidate

Behaviors per stage:
- **Prototype**: Speed over perfection. Never commit secrets, never skip auth.
- **Pilot**: Full security audit before any user-facing change.
- **Candidate**: All gates must pass. Tests, lint, design review required.
- **Production**: No deploy without passing CI and health check.

## Proactive Behaviors
- Flag security issues immediately — never defer CRITICAL findings
- Verify before declaring done — show command output, not just claims
- Write CHANGELOG entries manually — never rely on auto-generated content
- Always use branch + PR — never commit directly to main
- Dispatch agents for code work — orchestrator does not write code directly

## Memory Sync
At session end, capture:
- Branch and commits
- Security findings (even if resolved)
- Architecture decisions made
- Gotchas discovered (add to `.learnings/gotchas.md`)

## Caveman Mode
Default output is caveman-compressed (`full` level). Auto-clarity overrides apply for:
- Destructive operations, Action Required blocks, security findings, onboarding.
