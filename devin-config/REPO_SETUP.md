# Devin Repo Configuration — CKS-Style Environment

## How to Use

When setting up Devin for a repo that uses the CKS-inspired workflow system, configure these settings in Devin's repo setup wizard.

---

## Git Pull
```
git pull origin main
```

## Configure Secrets
Set these secrets in Devin's secret management:
- `DATABASE_URL` — Database connection string
- `API_KEY` — External API keys (as needed)
- `STRIPE_SECRET_KEY` — If using Stripe
- `OPENAI_API_KEY` — If using AI features

Never commit secrets to the repo. Always use environment variables.

## Install Dependencies
```bash
# Node.js
npm install

# Python
pip install -r requirements.txt

# Or whatever the project uses
```

## Maintain Dependencies
```bash
# Same as install — runs after git pull
npm install
```

## Set Up Lint
```bash
# JavaScript/TypeScript
npm run lint

# Python
ruff check .
# or
flake8 .
```

## Set Up Tests
```bash
# JavaScript/TypeScript
npm test

# Python
pytest
```

## Run Local App
```bash
npm run dev
# or
python manage.py runserver
# or whatever starts the app
```

## Additional Notes

```
This repo uses a CKS-inspired 5-phase feature lifecycle.

WORKFLOW SYSTEM:
- Workflows are defined in .devin/workflows/
- Available workflows: /new-feature, /discover, /design, /sprint, /review, /release, /lifecycle, /status
- State is tracked in .phases/PRD-STATE.json
- Artifacts are stored in .phases/{feature_id}/

5-PHASE LIFECYCLE:
1. Discover: Gather 11 elements → CONTEXT.md
2. Design: UX flows, screens, components → DESIGN.md
3. Sprint: Plan → implement (TDD) → verify → merge → PLAN.md, SUMMARY.md, VERIFICATION.md
4. Review: Sprint review + retro + iteration decision → REVIEW.md
5. Release: Dev → Staging → RC → Production → RELEASE.md

RULES:
- Always read .phases/PRD-STATE.json before starting work
- Always update state after completing a step
- Never skip phases (discover before design, design before sprint)
- Always write tests before implementation (TDD)
- Prefer minimal changes over refactoring
- Fix root causes, not symptoms
- Never deploy to production without explicit confirmation
- Always have a rollback plan before deploying

PLAYBOOKS:
- See devin-playbooks/PLAYBOOKS.md for reusable prompts
- Use playbooks for common tasks (new feature, fix bug, code review, deploy)

KNOWLEDGE:
- See devin-knowledge/KNOWLEDGE_ITEMS.md for persistent context
- Add knowledge items to Devin's Knowledge system with appropriate triggers

FILE STRUCTURE:
.phases/
  PRD-STATE.json          — Current project state
  F-01/
    CONTEXT.md            — Discovery artifacts
    DESIGN.md             — Design artifacts
    PLAN.md               — Sprint plan
    SUMMARY.md            — Implementation summary
    VERIFICATION.md       — QA results
    REVIEW.md             — Review findings
    RELEASE.md            — Release summary
```
