# Requirement Curation Pipeline Prompt

## Goal

Use the Requirement Extraction Specialist skill to analyze raw project documents and generate curated, implementation-oriented requirement documents under:

docs/curated/

The objective is to transform messy or incomplete source material into structured engineering artifacts suitable for:

- architecture design
- implementation planning
- backlog generation
- AI agent workflows
- technical review
- system decomposition

---

# Input Sources

Analyze all documents under:

docs/raw/

Supported inputs include:

- markdown
- txt
- exported PDFs
- meeting notes
- RFCs
- PRDs
- transcripts
- emails
- Jira exports
- Slack exports

The input data may contain:
- duplication
- ambiguity
- contradictions
- partial requirements
- conversational noise
- outdated information

---

# Skill Usage

Use the "Requirement Extraction Specialist" skill for all analysis.

The skill must:

- extract structured requirements
- normalize terminology
- detect ambiguity
- detect contradictions
- infer architecture implications
- classify priorities
- identify risks and dependencies

Do NOT generate casual summaries.

The output should resemble professional systems analysis documentation.

---

# Processing Workflow

For each document:

1. Parse raw content
2. Extract:
   - functional requirements
   - non-functional requirements
   - constraints
   - dependencies
   - assumptions
   - risks
   - open questions
3. Normalize terminology
4. Merge duplicate requirements
5. Detect contradictions
6. Generate curated outputs
7. Save outputs into docs/curated/

---

# Output Directory Structure

Generate:

```text
docs/
  curated/
    executive-summary.md
    functional-requirements.md
    non-functional-requirements.md
    constraints.md
    dependencies.md
    risks.md
    assumptions.md
    open-questions.md
    domain-model.md
    suggested-apis.md
    architecture-notes.md
    requirement-traceability.md
```

---

# Output Requirements

All outputs must:

- use markdown
- be implementation-oriented
- avoid conversational language
- preserve technical detail
- include requirement IDs
- classify confidence
- classify priority
- remain architecture-aware

---

# Functional Requirement Format

Use:

```text
FR-001 [Priority: Critical] [Confidence: High]

Description:
Users can upload PDF documents up to 50MB.

Source:
meeting-notes-2026-05-10.md

Acceptance Criteria:
- Upload succeeds for valid PDFs
- Reject files above limit
- Virus scan completes before indexing
```

Requirements must be:
- atomic
- testable
- implementation-ready

---

# Non-Functional Requirement Format

Use:

```text
NFR-001 [Priority: High] [Confidence: Medium]

Description:
Search responses should complete within 500ms for 95th percentile queries.
```

Include:
- scalability
- latency
- observability
- availability
- security
- compliance
- performance
- multi-region requirements

when available.

---

# Risk Format

Use:

```text
R-001

Risk:
No document retention policy specified.

Impact:
Potential compliance and storage cost concerns.

Recommendation:
Clarify retention requirements before implementation.
```

---

# Ambiguity Handling

Never silently resolve ambiguity.

Instead generate:

```text
OQ-001

Question:
Maximum upload size is undefined.

Context:
Documents mention "large uploads" but provide no limit.
```

---

# Contradiction Handling

Generate explicit contradiction reports.

Example:

```text
Conflict-001

Conflict:
Document A states:
- offline-first support required

Document B states:
- constant internet connection required

Resolution Status:
Unresolved
```

---

# Domain Model Extraction

Infer likely entities.

Example:

```text
Entity: Document
Attributes:
- id
- filename
- uploadDate
- ownerId
- embeddingStatus
```

---

# Suggested API Extraction

Infer likely APIs.

Example:

```text
POST /documents/upload
GET /documents/{id}
POST /search/query
```

Include:
- request purpose
- authentication assumptions
- likely response behavior

---

# Architecture Note Extraction

Infer architectural implications when strongly supported.

Examples:
- asynchronous ingestion pipeline
- vector database requirement
- event-driven indexing
- background workers
- queue-based processing
- caching requirements
- multi-tenant isolation
- Bedrock/LLM integration
- semantic search infrastructure

---

# Traceability Requirements

Generate:

docs/curated/requirement-traceability.md

This file should map:

```text
Requirement ID
→ source document
→ source section
→ inferred dependencies
```

---

# AI/LLM-Specific Rules

If AI systems are mentioned, extract:

- model providers
- prompt orchestration
- RAG requirements
- embedding pipelines
- vector databases
- hallucination mitigation
- evaluation requirements
- latency expectations
- token/cost concerns
- safety/compliance concerns

---

# Quality Bar

The curated outputs must resemble artifacts produced by:
- senior architects
- staff engineers
- technical analysts

Avoid:
- fluffy summaries
- generic observations
- vague wording
- repeated content
- unstructured notes

Prefer:
- normalized requirements
- implementation detail
- architectural clarity
- engineering usefulness

---

# Final Objective

Produce a curated engineering knowledge base under:

docs/curated/

suitable for:
- implementation planning
- AI agent orchestration
- architecture reviews
- backlog generation
- technical estimation
- downstream automation