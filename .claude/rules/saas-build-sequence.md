# SaaS Build Sequence Rules

## Mandatory Behavior

When `project_type: multi-role-saas` is set in `.kickstart/state.md` or
`.bootstrap/scan-context.md`, OR any feature description, CONTEXT.md, PLAN.md, or pitch text
matches a trigger pattern below, the orchestrating agent MUST offer the 12-stage
`skills/saas-dashboard-sequence/` methodology via `AskUserQuestion` (Run/Skip) before
proceeding past kickstart Phase 1b (Compose) or the bootstrap Guided Intake gate. This is not a
suggestion — it fires deterministically on match.

The offer is non-blocking — per the confirmed decision, `project_type` never blocks
progression. The user may skip and continue with standard kickstart/bootstrap flow. The act of
asking is mandatory; the answer is the user's judgment call.

## Trigger Patterns

Match is case-insensitive. Any single match is sufficient to trigger.

**Multi-role SaaS language**
- `multi-role`, `admin/user/vendor`, `role-based dashboard`, `super admin`
- `tenant roles`, `permission matrix`, `multi-tenant roles`

**Project-type tag**
- `project_type: multi-role-saas` present in `.kickstart/state.md` frontmatter
- `project_type: multi-role-saas` present in `.bootstrap/scan-context.md`

## Required Behavior by Lifecycle Gate

### Kickstart Gate — Phase 1b (Compose)

**When:** `kickstart-intake` agent has completed Phase 1 (Intake) and is about to run Phase 1b
(Compose), AND a trigger pattern matched during intake or `project_type: multi-role-saas` was
recorded.

**What MUST happen:**
1. Before running Phase 1b compose steps, call `AskUserQuestion`:

```
question: "This looks like a multi-role SaaS build (admin/user/vendor style roles). Run the
  12-stage Unified Dashboard SaaS Build Sequence to design one role-gated app instead of
  separate dashboards per role?"
header: "SaaS Build Sequence"
options:
  - label: "Run the 12-stage sequence (Recommended)"
    description: "Reads skills/saas-dashboard-sequence/ — produces a permissions matrix
      before any architecture or deployment-target decision is locked in"
  - label: "Skip — proceed with standard kickstart"
    description: "Continue Phase 1b normally, no role-gating enforcement"
```

2. If "Run": read `skills/saas-dashboard-sequence/SKILL.md` and
   `skills/saas-dashboard-sequence/workflows/build-sequence.md`, and start at Stage 1
   (Product Definition & Monetization — the permissions matrix). This directly feeds
   `workflows/compose.md` Step 3's deployment-target question (see
   `.claude/rules/saas-single-app.md` and the Step 3 edit it requires).
3. If "Skip": proceed with Phase 1b as normal. Record the skip — do not re-prompt for the
   same project within the same kickstart session.

### Bootstrap Gate — Guided Intake

**When:** `bootstrap-scanner` has completed its stack scan (Step 1) and Step 1b project-type
classification, AND `project_type: multi-role-saas` was recorded or a trigger pattern matched
during the scan.

**What MUST happen:**
1. Before proceeding to Guided Intake (Step 3), call `AskUserQuestion` with the same Run/Skip
   offer as above, scoped to the existing codebase being bootstrapped.
2. If "Run": read `skills/saas-dashboard-sequence/SKILL.md` — for an existing codebase, this
   typically means confirming whether a permissions matrix already exists (informally, in
   code) and formalizing it into `PERMISSIONS-MATRIX.md` before continuing.
3. If "Skip": proceed with standard Guided Intake.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The roles might not really need separate gating" | Trigger matched = offer it. The user can say Skip in one click — offering costs nothing. |
| "I'll mention the methodology as a suggestion in prose" | The rule mandates an `AskUserQuestion` offer, not a prose suggestion. Ask directly. |
| "It's early, the permissions matrix can come later" | Later means the deployment-target question in compose.md gets answered before the matrix exists — the exact ordering this rule prevents. |
| "The user didn't explicitly ask for a 12-stage methodology" | Multi-role signals in descriptions are implicit requirements. Surface the offer — the user decides. |
| "project_type isn't set yet so this doesn't apply" | Keyword match alone is sufficient — the tag and the keyword trigger are independent, either fires the offer. |
