# legacy/ — v5 agents, not loaded

Claude Code discovers plugin agents in `agents/` only. Everything here is the v5 task-agent
roster that v6 folded into eighteen roles. It stays for one release so anyone who copied an
agent into `~/.claude/agents/` can diff it, then it is removed in 6.1.

Find the replacement for any old `subagent_type` in `docs/MIGRATION-v5-to-v6.md` or
`scripts/agent-map.tsv`. Nothing under this directory is scanned by `scripts/agent-graph.sh`,
`scripts/test-integrity.sh` or `scripts/smoke-test.sh`.
