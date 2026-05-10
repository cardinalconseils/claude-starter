# Mode 4: Issue-Driven Debug Workflow

You received a GitHub issue number and the full issue body (filed by the investigator agent). Follow these steps in order.

## Step 1: Parse the Issue

Extract from the issue body:
- **Summary** — one-sentence description of what is broken
- **Evidence** — file paths and line numbers cited (e.g., `src/auth/login.ts:42`)
- **Failure classification** — the type and severity already assigned
- **Suggested fix direction** — any hints about what to change

## Step 2: Reproduce Locally

Use the evidence to locate the problem in the codebase:
- Read every file:line cited in the issue
- Confirm the problem exists at those locations
- If reproduction steps are provided, trace the code path they describe

## Step 3: Validate the Classification

The issue already has a failure type and severity. Confirm or correct it based on what you find in the code.

If you disagree with the classification, note it in your output with your reasoning.

## Step 4: Trace the Root Cause

Same rule as all modes: the root cause is where bad data or bad state was **INTRODUCED**, not where the symptom is visible.

From the evidence, trace upstream until you find the origin. Collect file:line evidence at each link in the chain.

## Step 5: Propose Fix

Before applying anything:
1. Describe the exact change — which file, what line, what the change is
2. Show the diff (before / after) if the change is non-trivial
3. Ask for confirmation using `AskUserQuestion`: "I found the root cause and have a fix ready. Shall I apply it?"

Do NOT apply the fix without confirmation.

---

## Fix and Close Flow (after user confirms)

### Step 6: Apply the Fix

Use `Edit` to apply exactly the change you described. Do not expand scope.

### Step 7: Run Verification

Re-run the relevant verification from the issue body:
- If the issue includes a build command, run it
- If the issue includes a test command, run it
- If the issue includes manual reproduction steps, trace the code path again to confirm the fix is in place

### Step 8: Close or Escalate

**If verification passes:**

Close the issue via `mcp__plugin_github_github__issue_write` with:
- `state: "closed"`
- A comment in this format:
  ```
  Fixed in {commit-sha or branch}. Root cause: {one sentence}. Verification: {what passed}.
  ```

**If verification fails:**

- Do NOT close the issue
- Report: "Fix applied but verification failed — issue remains open"
- Describe exactly what still needs to happen before the issue can be closed

**If GitHub MCP is unavailable:**

- Apply the fix
- Skip closing the issue
- Remind the user: "GitHub MCP was unavailable — please close issue #{N} manually once you verify the fix."
