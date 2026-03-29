# Sub-step [3b+]: Secrets Gate

<context>
Phase: Sprint (Phase 3)
Requires: TDD created ([3b])
Produces: Secrets verification before implementation
</context>

## Instructions

Before implementation, ensure all required secrets are resolved or explicitly deferred:

```
Read ${SKILL_ROOT}/workflows/secrets/hook-sprint.md
Execute its instructions.
```

This re-checks `.env.local` for newly added secrets, then presents a blocking `AskUserQuestion` for any remaining pending secrets with "go fetch" instructions. The user can also skip with mock values (deferred to release).
