# AI Vocabulary — Quick Reference for /kickstart

> Used during intake Q&A to explain concepts inline when they come up naturally.
> Surface definitions as `> **Term** — definition` when relevant to the conversation.

## Prompting Techniques

| Term | Definition |
|------|-----------|
| **Zero-shot** | No examples given — just ask the model directly |
| **One-shot** | One example given before the task |
| **Few-shot** | 3-10 examples given — most reliable for complex tasks |
| **Chain of Thought (CoT)** | Ask the model to reason step by step before answering |
| **ReAct** | Model alternates between Reasoning and Acting (calling tools) — core of AI agents |
| **System prompt** | Hidden instructions that set the model's behavior, tone, and rules before the conversation starts |
| **Prompt chaining** | Output of one prompt becomes input of the next |
| **Scaffolding** | Breaking a complex task into structured steps the AI follows sequentially |
| **Constrained prompting** | Force the model to answer in a specific format (JSON, table, yes/no) |
| **Prompt injection** | Malicious input that hijacks the AI's instructions — a security risk in agents |

## Model Behavior

| Term | Definition |
|------|-----------|
| **Hallucination** | AI confidently states false information as fact |
| **Grounding** | Anchoring AI responses to real, provided data so it can't make things up |
| **Temperature** | Controls randomness — low = predictable, high = creative/chaotic |
| **Token** | The smallest unit of text the AI processes (~3/4 of a word) |
| **Context window** | How much text the AI can "see" at once — its working memory |
| **Inference** | The act of the model generating a response (vs training) |

## Agent Concepts

| Term | Definition |
|------|-----------|
| **AI Agent** | An AI that doesn't just answer — it plans, decides, and takes actions autonomously |
| **Tool calling** | Agent can trigger external tools (APIs, search, code execution, databases) mid-reasoning |
| **ReAct loop** | Reason → Act → Observe → Reason again — the core loop of every AI agent |
| **Orchestration** | Managing multiple agents or steps — deciding who does what and when |
| **RAG** | Retrieval Augmented Generation — fetch real documents, inject them into the prompt so AI answers from facts not memory |
| **Vector database** | Stores text as math (embeddings) so AI can find semantically similar content fast |
| **Embedding** | Converting text into a list of numbers that captures its meaning — enables similarity search |
| **Short-term memory** | What's in the current context window — disappears after the conversation |
| **Long-term memory** | Stored externally (database, vector store) — persists across sessions |
| **Multi-agent system** | Multiple specialized AI agents working together |
| **Human-in-the-loop** | A checkpoint where a human must approve before the agent continues |
| **Tool schema** | The definition the agent reads to know what a tool does and how to call it |

## Training Concepts

| Term | Definition |
|------|-----------|
| **Pre-training** | Teaching the model on massive amounts of text — learns language, facts, patterns |
| **Fine-tuning** | Taking a pre-trained model and training it further on specific data |
| **RLHF** | Reinforcement Learning from Human Feedback — humans rate outputs, model learns what humans prefer |
| **Base model** | Raw pre-trained model — no instructions, no guardrails, just pattern completion |
| **Instruct model** | Base model + instruction tuning — actually follows your prompts |
| **Embedding model** | A model specifically trained to generate embeddings |
| **Transformer** | The neural network architecture behind all modern LLMs |

## Safety & Alignment

| Term | Definition |
|------|-----------|
| **Alignment** | Making AI behave according to human values and intentions |
| **Guardrails** | Rules/filters that prevent the model from producing harmful or dangerous outputs |
| **Prompt injection** | Malicious text in user input that hijacks the AI's instructions |
| **Red teaming** | Deliberately attacking your own AI system to find vulnerabilities |

## Architecture Patterns (for Design Phase)

| Term | When Relevant |
|------|--------------|
| **RAG** | User's idea involves AI answering questions from a knowledge base |
| **Vector database** | User needs semantic search, similarity matching, or recommendation |
| **Embedding** | User needs to compare, cluster, or search text/images by meaning |
| **Fine-tuning** | User wants AI behavior specific to their domain (vs prompting) |
| **Agent / ReAct** | User's idea involves AI taking autonomous actions |
| **Multi-agent** | User's idea has multiple specialized AI roles |
| **Grounding** | User needs AI that doesn't hallucinate — uses real data sources |
| **Human-in-the-loop** | User wants AI automation with approval checkpoints |

## When to Surface Definitions

Surface a definition when:
- User uses the term but might not fully understand it
- A design decision depends on understanding the concept
- The architecture involves the concept and explaining it helps the user make better choices
- The user explicitly asks "what is X?"

Do NOT surface definitions when:
- The user clearly understands the term already
- It would interrupt the flow of Q&A
- The term is common English (don't over-explain)

## Claude Code Power Commands

For thinking keywords, slash commands, keyboard shortcuts, and CLI flags — see
`skills/kickstart/references/claude-code-commands.md`.

Surface the thinking keyword guidance when the user is about to tackle architecture,
schema design, or complex debugging — recommend `ultrathink` for those cases.
