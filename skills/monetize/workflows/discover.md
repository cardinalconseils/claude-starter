# Workflow: Discover

## Overview
Gathers context about the product/business to feed the evaluation framework.
Behavior adapts based on input mode (A: self-analyze, B: target project, C: description).

## Input
- `$MODE` — A, B, or C (determined by SKILL.md)
- `$TARGET_PATH` — project path for Mode B (optional)
- `$DESCRIPTION` — business description for Mode C (optional)

## Steps

### Step 1: Check for Existing Context

Read `.monetize/context.md` if it exists.

- If complete context exists → ask: "Discovery already done. Re-do or skip to research?"
- If partial context exists → resume from where it left off
- If no context → fresh discovery

### Step 2: Codebase Scan (Modes A & B only)

For Mode A, scan the current project. For Mode B, scan `$TARGET_PATH`.

**Read these files (if they exist) and extract signals:**

| File | What to Extract |
|------|----------------|
| `package.json` / `requirements.txt` / `Cargo.toml` / `go.mod` | Tech stack, dependencies, project name |
| `README.md` | Product description, features, target audience |
| `CLAUDE.md` | Project context, workflows, architecture |
| `LICENSE` | Current licensing model |
| `src/**/*.{ts,tsx,py,go,rs}` (scan structure) | Feature set, architecture pattern |
| `docker-compose.yml` / `Dockerfile` | Deployment model |
| `vercel.json` / `railway.json` / `netlify.toml` | Hosting platform |
| `.env.example` | External service dependencies |
| `stripe*` / `billing*` / `subscription*` in filenames | Existing monetization signals |
| Auth-related files (roles, permissions, tiers) | User segmentation capability |

**Summarize findings as:**
```
## Codebase Scan Results
- **Product:** {inferred name and description}
- **Tech Stack:** {languages, frameworks, key dependencies}
- **Architecture:** {monolith | microservices | serverless | static + API}
- **Features:** {list of major features found}
- **Deployment:** {platform and model}
- **Monetization Signals:** {existing billing, tiers, auth roles — or "none found"}
- **License:** {current license or "none"}
```

Present scan results to the user: "Here's what I found. Let me ask a few questions to fill in the gaps."

### Step 3: Interactive Questions

Ask questions **one at a time** using AskUserQuestion. Adapt based on mode:

**For Modes A & B (after scan — ~8 questions):**

1. "Who is your target customer? (e.g., SMB teams, enterprise IT, solo developers, agencies)"
2. "What stage are you at? (pre-revenue / early revenue / growth / mature)"
3. "What's your team size and budget for monetization work? (solo / 2-5 / 5-10 / 10+)"
4. "What makes your product different from competitors? (1-2 sentences)"
5. "What's your priority? (a) Revenue speed — make money ASAP, (b) Market share — grow users first, monetize later, (c) Community — build ecosystem, revenue is secondary"
6. "How do you acquire customers today, and what does it cost? (organic/SEO / paid ads with rough CAC / referral / partnerships / outbound sales / N/A — be specific if you know your numbers)"
7. "What's the maximum your target customer would realistically pay monthly/annually for this? (Even a rough range helps — e.g., '$20-$50/mo' or 'enterprise: $10K+/yr')"
8. "Are there legal, regulatory, or compliance constraints? (e.g., HIPAA, SOC2, GDPR, PCI-DSS, financial regulations, data residency, export controls, IP/licensing obligations) — list all that apply, even if uncertain"

**For Mode C (no scan — ~12 questions):**

Questions 1-8 above, plus:
9. "Describe what your product does in 2-3 sentences."
10. "What's the core technology or IP? (e.g., proprietary algorithm, unique data set, novel UX)"
11. "Do you have existing users? How many? (none / <100 / 100-1K / 1K-10K / 10K+)"
12. "How do users find your product today? (organic / referral / paid ads / partnerships / N/A)"

### Step 4: Save Context

Create `.monetize/` directory if it doesn't exist:
```bash
mkdir -p .monetize
```

Write structured context to `.monetize/context.md`:

```markdown
# Monetization Discovery Context

**Generated:** {date}
**Mode:** {A|B|C}
**Project:** {name}

## Product Overview
{Product description — from scan and/or user input}

## Tech Stack
{Languages, frameworks, key dependencies}

## Architecture
{Architecture pattern}

## Features
{List of major features}

## Deployment
{Platform and model}

## Existing Monetization Signals
{Any billing, tiers, or auth roles found — or "none"}

## License
{Current license}

## Target Market
- **ICP:** {from Q1}
- **Stage:** {from Q2}
- **Team Size:** {from Q3}
- **Differentiation:** {from Q4}
- **Growth Priority:** {from Q5}

## Distribution & Unit Economics
- **Acquisition Channels:** {from Q6 — channels and known CAC}
- **Willingness to Pay:** {from Q7 — customer price ceiling}

## Legal, Regulatory & Compliance
- **Applicable Regulations:** {from Q8 — HIPAA, SOC2, GDPR, PCI-DSS, etc.}
- **Data Sensitivity:** {inferred from scan + Q8 — what kind of data does the product handle?}
- **Compliance Maturity:** {does the product currently meet these requirements, or is compliance work needed?}
- **Licensing Constraints:** {any open-source license obligations, patent considerations, or IP restrictions}
- **Monetization Blockers:** {regulations that rule out specific models — e.g., "HIPAA requires BAAs for API customers", "GDPR limits data-based monetization", "financial regulations require audit trails for usage billing"}

> **Why this matters for scoring:** Compliance constraints are hard filters. A model that requires sharing user data (white-label, marketplace) may be legally impossible. A model requiring per-customer contracts (enterprise licensing) may be necessary, not optional. These constraints eliminate or mandate models before any scoring begins.

## Additional Context (Mode C only)
- **Core Technology:** {from Q10}
- **User Base:** {from Q11}
- **Distribution:** {from Q12}
```

Display: "Discovery complete. Context saved to `.monetize/context.md`. Moving to research phase."
