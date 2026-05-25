# Skill: Requirement Extraction Specialist

## Purpose

Extract structured, implementation-ready requirements from raw unstructured documents.

The skill should transform messy business or technical documentation into normalized engineering requirements suitable for:

- architecture design
- backlog generation
- API planning
- system decomposition
- agent workflows
- engineering estimation
- implementation planning

---

# Input Types

The skill must support:

- PRDs
- RFCs
- business documents
- meeting notes
- Slack conversations
- emails
- architecture docs
- transcripts
- Jira exports
- markdown files
- PDFs converted to text
- customer requests
- support tickets

Inputs may be:
- incomplete
- ambiguous
- duplicated
- contradictory
- noisy
- partially structured

---

# Primary Objectives

Extract and normalize:

1. Functional requirements
2. Non-functional requirements
3. Business goals
4. User workflows
5. Constraints
6. Dependencies
7. Risks
8. Assumptions
9. Open questions
10. Acceptance criteria

The output should prioritize:
- clarity
- traceability
- implementation usefulness
- architecture relevance

---

# Extraction Rules

## General Rules

- Do NOT summarize blindly.
- Preserve important implementation details.
- Normalize inconsistent wording.
- Remove conversational noise.
- Merge duplicate requirements.
- Detect conflicting requirements.
- Flag ambiguities explicitly.
- Infer implicit technical requirements when strongly implied.

---

# Functional Requirement Extraction

Extract explicit system behaviors.

Examples:
- authentication flows
- search functionality
- document upload
- notifications
- role permissions
- API interactions
- workflow automation

Format:

```text
FR-001:
Users can upload PDF documents up to 50MB.

FR-002:
The system must support semantic search across uploaded documents.
```

Requirements must:
- be atomic
- testable
- implementation-oriented

---

# Non-Functional Requirement Extraction

Extract quality attributes.

Examples:
- scalability
- latency
- availability
- security
- compliance
- accessibility
- observability
- multi-region support

Format:

```text
NFR-001:
API responses should complete within 500ms under normal load.

NFR-002:
The platform must support 99.9% uptime.
```

---

# Constraint Extraction

Identify constraints including:

- technology restrictions
- cloud/vendor requirements
- budget limitations
- compliance obligations
- deployment restrictions
- timeline constraints
- browser/device limitations

Format:

```text
C-001:
The solution must run entirely within AWS.

C-002:
PII data cannot leave Canada.
```

---

# Dependency Extraction

Identify:

- external systems
- APIs
- vendors
- internal teams
- data sources
- infrastructure dependencies

Format:

```text
D-001:
Requires integration with Okta SSO.

D-002:
Depends on Bedrock knowledge base availability.
```

---

# Assumption Detection

Explicitly identify assumptions.

Format:

```text
A-001:
Assumes all uploaded files are machine-readable PDFs.

A-002:
Assumes users already exist in corporate identity provider.
```

---

# Risk Detection

Identify:
- unclear ownership
- scalability concerns
- compliance concerns
- operational risks
- missing requirements
- integration uncertainty

Format:

```text
R-001:
No retention policy specified for uploaded documents.

R-002:
Search indexing scalability requirements are undefined.
```

---

# Ambiguity Detection

The skill MUST flag ambiguous statements.

Examples:

Bad:
"fast search"

Good:
Ambiguity:
Search latency target is unspecified.

Bad:
"large file uploads"

Good:
Ambiguity:
Maximum upload size is undefined.
```

---

# Output Structure

Return results in the following structure:

# Executive Summary

Short overview of:
- system purpose
- primary workflows
- major architectural themes

---

# Functional Requirements

Ordered list.

---

# Non-Functional Requirements

Ordered list.

---

# Constraints

Ordered list.

---

# Dependencies

Ordered list.

---

# Risks

Ordered list.

---

# Assumptions

Ordered list.

---

# Open Questions

List unresolved issues requiring clarification.

Examples:
- Who owns document retention?
- Is multi-tenant isolation required?
- What authentication provider is mandated?

---

# Suggested Domain Model

Infer potential entities.

Example:

```text
Entities:
- User
- Workspace
- Document
- Embedding
- SearchIndex
- Permission
```

---

# Suggested APIs

Infer likely APIs when possible.

Example:

```text
POST /documents/upload
GET /documents/{id}
POST /search/query
```

---

# Suggested Architecture Notes

Infer likely architectural implications.

Examples:
- asynchronous document ingestion pipeline
- vector database required
- background processing required
- event-driven indexing pipeline
- caching layer recommended

---

# Requirement Quality Rules

Requirements should be:

- atomic
- measurable
- implementation-relevant
- unambiguous
- testable
- normalized

Avoid:
- vague language
- duplicated requirements
- business fluff
- conversational phrasing

---

# Priority Classification

Classify requirements:

- Critical
- High
- Medium
- Low

When confidence is low, mark:
- Unknown Priority

---

# Confidence Scoring

Each extracted requirement should include:

- High confidence
- Medium confidence
- Low confidence

Low confidence requirements should explain uncertainty.

---

# Contradiction Handling

Detect contradictions.

Example:

```text
Conflict:
Document says both:
- "system is offline-first"
- "requires constant internet connection"
```

Do NOT silently resolve contradictions.

---

# Architecture Awareness

The skill should infer:
- likely system scale
- distributed system implications
- AI/ML implications
- security implications
- operational implications

when strongly supported by context.

---

# AI-Specific Extraction Rules

If documents mention AI/LLM systems, extract:

- model providers
- context window concerns
- vector search requirements
- prompt orchestration
- RAG pipelines
- evaluation requirements
- hallucination risks
- latency expectations
- cost constraints
- safety/compliance constraints

---

# Final Goal

Produce outputs useful for:
- architects
- senior engineers
- product managers
- AI agents
- implementation planning systems
- backlog generation pipelines

The output should resemble a professional systems analysis artifact rather than a casual summary.