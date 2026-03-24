---
description: Project health overview at session start
allowed-tools: Bash, Read, Glob, Grep
---

Show project health overview. Run at the start of each session.

1. **Git Status** — Current branch, uncommitted changes, recent commits
2. **Build Health** — Can the project build? (run the project's build/check script)
3. **Dependencies** — Any outdated or vulnerable packages?
4. **GSD Progress** — Check `.prd/` for current milestone/phase status
5. **Open Issues** — Check for TODO/FIXME/HACK comments in source

Output a concise dashboard:

```
Project: [PROJECT_NAME]
Branch:  [branch] | [clean/dirty]
Build:   [passing/failing]
Phase:   [current GSD phase or "not initialized"]
Issues:  [count] TODOs, [count] FIXMEs
```
