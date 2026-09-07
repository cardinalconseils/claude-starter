# Workflow: Feature Scope (Phase 3.5) — inventory every feature, cut to the MVP

Elicit every feature the user imagines, probe each one, tag it `mvp` / `v2` / `cut`, and
write three artifacts downstream phases build from without re-asking:

- `.prd/FEATURES.md` — full inventory, tagged
- `.prd/MVP-CUTLINE.md` — one-sentence MVP thesis + minimal feature set
- `.prd/OUT-OF-SCOPE.md` — rejected features with rationale

Every question is an `AskUserQuestion` call. Never accept the first answer: a feature that
cannot survive two "what exactly?" probes is not defined and gets tabled.

## 0. Read context

`.kickstart/context.md`, `.kickstart/state.md` (`maturity_stage` — calibrates the cut),
`.kickstart/research.md` (pain points, competitor features), `.monetize/context.md`
(monetizable capabilities).

Maturity calibration: Prototype → MVP max 3 features (the core validation loop only) ·
Pilot → 5–7 (usable by real users; auth counts if identity is needed) · Candidate → 8–15
(full workflow, error handling, monitoring hooks, accessibility basics) · Production → all
validated features, no artificial thinning.

## 1. Brainstorm

"List every feature you imagine — don't filter yet." Options: start with the core loop ·
tell me everything · walk me through a user session. Do not tag yet.

## 2. Grill each feature

For each named feature establish: what it does (user action + outcome), who does it
(end user / admin / system), failure mode, day-one necessity. Batch up to 4 probes per
call. Pattern: "For '{feature}': what exactly can the user do, step by step?" (specific
interpretation · simpler version · broader version) and "Required on day one to prove the
core idea?" (yes — broken without it · nice to have · v2 quality-of-life · not sure — help
me decide → apply the calibration).

## 3. Hidden features

Multi-select from context: authentication · error and empty states · onboarding ·
search/filter · export · notifications · admin/moderation · none. Probe newly selected
items as in step 2.

## 4. MVP cutline

Present the proposed cut for the maturity stage: Approve (Recommended) · move {feature}
v2 → MVP · move {feature} MVP → v2 · cut more aggressively. Push back on a cut that
violates the calibration ("At Prototype, 15 features means 15 things to build before you
know the idea is right — which 2–3 are essential?"). If the user insists, record it and
note it in MVP-CUTLINE.md.

## 5. Scope lock

For every `v2` / `cut` feature confirm the reason (multi): defer to v2 — nice-to-have
after core proven · cut — too complex for current maturity · cut — user research needed ·
cut — depends on features not yet built.

## 6. Write the artifacts

`.prd/FEATURES.md` — header (`Generated … {date}`, `Maturity stage`), then `## MVP
Features` / `## V2 Features` / `## Cut Features`; each entry: `**Tag:**`, `**Description:**`
(one sentence), `**User:**`, `**User Stories:**` (As a / I want / so that), `**Failure
Mode:**`, `**Day-One Necessity:**` (MVP) or `**Deferred Because:**` / `**Reason:**`.

`.prd/MVP-CUTLINE.md` — `**MVP Proves:**` one sentence · `**Maturity Stage:**` · `## Minimum
Feature Set` ordered as a user meets them, one-line rationale each · `## Why This Cut`
(2–3 sentences) · `## Success Signal` (one sentence: the behavior or metric that proves the
thesis).

`.prd/OUT-OF-SCOPE.md` — table `| Feature | Tag | Reason | Revisit When |` and a `## Scope
Freeze` paragraph: as of {date} the MVP set is locked to `mvp` entries; any addition needs
a new feature-scope session.

## 7. Confirm

"Feature scope complete. Proceed to Brand?" Options: Proceed (Recommended) · Adjust a
feature tag · Add a missing feature.

## State

Update `.kickstart/state.md` before reporting: `feature_scope_opted: true`,
`mvp_feature_count`, `v2_feature_count`, `cut_feature_count`, `last_phase: 3.5`,
`last_phase_name: Feature Scope`, `last_phase_status: done`.

Artifacts go to `.prd/`, not `.kickstart/` — they belong to the feature lifecycle.
