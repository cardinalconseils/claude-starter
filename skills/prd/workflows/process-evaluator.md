# Workflow: Process Evaluator

## Overview
The Process Evaluator is a feature of ProcessFlow AI that takes raw text (pasted or uploaded) and produces a **complete process card** with all components:

- Executive Summary
- KPIs (SMART, measurable)
- Industry Benchmarks
- Standard Operating Procedure (SOP)
- Flow Chart (BPMN nodes/edges)
- Technical Stack
- Bottleneck Analysis
- Improvement Recommendations

When the input text is incomplete, the system asks the user clarifying questions via the ChatBot before generating the full card.

## Architecture

```
User Input (text/document)
    │
    ├── Completeness Check ──→ Missing info? ──→ Ask questions via ChatBot
    │                                              │
    │                          ◄───── User answers ┘
    │
    ├── Parse & Extract
    │   ├── Identify process steps, roles, decisions
    │   ├── Detect tools/systems mentioned
    │   └── Map to BPMN node types (task/gateway/event)
    │
    ├── Generate Process Card
    │   ├── Executive Summary ──→ process.description (enriched)
    │   ├── Flow Chart ─────────→ process.content (nodes/edges JSON)
    │   ├── KPIs ───────────────→ process.kpis[]
    │   ├── Tech Stack ─────────→ process.techStack[]
    │   ├── SOP ────────────────→ AI-generated markdown (stored in notes or separate)
    │   ├── Benchmark ──────────→ AI-generated markdown
    │   └── Bottleneck Analysis → AI-generated markdown
    │
    └── Save to Firestore ──→ processes collection
```

## Completeness Detection

Before generating the full card, the evaluator checks the input text for:

### Required Information (must have or ask)
1. **Process name/title** — What is this process called?
2. **Process steps** — What are the sequential actions? (minimum 3)
3. **Roles/departments** — Who performs each step?
4. **Decision points** — Where does the flow branch?
5. **Start/end conditions** — When does this process begin and end?

### Enrichment Information (nice to have, infer or ask)
6. **Tools/systems used** — What software supports each step?
7. **Success criteria** — How do you measure good outcomes?
8. **Pain points** — Where are current bottlenecks?
9. **Compliance requirements** — Any regulations or standards?
10. **Volume/frequency** — How often does this run? How many per day/week?

### Completeness Score
```
Score = (required items found / 5) * 60 + (enrichment items found / 5) * 40

≥ 80% → Generate full card immediately
60-79% → Generate with assumptions, flag gaps
< 60% → Ask clarifying questions first
```

## Clarifying Questions (Frontend ChatBot Integration)

When the input is incomplete, the evaluator generates targeted questions:

```typescript
interface ClarificationRequest {
  processId: string;          // Temporary ID for the in-progress evaluation
  questions: {
    id: string;
    question: string;         // The question text
    category: 'required' | 'enrichment';
    context: string;          // Why we're asking (what the AI noticed)
    suggestedAnswer?: string; // AI's best guess if it can infer
    options?: string[];       // Multiple choice options if applicable
  }[];
  partialCard: Partial<ProcessCard>; // What we can generate so far
}
```

The ChatBot component should:
1. Display the questions in a conversational format
2. Accept answers (text, selection, or "skip")
3. Send answers back to the evaluator
4. Re-run generation with the enriched context

## Process Card Generation

### Executive Summary
Generated from the input text + clarifying answers. Should be 2-4 sentences covering:
- What the process does
- Who it serves
- What the business outcome is
- Key metrics

### KPIs
Generate 5-8 SMART KPIs based on:
- Process type (operational, customer-facing, compliance, etc.)
- Industry benchmarks for similar processes
- Mentioned metrics or targets in the input
- Volume/frequency data

Format: `"Metric description: Target value (measurement method)"`

### Benchmarks
Compare the process against industry standards:
- Cycle time vs industry average
- Error rates vs Six Sigma levels
- Automation level vs peers
- Cost per transaction benchmarks

### SOP
Full standard operating procedure:
- Purpose and scope
- Roles and responsibilities (from swimlane assignments)
- Step-by-step procedure (from process nodes)
- Exception handling (from gateway decisions)
- Quality checks
- Revision history template

### Flow Chart
BPMN nodes and edges following the existing `ContentNode` / `ContentEdge` format:
- task nodes for action steps
- gateway nodes for decisions
- event nodes for start/end
- lane assignments for roles/departments
- Edge labels for conditional paths

### Tech Stack
Detect from:
- Explicitly mentioned tools
- Implied systems (e.g., "email the client" → email system)
- Industry-standard tools for this process type
- Integration requirements

### Bottleneck Analysis
Analyze the generated flow chart for:
- Nodes with high in-degree (convergence points)
- Manual steps that could be automated
- Sequential steps that could be parallelized
- Handoff points between departments
- Decision gates with many outcomes

## Data Model Extension

The current `Process` type needs these additions for full process cards:

```typescript
interface Process {
  // ... existing fields ...

  // New fields for process card
  executiveSummary?: string;       // Rich executive summary (separate from description)
  sop?: string;                    // Markdown SOP document
  benchmark?: string;              // Markdown benchmark analysis
  bottleneckAnalysis?: string;     // Markdown bottleneck report
  completenessScore?: number;      // 0-100 score
  evaluationStatus?: 'pending' | 'questions_asked' | 'complete';
  pendingQuestions?: string;       // JSON string of ClarificationRequest
  sourceText?: string;             // Original input text for re-evaluation
}
```

## Implementation Phases

### Phase 1: Completeness Checker + Question Flow
- Build the completeness scoring logic
- Integrate with ChatBot for clarifying questions
- Store partial evaluation state

### Phase 2: Full Card Generator
- Executive summary generation
- Enhanced KPI generation (SMART, industry-aware)
- Benchmark generation with persistence
- SOP generation with persistence
- All stored on the Process document

### Phase 3: Enriched Flow Chart
- Better node extraction from natural text
- Automatic role/department detection
- Gateway inference from decision language
- Re-layout after generation

### Phase 4: ChatBot Integration
- ChatBot reads process context
- Can answer questions about specific processes
- Can re-evaluate and update existing process cards
- Conversational process building

## Gemini Prompt Strategy

### Single-Pass Evaluation Prompt
For complete inputs (≥80% score), use a single structured prompt:

```
You are ProcessFlow AI, a business process evaluation expert.

Analyze this process description and produce a COMPLETE PROCESS CARD:

INPUT TEXT:
{input_text}

ADDITIONAL CONTEXT:
{answers to clarifying questions, if any}

Produce a JSON response with:
{
  "executiveSummary": "2-4 sentence summary",
  "kpis": ["SMART KPI 1", "SMART KPI 2", ...],
  "techStack": ["Tool 1", "Tool 2", ...],
  "benchmark": "Markdown benchmark analysis",
  "sop": "Markdown SOP document",
  "bottleneckAnalysis": "Markdown bottleneck report",
  "nodes": [ContentNode format],
  "edges": [ContentEdge format],
  "completenessScore": 85,
  "assumptions": ["assumption 1", ...]
}
```

### Multi-Pass Strategy
For complex or incomplete inputs:
1. **Pass 1: Extract** — Pull out process steps, roles, tools
2. **Pass 2: Questions** — Generate clarifying questions for gaps
3. **Pass 3: Generate** — Full card with enriched context
4. **Pass 4: Validate** — Check consistency of generated components
