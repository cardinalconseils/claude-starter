---
name: ai-agent-projects
description: >
  AI agent project scaffolding templates for vibe coders. Knows how to scaffold
  voice agents (Telnyx + ElevenLabs), chat agents (OpenRouter + Supabase),
  multi-agent systems, RAG pipelines, and MCP servers. Use when /cks:kickstart
  detects an AI agent project type, or when user says "I want to build an AI agent."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: sonnet
---

# AI Agent Projects for Vibe Coders

Scaffold AI agent projects from idea to deployable product. These are opinionated
templates matching the CKS stack defaults: Next.js + Supabase + OpenRouter +
n8n + Vercel + Railway.

## Agent Project Types CKS Can Scaffold

| Type | Description | Default Stack |
|------|-------------|---------------|
| **voice-agent** | Phone-based AI voice agent (inbound/outbound) | Telnyx + ElevenLabs + Deepgram + Supabase |
| **chat-agent** | Web chat bot with memory and tools | Next.js + Supabase + OpenRouter |
| **multi-agent** | Multiple AI agents coordinating on tasks | Supabase + n8n + OpenRouter |
| **rag-pipeline** | Retrieval-augmented generation over documents | Supabase/pgvector + OpenRouter + Next.js |
| **mcp-server** | Model Context Protocol server (extends AI tools) | TypeScript + Fastify or Express |
| **n8n-workflow** | n8n-hosted agent with MCP tools | n8n + OpenRouter |

## Pattern: Voice Agent Stack

### Architecture
```
Inbound call
  ↓
Telnyx number → SIP trunk
  ↓
ElevenLabs Conversational AI (agent_7901ksp5mtc1fpkvqmeedwqmde50)
  — STT: Deepgram (via ElevenLabs)
  — LLM: OpenRouter (claude/gemini)
  — TTS: ElevenLabs (voice EkK5I93UQWFDigLMpZcX)
  ↓
n8n webhook → Supabase CRM / Brain MCP
```

### What to Scaffold

```
voice-agent/
├── .voice/
│   ├── config.json          ← Telnyx number, agent ID, ElevenLabs config
│   ├── system-prompt.txt    ← AI agent behavior prompt
│   └── knowledge-base/      ← KB documents for ElevenLabs
│       ├── faq.md
│       └── procedures.md
├── n8n/
│   └── crm-integration.json ← Webhook workflow templates
├── supabase/
│   ├── schema.sql           ← Calls, transcripts, contacts tables
│   └── rls-policies.sql     ← Row-level security
├── AGENTS.md                ← Hermes standing orders
├── CLAUDE.md                ← Claude Code standing orders
└── README.md
```

### KB Content Rule
AI agent knowledge bases MUST use actual site content (blog/guides/copy),
never manual summaries. Point to source URLs, not generated text.

### System Prompt Template (Voice)
```
You are a {agent-name}, a voice AI assistant for {company/project}.
Rules:
- Speak in complete sentences. Never use markdown.
- Maximum {N} sentences per response.
- Confirm before any destructive action.
- If unsure, ask ONE clarifying question.
- Your knowledge is in the KB. Don't hallucinate.
- End every successful interaction by logging to CRM.
```

## Pattern: Chat Agent Stack

### Architecture
```
User message
  ↓
Next.js chat UI (/chat)
  ↓
Supabase (auth, session history, message storage)
  ↓
OpenRouter (model routing per task type)
  ↓
Tool calls (n8n webhooks, Supabase queries, MCP servers)
  ↓
Streaming response back to UI
```

### What to Scaffold

```
chat-agent/
├── src/
│   ├── app/
│   │   ├── page.tsx           ← Landing + chat trigger
│   │   ├── chat/
│   │   │   ├── page.tsx       ← Chat UI
│   │   │   └── api/
│   │   │       └── route.ts   ← Streaming chat endpoint
│   │   └── layout.tsx
│   ├── components/
│   │   ├── ChatMessage.tsx
│   │   ├── ChatInput.tsx
│   │   └── ToolCallCard.tsx
│   ├── lib/
│   │   ├── llm.ts             ← OpenRouter client
│   │   ├── tools.ts           ← Tool definitions
│   │   └── supabase.ts        ← DB client
│   └── types/
│       └── chat.ts
├── supabase/
│   ├── schema.sql
│   └── rls-policies.sql
├── AGENTS.md
├── CLAUDE.md
└── README.md
```

## Pattern: Multi-Agent Stack

