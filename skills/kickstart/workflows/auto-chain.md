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

3. Invoke `/cks:new` for the **first sub-project** in build order:
   ```
   Skill(skill="cks:new", args="{first sub-project brief}")
   ```

4. **VALIDATION GATE — MANDATORY:** After `/cks:new` returns, IMMEDIATELY verify:
   - `.prd/phases/{NN}-{name}/` directory exists
   - `PRD-STATE.md` has `active_phase` set to a phase number

   If EITHER check fails:
   ```
   Auto-chain validation failed:
     Expected: .prd/phases/{NN}-{name}/ to exist
     Found: {what actually exists}
     Action: Retrying /cks:new...
   ```
   Retry `/cks:new` once. If it fails again, stop and tell the user:
   "Run `/cks:new` manually to create your first feature."
   Do NOT proceed to step 5.

5. Update PRD-ROADMAP.md with ALL sub-projects from the manifest (not just the first):
   ```markdown
   | Phase | Sub-Project | Status | Depends On |
   |-------|-------------|--------|------------|
   | 01 | {first SP name} | Discovering | — |
   | 02 | {second SP name} | Pending | Phase 01 |
   | ... | ... | ... | ... |
   ```
   Only the first sub-project enters the lifecycle immediately. Others are queued.

6. Only after validation passes, invoke `/cks:next`:
   ```
   Skill(skill="cks:next")
   ```

7. `/cks:next` detects the state and invokes `/cks:discover` automatically.

8. Each subsequent phase ends with a **Context Reset** banner telling the user to
   run `/clear` then `/cks:next` to continue. This is intentional — it keeps context
   windows manageable across long lifecycles.

**The chain is:** kickstart → manifest copy → new (first SP, validated) → roadmap (all SPs) → next → discover → (context reset) → next → design → ...
