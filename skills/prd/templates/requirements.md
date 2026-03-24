# REQUIREMENTS.md Template

Use this template for `.prd/PRD-REQUIREMENTS.md`. Requirements are tracked with unique IDs for traceability.

---

```markdown
# Requirements Registry

**Last Updated:** {YYYY-MM-DD}

## About

This file tracks all requirements across all features with unique IDs. Each requirement traces back to a PRD and forward to implementation.

## Requirements

| REQ-ID | Description | Source | Status | Phase |
|--------|-------------|--------|--------|-------|
<!-- Requirements are added here as features are planned -->

## ID Format

- **REQ-{NNN}**: Sequential requirement ID (REQ-001, REQ-002, ...)
- **Source**: PRD number (e.g., PRD-001) or user request
- **Status**: Proposed | Accepted | Implemented | Verified | Deferred | Dropped
- **Phase**: Which phase implements this requirement

## Adding Requirements

When a new PRD is created, extract functional requirements and add them here:

| REQ-{NNN} | {description} | PRD-{NNN} | Accepted | Phase {NN} |

When a requirement is implemented:
- Update status to "Implemented"

When verified:
- Update status to "Verified"
```