### Architecture
```
User request
  ↓
Orchestrator agent (classifies intent)
  ↓
Specialist agents (parallel or sequential):
  ├── Researcher agent → web search + synthesize
  ├── Writer agent → generate content
  ├── Reviewer agent → validate quality
  └── Summary agent → combine results
  ↓
n8n (orchestration + tool execution)
  ↓
Response to user
```

### What to Scaffold

```
multi-agent/
├── src/
│   ├── orchestrator.ts       ← Intent classifier + agent router
│   ├── agents/
│   │   ├── researcher.ts     ← Web search + fact synthesis
│   │   ├── writer.ts         ← Content generation
│   │   ├── reviewer.ts       ← Quality validation
│   │   └── summarizer.ts     ← Result combination
│   ├── tool-registry.ts      ← Available tools per agent
│   └── types.ts
├── supabase/
│   ├── schema.sql            ← Agent state, logs, results
│   └── rls-policies.sql
├── AGENTS.md
├── CLAUDE.md
└── README.md
```

## Pattern: RAG Pipeline

### Stack Selection
- **Vector DB:** Supabase/pgvector (free, auth integrated)
- **Embeddings:** OpenAI text-embedding-3-small via OpenRouter
- **Chunking:** LangChain or custom recursive splitter
- **Retrieval:** Hybrid (vector + keyword via pgvector + tsvector)
- **Generation:** Claude Sonnet or Gemini via OpenRouter

### What to Scaffold

```
rag-pipeline/
├── src/
│   ├── ingest/
│   │   ├── loader.ts          ← Document loader (PDF, MD, TXT, URL)
│   │   ├── chunker.ts         ← Recursive text splitter
│   │   └── embedder.ts        ← Vector embedding + upsert
│   ├── retrieve/
│   │   ├── vector-search.ts   ← pgvector similarity search
│   │   └── hybrid-search.ts   ← Vector + keyword fusion
│   ├── generate/
│   │   ├── query-rewriter.ts  ← Rewrite user query for retrieval
│   │   └── answer.ts          ← LLM answer with context
│   └── app/
│       └── route.ts           ← Search + answer API endpoint
├── supabase/
│   └── migrations/
│       └── 001_pgvector.sql   ← Enable pgvector + index
├── AGENTS.md
├── CLAUDE.md
└── README.md
```

## Pattern: MCP Server (Model Context Protocol)

### Architecture
```
AI agent (Claude Code / Hermes)
  ↓
MCP Client (stdio or HTTP transport)
  ↓
MCP Server (this project)
  ↓
Tools you define (file ops, API calls, DB queries)
  ↓
External services
```

### What to Scaffold

```
mcp-server/
├── src/
│   ├── index.ts              ← Server entry + transport setup
│   ├── tools/
│   │   ├── tool-definitions.ts ← Tool schema + handler map
│   │   ├── search-tool.ts     ← Example: web search
│   │   └── db-tool.ts         ← Example: Supabase query
│   ├── handlers/
│   │   └── resource-handler.ts ← Resource handler (optional)
│   └── types.ts
├── package.json               ← @modelcontextprotocol/sdk
├── tsconfig.json
├── AGENTS.md
├── CLAUDE.md
└── README.md
```

## How to Use in Kickstart

When the user types `/cks:kickstart "voice agent for restaurant booking"`:

1. Detect project type from the description (voice-agent keywords → template)
2. Check `.kickstart/context.md` for confirming signals
3. Auto-select the matching template stack (overrideable via AskUserQuestion)
4. After brand/design phases, scaffold from the template in Handoff phase
5. Generate both AGENTS.md (Hermes) and CLAUDE.md (Claude Code)

## Stack Selection Overrides for AI Projects

The `stack-selection` workflow should add these options when AI agent project
is detected:

| Category | Override Options |
|----------|-----------------|
| AI Gateway | OpenRouter (default), Direct Anthropic, Direct OpenAI |
| Voice Platform | Telnyx (default), Twilio, Just WebRTC (no phone) |
| TTS | ElevenLabs (default), OpenAI TTS, Edge TTS |
| STT | Deepgram (default), Whisper, OpenAI STT |
| Orchestration | n8n (default), Temporal, Direct code |
| KB Storage | Supabase (default), Pinecone, Weaviate, files |

## Verification

- [ ] Scaffolded project type matches user's description
- [ ] Stack matches CKS defaults or user overrides
- [ ] AGENTS.md generated for Hermes compatibility
- [ ] CLAUDE.md generated for Claude Code compatibility
- [ ] Environment variable placeholders in .env.example
- [ ] Supabase schema has RLS policies on every table
- [ ] OpenRouter routing config for each task type