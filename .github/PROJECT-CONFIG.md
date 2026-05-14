# GitHub Projects v2 Configuration — CKS v5 Migration

> Configuration record for the **CKS v5 Migration — Attractor Spine** GitHub Project.
> Use these IDs for GraphQL mutations, API calls, and automation workflows.

## Project Overview

- **Title:** CKS v5 Migration — Attractor Spine
- **Project Number:** 4
- **Project ID:** PVT_kwHOCtKzxM4BXt3x
- **Project URL:** https://github.com/users/cardinalconseils/projects/4
- **Owner:** cardinalconseils (user)
- **Repository:** cardinalconseils/claude-starter

---

## Status Field Configuration

The **Status** field is a single-select field that manages the pipeline state for each phase item.

**Field ID:** PVTSSF_lAHOCtKzxM4BXt3xzhS42H8

### Status Options (in order)

| Option Name | Option ID | Color |
|---|---|---|
| Backlog | ad49b1dc | GRAY |
| Ready | f48c9e53 | BLUE |
| In Progress | 8162feba | YELLOW |
| In Review | bf076149 | PURPLE |
| Blocked | a692d1d4 | RED |
| Done | 6bdb640c | GREEN |

---

## Custom Fields Configuration

| Field Name | Field ID | Data Type | Purpose |
|---|---|---|---|
| Phase Number | PVTF_lAHOCtKzxM4BXt3xzhS42P0 | NUMBER | Numeric identifier (0–8) for each migration phase |
| Runner State | PVTF_lAHOCtKzxM4BXt3xzhS42P4 | TEXT | Current worker state or action being taken |
| PR Count | PVTF_lAHOCtKzxM4BXt3xzhS42Qw | NUMBER | Number of pull requests associated with the phase |
| Last Sync | PVTF_lAHOCtKzxM4BXt3xzhS42Q0 | TEXT | ISO 8601 timestamp of last automated sync |

---

## Phase Items Configuration

All 9 phase items are draft issues (not linked to repository issues).

### Phase 0 — Foundation, Safety Net, Project Setup

- **Item ID:** PVTI_lAHOCtKzxM4BXt3xzgswcC4
- **Current Status:** In Progress (8162feba)
- **Phase Number:** 0

### Phase 1 — Bridge State Systems

- **Item ID:** PVTI_lAHOCtKzxM4BXt3xzgswcEE
- **Current Status:** Backlog (ad49b1dc)
- **Phase Number:** 1

### Phase 2 — Expand SprintReview + Parallel Dispatch Layer

- **Item ID:** PVTI_lAHOCtKzxM4BXt3xzgswcFU
- **Current Status:** Backlog (ad49b1dc)
- **Phase Number:** 2

### Phase 3 — Release Node

- **Item ID:** PVTI_lAHOCtKzxM4BXt3xzgswcGA
- **Current Status:** Backlog (ad49b1dc)
- **Phase Number:** 3

### Phase 4 — Wire Entry Points

- **Item ID:** PVTI_lAHOCtKzxM4BXt3xzgswcGg
- **Current Status:** Backlog (ad49b1dc)
- **Phase Number:** 4

### Phase 5 — Agentic OS Data Layer

- **Item ID:** PVTI_lAHOCtKzxM4BXt3xzgswcHE
- **Current Status:** Backlog (ad49b1dc)
- **Phase Number:** 5

### Phase 6 — Bidirectional Kanban Automation

- **Item ID:** PVTI_lAHOCtKzxM4BXt3xzgswcHk
- **Current Status:** Backlog (ad49b1dc)
- **Phase Number:** 6

### Phase 7 — Archive Legacy, Update Session Commands

- **Item ID:** PVTI_lAHOCtKzxM4BXt3xzgswcIc
- **Current Status:** Backlog (ad49b1dc)
- **Phase Number:** 7

### Phase 8 — Docs, Migration Script, v5.0.0 Release

- **Item ID:** PVTI_lAHOCtKzxM4BXt3xzgswcJc
- **Current Status:** Backlog (ad49b1dc)
- **Phase Number:** 8

---

## Default Fields (Built-In)

These fields are automatically created with every GitHub Project and cannot be deleted:

| Field Name | Field ID | Type |
|---|---|---|
| Title | PVTF_lAHOCtKzxM4BXt3xzhS42H0 | Built-in |
| Assignees | PVTF_lAHOCtKzxM4BXt3xzhS42H4 | Built-in |
| Labels | PVTF_lAHOCtKzxM4BXt3xzhS42IA | Built-in |
| Linked pull requests | PVTF_lAHOCtKzxM4BXt3xzhS42IE | Built-in |
| Milestone | PVTF_lAHOCtKzxM4BXt3xzhS42II | Built-in |
| Repository | PVTF_lAHOCtKzxM4BXt3xzhS42IM | Built-in |
| Reviewers | PVTF_lAHOCtKzxM4BXt3xzhS42IQ | Built-in |
| Parent issue | PVTF_lAHOCtKzxM4BXt3xzhS42IU | Built-in |
| Sub-issues progress | PVTF_lAHOCtKzxM4BXt3xzhS42IY | Built-in |

---

## GraphQL Usage Examples

### Move an item to "In Progress"

```graphql
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "PVT_kwHOCtKzxM4BXt3x"
    itemId: "PVTI_lAHOCtKzxM4BXt3xzgswcC4"
    fieldId: "PVTSSF_lAHOCtKzxM4BXt3xzhS42H8"
    value: {
      singleSelectOptionId: "8162feba"
    }
  }) {
    projectV2Item {
      id
    }
  }
}
```

### Update custom field "Last Sync"

```graphql
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "PVT_kwHOCtKzxM4BXt3x"
    itemId: "PVTI_lAHOCtKzxM4BXt3xzgswcC4"
    fieldId: "PVTF_lAHOCtKzxM4BXt3xzhS42Q0"
    value: {
      text: "2025-05-14T14:30:00Z"
    }
  }) {
    projectV2Item {
      id
    }
  }
}
```

### Update custom field "Phase Number"

```graphql
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "PVT_kwHOCtKzxM4BXt3x"
    itemId: "PVTI_lAHOCtKzxM4BXt3xzgswcC4"
    fieldId: "PVTF_lAHOCtKzxM4BXt3xzhS42P0"
    value: {
      number: 0
    }
  }) {
    projectV2Item {
      id
    }
  }
}
```

### Query project items and their field values

```graphql
{
  node(id: "PVT_kwHOCtKzxM4BXt3x") {
    ... on ProjectV2 {
      items(first: 10) {
        edges {
          node {
            id
            fieldValues(first: 10) {
              edges {
                node {
                  ... on ProjectV2ItemFieldValueCommon {
                    field {
                      ... on ProjectV2Field {
                        name
                      }
                    }
                  }
                  ... on ProjectV2ItemFieldValueSingleSelect {
                    name
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

---

## Automation Endpoints

To use these IDs in CI/CD or automation workflows:

- **List items in phase:** Query by project ID and filter/sort by "Phase Number" custom field
- **Move phase to next status:** Use `updateProjectV2ItemFieldValue` with the appropriate Status option ID
- **Sync metadata:** Update "Last Sync" field with ISO 8601 timestamp after each automated workflow

---

## Created

- **Date:** 2025-05-14
- **Created by:** prd-executor-worker (Task 0.3)
- **Configuration version:** 1.0
