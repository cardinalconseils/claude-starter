---
version: 1
active_feature: F-01
active_phase: P-01
features:
  - id: F-01
    title: "Applicant CSV export"
    status: doing
    slug: csv-export
    phases:
      - id: P-01
        title: "Export endpoint"
        status: doing
        slug: export-endpoint
        tasks:
          - id: T-01-01
            title: "Serialize applicants to CSV"
            status: done
          - id: T-01-02
            title: "Auth guard on export route"
            status: todo
---

# Work Hierarchy

_Auto-managed by the project-manager. Edit via `/cks:work` only._
