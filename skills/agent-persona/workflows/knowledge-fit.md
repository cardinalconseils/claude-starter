# Knowledge Fit — Retrieval Strategy Decision Tree

Use when selecting a retrieval tag for a knowledge source in `knowledge-index.md`.
Answer the questions in order; the first match wins.

## Decision Tree

### Q1: Is the corpus small and stable?

Is the source under ~50 pages (or ~50,000 words) and updated less than once a month?

- **Yes** → tag: `static`
  The agent will Read the file at session start. No infrastructure needed.
  Cost: a few thousand tokens per session.

- **No** → continue to Q2.

### Q2: Is the corpus large, dynamic, or too big to inject?

Is the source frequently updated, too large for context, or stored in an external
system that requires search to be useful?

- **Yes** → tag: `rag`
  The agent queries a vector store at request time.

  **Setup guidance (prose only — CKS does not scaffold infra):**
  1. Choose a vector store: Chroma (local), Pinecone, Supabase pgvector, or similar
  2. Index your corpus using an embedding model (e.g., OpenAI text-embedding-3-small,
     HuggingFace sentence-transformers)
  3. Set `location` in `knowledge-index.md` to the query endpoint
  4. If you want automated retrieval, add a RAG query tool to the agent's `tools:` list
  5. If no RAG tool is available, the agent outputs a prompt for the user to paste results

- **No** → continue to Q3.

### Q3: Is behavioral consistency more important than knowledge breadth?

Do you need the agent to consistently adopt a communication style that goes beyond
what a system prompt reliably achieves? Is this critical enough for model training?

- **Yes** → tag: `fine-tune`
  A fine-tuned model endpoint is registered in the index.

  **Setup guidance (prose only — CKS does not execute training):**
  1. Prepare (prompt, ideal response) pairs for the desired behavior — min ~100, ideally 500+
  2. Fine-tune using: HuggingFace (open models), OpenAI fine-tuning API, or Anthropic's
     fine-tuning offering (check your plan tier)
  3. Set `location` in `knowledge-index.md` to the resulting model endpoint
  4. If an inference tool is in the agent's `tools:` list, it will use the endpoint

- **No** → tag: `static` (reduced capability)
  Corpus may be too large for ideal injection but no vector store is available yet.
  Add a `notes` entry: "TODO: migrate to rag when vector store is set up."

## Summary Table

| Condition | Tag | Infrastructure needed |
|-----------|-----|----------------------|
| Small corpus, rarely changes | `static` | None |
| Large or dynamic corpus | `rag` | Vector store + embedding pipeline |
| Behavior consistency critical | `fine-tune` | Training data + training job |
| No infra available | `static` | None (reduced capability) |
