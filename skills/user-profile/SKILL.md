---
name: user-profile
description: >
  Human user profile — loads the CKS operator's personal preferences, communication style,
  and domain context from ~/.cks/user-profile.md. Use when personalizing responses to the
  operator: tone, technical depth, what to optimize for, what to avoid.
  Trigger on: session start, discovery, review, any agent that adapts its output style.
allowed-tools: Read, Bash
---

# User Profile System

## Session Start Instructions

When you load this skill, execute the following steps before doing any other work.

### Step 1 — Load profile

Run `cat ~/.cks/user-profile.md` via Bash (or use Read on the expanded path).

If the file is missing or unreadable: proceed normally. Do not block. Note:
"No user profile — operator can run /cks:me to set one up."

### Step 2 — Extract and hold active

From the file, extract and hold active:

- **name** — how to address the user
- **role** — their function (Founder, Developer, Designer, etc.)
- **technical_level** — code comfort (writes code / reads code / avoids code)
- **communication_style** — Terse, Normal prose, or Detailed with context
- **domain** — their project/industry context
- **optimize_for** — ranked priorities (Speed, Quality, UX, Cost, Security)
- **pet_peeves** — behaviors to avoid
- **notes** — freeform context about this user

### Step 3 — Apply throughout session

- Address the user by **name** if provided
- Match **communication_style**:
  - Terse → caveman default stays active (do not override)
  - Normal prose → use standard prose, no caveman compression
  - Detailed with context → full explanations, include rationale
- Avoid every item listed in **pet_peeves**
- Bias decisions and recommendations toward **optimize_for** priorities
- Use **domain** context when making technology or design suggestions
- Apply **notes** as background context — it may explain unusual preferences

### Step 4 — Caveman interaction rule

Override caveman behavior ONLY if `communication_style` is NOT terse.

- Terse → caveman stays on (default)
- Normal prose → disable caveman compression for this session
- Detailed with context → disable caveman compression, add more explanation

Auto-clarity overrides (destructive ops, action required, security findings) always apply regardless of communication_style.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The profile file might be wrong, I'll use defaults" | Load what's there. Wrong profile = user updates it with /cks:me. |
| "Communication style is just a preference, I'll use my default" | It's an explicit instruction. Honor it. |
| "I don't need to check the file every session" | This skill fires at session start — that IS every session. |
| "Skipping name addressing is fine" | If name is set, use it. It's a 1-token change with disproportionate effect. |

## Verification

- [ ] Profile file checked at skill load time
- [ ] name, role, technical_level, communication_style, domain, optimize_for, pet_peeves, notes all extracted
- [ ] communication_style applied to caveman toggle
- [ ] pet_peeves actively avoided throughout session
- [ ] Missing file handled gracefully without blocking
