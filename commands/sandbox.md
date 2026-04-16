---
description: "Generate a Leash Cedar policy for this project — sandbox Claude Code with minimal-privilege file, process, and network rules"
allowed-tools:
  - Agent
---

# /cks:sandbox — Sandbox Policy Generator

Dispatch the **sandbox-agent** to analyze the project and generate `.leash/policy.cedar`.

## Dispatch

```
Agent(subagent_type="sandbox-agent", prompt="Analyze this project and generate a Leash Cedar policy file. Project root: {cwd}. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:sandbox          → Generate .leash/policy.cedar for this project
```

The sandbox-agent handles: stack detection, .env file discovery, external host enumeration, Cedar policy generation, and Leash activation instructions.
