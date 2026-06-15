---
date: 2026-06-15
source: anthropic
title: Making frontier cybersecurity capabilities available to defenders
priority: MEDIUM
type: OPPORTUNITY
affects: [security-hardening, api-design]
action_required: false
expires: 2026-12-12
---

## What Changed
Anthropic released Claude Code Security in limited research preview — a capability built into Claude Code on the web that scans codebases for security vulnerabilities and generates targeted software patches for human review. In internal testing it found over 500 vulnerabilities in production open-source codebases undetected for decades. Full details at https://www.anthropic.com/news/claude-code-security

## Impact on Agents
CKS security-auditor and prd-verifier agents should know this capability exists. For Candidate/Production stage projects, check https://www.anthropic.com/news/claude-code-security for how to request research preview access before the next major release. This could replace or augment manual security review steps in the sprint lifecycle.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://www.anthropic.com/news/claude-code-security
