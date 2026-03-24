# Verification Patterns

Reference for the prd-verifier agent. Describes techniques for verifying different types of acceptance criteria.

## Verification Methods

### 1. Code Inspection

**When:** Checking that specific behavior is implemented.

```
1. Read the source file
2. Find the relevant function/component
3. Verify the logic matches the criterion
4. Check edge cases (null, empty, error states)
```

**Evidence format:** `{file}:{line} — {description of what the code does}`

### 2. Test Execution

**When:** Automated tests exist for the feature.

```bash
# Run full test suite
npm test

# Run specific test file
npm test -- --grep "feature name"

# Run with coverage
npm test -- --coverage
```

**Evidence format:** `Test suite: {X}/{Y} passing — {output snippet}`

### 3. Build Verification

**When:** Checking compilation and bundling.

```bash
# TypeScript compilation
npx tsc --noEmit

# Lint check
npm run lint

# Build
npm run build
```

**Evidence format:** `Build: {PASS|FAIL} — {output summary}`

### 4. Static Analysis

**When:** Checking code quality, types, patterns.

```
1. Check for TypeScript errors
2. Verify no unused imports/variables
3. Check for proper error handling
4. Verify consistent naming conventions
```

**Evidence format:** `{tool}: {result summary}`

### 5. Grep Verification

**When:** Checking that specific patterns exist or don't exist.

```
# Verify a function is called where expected
Grep: functionName in src/

# Verify no deprecated patterns remain
Grep: deprecatedPattern -- should return 0 results

# Verify exports are correct
Grep: "export.*ComponentName" in src/components/
```

**Evidence format:** `Grep '{pattern}': {N} matches in {files}`

### 6. Manual Verification Flag

**When:** Criterion requires visual inspection or user interaction.

```
Mark as: "Requires Manual Verification"
Describe: What to check, where to look, expected behavior
```

**Evidence format:** `Manual check needed: {description of what to verify}`

## Verdict Decision Tree

```
All criteria PASS → Verdict: PASS
Any criterion FAIL → Verdict: FAIL
All criteria PASS but quality issues → Verdict: PARTIAL
Only manual-check items remain → Verdict: PASS (with manual items noted)
```

## Common Pitfalls

1. **Don't trust "the code looks right"** — Run the actual verification
2. **Don't skip edge cases** — If the criterion says "handles errors gracefully", check error paths
3. **Don't conflate "works on my read" with "works"** — Run tests
4. **Don't mark uncertain items as PASS** — If unsure, flag for manual verification
5. **Don't fix issues you find** — Report them. Fixing is the executor's job.
