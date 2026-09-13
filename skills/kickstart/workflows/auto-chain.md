# Auto-Chain: Kickstart → Feature Lifecycle

**CRITICAL:** After displaying the final summary, automatically invoke the feature lifecycle.
Do NOT stop and wait for the user. The whole point of `/kickstart` is to go from idea to
implementation — stopping after scaffold defeats the purpose.

**Auto-chain sequence:**

1. Read `.kickstart/manifest.md` to get the list of sub-projects and build order.
   Copy the manifest to `.prd/PROJECT-MANIFEST.md`.

2. **Multi-sub-project mode:** For each sub-project in build order, create a feature entry.
   Extract the feature brief from the per-sub-project PRD (`.kickstart/artifacts/sp-{NN}-{name}/PRD.md`).
   If per-sub-project PRDs don't exist (single sub-project), fall back to `.kickstart/artifacts/PRD.md`.

3. **PRE-FLIGHT GATE — MANDATORY** (`.claude/rules/preflight.md`). Resolve `{NN}` = `01` and
   `{slug}` = kebab-case name of the first sub-project. Glob `.preflight/{NN}-*/PREFLIGHT.md` and
   read its `Cleared for takeoff` line, then `AskUserQuestion` (`header: "Phase 1 Gate"`):
   missing or `NO` → `Run pre-flight (Recommended)` / `Stop — I'll come back`; found with `YES` →
   `Skip — already done (Recommended)` / `Re-run pre-flight`. No "proceed without" option. On
   Run / Re-run:
   ```
   Agent(subagent_type="cks:architect", prompt="Mode: preflight — feature {slug}, phase {NN}. Read skills/agile-eagle/workflows/preflight.md; the brief is .kickstart/artifacts/sp-01-{slug}/PRD.md (or .kickstart/artifacts/PRD.md); write .preflight/{NN}-{slug}/PREFLIGHT.md; return the Cleared for takeoff verdict.")
   ```
   Re-read the verdict from disk. `NO` → `▶ ACTION REQUIRED` naming each BLOCK gotcha,
   `Then: fix it, then run /cks:preflight 01 and /cks:new`; stop the chain here. Stop → stop the
   chain here. Only a `YES` on disk continues to step 4.

4. Create the first feature entry and start discovery for the **first sub-project** in build order:
   ```
   Agent(subagent_type="cks:strategist", prompt="Mode: discover. Run Phase 1: Discovery for the first sub-project. Feature brief: {first sub-project brief}. Read .prd/PRD-STATE.md for context. PREFLIGHT.md at .preflight/{NN}-{slug}/PREFLIGHT.md — read §R and §F before asking about dependencies and risks. You MUST use AskUserQuestion interactively — do NOT run in autonomous mode.")
   ```

5. **VALIDATION GATE — MANDATORY:** After the strategist returns, IMMEDIATELY verify:
   - `.prd/phases/{NN}-{name}/` directory exists
   - `PRD-STATE.md` has `active_phase` set to a phase number

   If EITHER check fails:
   ```
   Auto-chain validation failed:
     Expected: .prd/phases/{NN}-{name}/ to exist
     Found: {what actually exists}
     Action: Retrying discovery...
   ```
   Retry the `Agent(subagent_type="cks:strategist", ...)` call once. If it fails again, stop and tell the user:
   "Run `/cks:new` manually to create your first feature."
   Do NOT proceed to step 6.

6. Update PRD-ROADMAP.md with ALL sub-projects from the manifest (not just the first):
   ```markdown
   | Phase | Sub-Project | Status | Depends On |
   |-------|-------------|--------|------------|
   | 01 | {first SP name} | Discovering | — |
   | 02 | {second SP name} | Pending | Phase 01 |
   | ... | ... | ... | ... |
   ```
   Only the first sub-project enters the lifecycle immediately. Others are queued.

7. Only after validation passes, advance to the design phase:
   ```
   Agent(subagent_type="cks:architect", prompt="Mode: design. Run Phase 2: Design for the active phase. Read .prd/PRD-STATE.md. Read the CONTEXT.md from Phase 1. MANDATORY: use AskUserQuestion at every interactive checkpoint.")
   ```

8. The designer detects the state and advances the lifecycle automatically.

9. Each subsequent phase ends with a **Context Reset** banner telling the user to
   run `/clear` then `/cks:next` to continue. This is intentional — it keeps context
   windows manageable across long lifecycles.

**The chain is:** kickstart → manifest copy → architect pre-flight (gated, verdict YES) → strategist discovery (first SP, validated) → roadmap (all SPs) → architect design → discover → (context reset) → design → ...
