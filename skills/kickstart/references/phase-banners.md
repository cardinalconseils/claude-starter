# Kickstart Phase 5 & 6 Sub-Step Banners

## Phase 5: Design Sub-Steps

**Design has 5 sub-steps per sub-project, each independently tracked. Each sub-step MUST complete and validate before the next begins.**

**[5a] ERD — Entity Relationship Diagram**
- Validate: `.kickstart/artifacts/ERD.md` exists with valid `erDiagram` block
- Update `state.md`: Design: ERD → `done`
- Display:
  ```
  [5a] ERD             ✅ done
       Output: .kickstart/artifacts/ERD.md — {N} entities, {N} relationships
  ```

**[5b] Schema — Database schema DDL (MANDATORY — do NOT skip)**
- **Gate:** `.kickstart/artifacts/ERD.md` MUST exist before starting this step. If missing, go back to 5a.
- Validate: `.kickstart/artifacts/schema.sql` exists with `CREATE TABLE` statements matching ERD entities
- Update `state.md`: Design: Schema → `done`
- Display:
  ```
  [5b] Schema          ✅ done
       Output: .kickstart/artifacts/schema.sql — {N} tables, {DB dialect} ({N} indexes)
  ```

**[5c] PRD — Product Requirements Document**
- **Gate:** `.kickstart/artifacts/schema.sql` MUST exist before starting this step. If missing, go back to 5b.
- Validate: `.kickstart/artifacts/PRD.md` exists with `## User Stories` and `## Functional Requirements`
- Update `state.md`: Design: PRD → `done`
- Display:
  ```
  [5c] PRD             ✅ done
       Output: .kickstart/artifacts/PRD.md — {N} user stories, {N} features
  ```

**[5d] API Design — Endpoint contracts and resource map (MANDATORY — do NOT skip)**
- **Gate:** `.kickstart/artifacts/PRD.md` MUST exist before starting this step. If missing, go back to 5c.
- Validate: `.kickstart/artifacts/API.md` exists with `## Endpoints` section containing endpoint tables
- Update `state.md`: Design: API → `done`
- Display:
  ```
  [5d] API Design      ✅ done
       Output: .kickstart/artifacts/API.md — {N} endpoints, {API style}
  ```

**[5e] Architecture — Architecture decisions**
- **Gate:** `.kickstart/artifacts/API.md` MUST exist before starting this step. If missing, go back to 5d.
- Validate: `.kickstart/artifacts/ARCHITECTURE.md` exists with `## Stack Decision` table
- Update `state.md`: Design: Architecture → `done`
- Display:
  ```
  [5e] Architecture    ✅ done
       Output: .kickstart/artifacts/ARCHITECTURE.md — Stack: {summary}
  ```

## Phase 6: Handoff Sub-Steps

**The handoff has 4 sub-steps, each independently tracked:**

**[6a] Bootstrap — Personalize .claude/**
- Validate: CLAUDE.md updated with project-specific content
- Update `state.md`: Bootstrap → `done`
- Display:
  ```
  [6a] Bootstrap      ✅ done
       Output: CLAUDE.md + .claude/ personalized
       Agents: {N} configured | Commands: {N} adapted
  ```

**[6b] Scaffold — Create project files**
- Validate: `package.json` (or equivalent) exists
- Update `state.md`: Scaffold → `done`
- Display:
  ```
  [6b] Scaffold       ✅ done
       Output: {stack} project scaffolded
       Deps: {N} packages installed | Build: {pass/fail}
  ```

**[6c] Observability — Configure deploy monitoring**
- Validate: `.learnings/observability.md` exists
- Update `state.md`: Observability → `done`
- Display:
  ```
  [6c] Observability  ✅ done
       Output: .learnings/observability.md
       Platform: {detected} | Sources: {N} enabled
  ```

**[6d] PRD Init — Initialize lifecycle tracking**
- Validate: `.prd/PRD-STATE.md` exists
- Update `state.md`: PRD Init → `done`
- Display:
  ```
  [6d] PRD Init       ✅ done
       Output: .prd/ initialized
       Roadmap: Phase 01 ready
  ```
