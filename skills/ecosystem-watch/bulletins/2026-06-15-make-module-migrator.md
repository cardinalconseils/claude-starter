---
date: 2026-06-15
source: make
title: Introducing Module Migrator for deprecated app integrations
priority: MEDIUM
type: ENHANCEMENT
affects: [no-code, environment-management]
action_required: false
expires: 2026-12-12
---

## What Changed
Make launched Module Migrator — a tool that detects deprecated modules in existing scenarios, provides upgrade paths, and gives warnings with manual fix instructions for modules that cannot be auto-migrated. First use case: monday.com V1 API deprecation (cutover was May 1, 2026). Full details at https://help.make.com/introducing-module-migrator

## Impact on Agents
CKS agents managing Make-based workflows should run Module Migrator on any scenario using older app integrations. Check https://help.make.com/introducing-module-migrator for the current list of deprecated modules — any scenario touching monday.com V1 endpoints is already broken post-May 1.

## Required Pattern Going Forward
No pattern change required — check source URL for details.

## Reference
https://help.make.com/introducing-module-migrator
