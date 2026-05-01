---
# Knowledge Index — What This Agent Knows
# Populated by /cks:persona. Each source has a retrieval strategy tag.
#
# Tag meanings (agent behavior when SKILL.md is loaded):
#   static     — agent uses Read tool to inject this source at session start
#   rag        — if RAG tool in agent's tools: list, query it; otherwise output:
#                [RAG source: <name> — query <location> directly and paste results here]
#   fine-tune  — if inference tool available, use endpoint; otherwise note for developer
#
# If a source is unavailable or unreadable, agent skips it and continues.
---

## sources

# Uncomment and fill in entries after running /cks:persona.
#
# - source: <name>
#   tag: static | rag | fine-tune
#   location: <file path, URL, or API endpoint>
#   notes: <optional>
#
# Example:
# - source: Product FAQ
#   tag: static
#   location: docs/faq.md
#   notes: Updated quarterly
#
# - source: Customer Database
#   tag: rag
#   location: https://my-vector-store/query
#
# - source: Support Tone Model
#   tag: fine-tune
#   location: https://api.openai.com/v1/models/ft:gpt-4:company:v1
