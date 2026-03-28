# PROJECT-MANIFEST.md Template (Project Composition Output)

Use this template when the compose phase writes project composition to `.kickstart/manifest.md` and later copied to `.prd/PROJECT-MANIFEST.md` during handoff.

All sections are REQUIRED. For single sub-project projects, the Shared Concerns section can be marked N/A and the Build Order is trivial.

---

```markdown
# Project Manifest: {Project Name}

**Created:** {YYYY-MM-DD}
**Updated:** {YYYY-MM-DD}
**Sub-Projects:** {count}
**Shared Concerns:** {count}

---

## Sub-Projects

### SP-{NN}: {Sub-Project Name}
- **Type:** {deployment-target | audience-app | shared-service | infrastructure}
- **Description:** {one-line purpose}
- **Stack suggestion:** {framework / language / platform}
- **Depends on:** {SP-XX (Name), SC-XX (Name) | — (none)}
- **Depended on by:** {SP-XX (Name) | — (none)}
- **Priority:** {N} ({build first | build after X | can parallel with X})

{Repeat for each sub-project}

---

## Shared Concerns

### SC-{NN}: {Concern Name}
- **Category:** {auth | payments | notifications | storage | search | messaging | other}
- **Used by:** {SP-XX, SP-XX, ...}
- **Strategy:** {brief technical approach}
- **Notes:** {alignment requirements — shared tokens, naming conventions, data formats}

{Repeat for each shared concern. Write "N/A — single sub-project, no shared concerns." if only 1 sub-project.}

---

## Infrastructure

### INFRA-{NN}: {Component Name}
- **Type:** {database | queue | cdn | monitoring | ci-cd | cache | other}
- **Used by:** {SP-XX, SC-XX, ...}
- **Provider suggestion:** {service / self-hosted}
- **Notes:** {sizing, scaling, or configuration notes}

{Repeat for each infrastructure component. Can be empty if infrastructure is implicit in stack choices.}

---

## Dependency Graph

```mermaid
graph TD
    {INFRA-NN}[{Infrastructure Name}] --> {SP-NN}[{Sub-Project Name}]
    {SC-NN}[{Shared Concern Name}] --> {SP-NN}[{Sub-Project Name}]
    {SP-NN}[{Sub-Project Name}] --> {SP-NN}[{Dependent Sub-Project}]
```

---

## Build Order

Priority groups — items in the same group can be built in parallel:

1. **Foundation:** {INFRA-XX, SC-XX — infrastructure and shared concerns}
2. **Core:** {SP-XX — the primary sub-project others depend on}
3. **Parallel:** {SP-XX, SP-XX — sub-projects that can be built concurrently}
4. **Final:** {SP-XX — sub-projects with the most dependencies}

---

## Cross-Project Contracts

Agreements that sub-projects must honor for alignment:

| Contract | Owner | Consumers | Type | Notes |
|----------|-------|-----------|------|-------|
| {API endpoint pattern} | SP-{NN} | SP-{NN}, SP-{NN} | API | {e.g., REST /api/v1, JSON responses} |
| {Auth token format} | SC-{NN} | SP-{NN}, SP-{NN} | Auth | {e.g., JWT with standard claims} |
| {Data model naming} | INFRA-{NN} | All | Schema | {e.g., snake_case, soft deletes} |
| {Event format} | SP-{NN} | SP-{NN} | Events | {e.g., CloudEvents schema} |

---

## Composition Method

{Guided Q&A during kickstart | Auto-detected from codebase | Manual}
```
