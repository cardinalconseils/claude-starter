# Mode 2: App Exploratory Debug Workflow

You received a description of unexpected behavior (e.g., "the login flow isn't working", "this endpoint returns wrong data"). Follow these steps in order.

## Step 1: Clarify

Use `AskUserQuestion` to gather the three required inputs before proceeding:

1. **Expected behavior** — What SHOULD happen? (Be specific: what output, what state, what response)
2. **Actual behavior** — What IS happening? (What do they see instead?)
3. **Reproduction steps** — How do you trigger it? (Exact steps, inputs, or conditions)

Do not skip this step. Without expected vs. actual, you cannot identify the divergence.

## Step 2: Map the Code Path

Starting from the entry point (the route, handler, component, or function the user's action hits first):

1. Read the entry point file
2. Follow the function calls and imports from that file
3. Read each file in the chain
4. Note where data transforms happen — where a value is created, modified, or passed along

Build a mental map: input → transform 1 → transform 2 → output.

## Step 3: Find the Divergence

Walk the code path and compare what the code does against what the expected behavior describes.

The divergence point is where actual behavior first departs from expected. That is where the bug lives — or where it was introduced upstream of that point.

## Step 4: Trace the Root Cause

Same rule as Mode 1: the root cause is where bad data or bad state was **INTRODUCED**, not where the symptom is visible.

From the divergence point, trace upstream:
- Who set this value?
- Where was this state created?
- What condition caused the wrong branch to execute?

Keep tracing until you find the origin.

## Step 5: Collect Evidence

For each link in the causal chain, record:
- `file:line` — what it shows (the bad assignment, the missing check, the wrong condition)

Minimum 2 evidence points. Maximum: however many it takes to show the full chain from origin to symptom.

## Step 6: Rate Confidence

- **High** — clear chain from origin to symptom with file:line evidence at each step
- **Medium** — chain is probable but one link was inferred, not confirmed by reading code
- **Low** — hypothesis only; multiple links are unconfirmed

If confidence is Low or Medium, note in your output what additional information (logs, reproduction, instrumentation) would raise it.
