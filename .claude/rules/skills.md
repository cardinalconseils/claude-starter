---
globs: "skills/**/SKILL.md"
---

# Skill Rules

- Skills are domain expertise, not process scripts — they describe WHAT, not step-by-step HOW
- YAML frontmatter MUST include: `name`, `description`, `allowed-tools`
- `description` field determines auto-triggering — make it keyword-rich and specific
- Keep SKILL.md under 250 lines — extract step-by-step processes to `workflows/` subdirectory
- Workflow files (`workflows/*.md`) are progressive disclosure — agents read them when needed
- Reference files (`references/*.md`) hold static lookup data (templates, checklists, validation)
- NEVER embed sequential execution logic in SKILL.md — that belongs in commands or workflows
