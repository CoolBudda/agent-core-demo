---
mode: agent
description: Generate C4 architecture diagrams (Context, Container, Component) as PlantUML files for this project.
---

# Generate C4 Architecture Diagrams in PlantUML

## Objective

Read the project facts below and produce three C4 architecture diagrams as standalone PlantUML files, together with matching markdown documentation and a README.
Output all files under `docs/c4/` using the exact structure defined in [Required Output Paths](#required-output-paths).

---

## Authoritative Project Facts

Use these facts as the sole architectural baseline. Do not invent infrastructure beyond what is listed here.

| Category          | Details                                                                 |
|-------------------|-------------------------------------------------------------------------|
| Frontend          | Vite, React, Tailwind CSS (only), ESLint                               |
| Backend           | AWS Lambda, Python 3.10+, uv, ruff (lint + format)                     |
| Platform services | AWS API Gateway, AWS Bedrock AgentCore                                  |
| IaC               | Terraform                                                               |
| Business flow     | User submits a form → validate → on failure: create ticket; on success: route to employee |

---

## Required Output Paths

Create every file below at the exact path shown.

```
docs/c4/
├── README.md
├── assumptions.md
├── context/
│   ├── context.puml
│   └── context.md
├── container/
│   ├── container.puml
│   └── container.md
└── component/
    ├── component.puml
    └── component.md
```

---

## PlantUML Standards

Apply these rules to every `.puml` file.

1. Use **C4-PlantUML** macros (`C4Context`, `C4Container`, `C4Component` includes).
2. Each file must be **standalone and renderable** — include the full `!include` header.
3. Add a descriptive `title` to every diagram.
4. Use **concrete, implementation-specific names** — no generic placeholders.
5. Show system boundaries, trust boundaries, actors, and primary data flows.
6. Label protocols and interfaces where known (e.g., HTTPS, AWS SDK, REST).
7. Represent **both success and failure paths** in the validation flow.
8. Keep **element identifiers and names consistent** across all three levels.
9. Use `note` blocks only to clarify branching behaviour or confirmed assumptions.

---

## Level-Specific Requirements

### Context Diagram — `docs/c4/context/context.puml`

| Element type   | Elements                                                    |
|----------------|-------------------------------------------------------------|
| Actors         | End User, Employee / Operator                               |
| Primary system | AWS-hosted form-processing application (single black box)   |
| External systems | Ticket Tracking System, AWS Bedrock AgentCore             |

- Show high-level interactions and system boundaries only.
- Do not decompose internal containers at this level.

---

### Container Diagram — `docs/c4/container/container.puml`

Show each deployable container as a distinct C4 `Container` element.

| Container               | Technology              | Responsibility                         |
|-------------------------|-------------------------|----------------------------------------|
| React Web App           | Vite + React + Tailwind | User-facing form UI                    |
| AWS API Gateway         | AWS managed             | Receives requests, routes to Lambda    |
| Lambda Backend          | Python 3.10+, uv        | Orchestrates multi-agent pipeline      |
| AWS Bedrock AgentCore   | AWS managed             | Hosts and runs all three agents        |
| Ticket Tracking System  | External (assumed)      | Creates tickets on validation failure  |

- Show both the **request path** and the **response path**.
- Indicate where authentication, validation, and orchestration responsibilities live.

---

### Component Diagram — `docs/c4/component/component.puml`

Decompose the **Lambda Backend** container into concrete internal components.

Required components and interactions:

1. **Lambda Handler** — entry point; parses API Gateway event; calls agents in sequence.
2. **Validator Agent Client** — invokes Bedrock AgentCore validator agent; returns `valid | invalid` + errors.
3. **Error Handler Agent Client** — invoked on validation failure; calls Bedrock AgentCore error-handler agent; triggers ticket creation.
4. **Handoff Agent Client** — invoked on validation success; calls Bedrock AgentCore handoff agent; routes submission to employee.
5. **Logger** — cross-cutting; used by all components.

Orchestration sequence to represent:

```
Lambda Handler
  └─► Validator Agent Client
        ├─ [invalid] ─► Error Handler Agent Client ──► Ticket Tracking System
        └─ [valid]   ─► Handoff Agent Client       ──► Employee / Operator
```

---

## Markdown Documentation Requirements

For **each** level's `.md` file, include all four sections below:

1. **Scope and purpose** — what this diagram shows and why.
2. **Included elements** — list every actor, system, container, or component shown.
3. **Key interactions** — describe the main data flows and their direction.
4. **Non-goals** — what this level deliberately omits.

Additional rules:
- Be concise and implementation-oriented.
- Do not duplicate content from `assumptions.md`; reference it instead.

---

## assumptions.md

Record every assumption or unknown in this file using the format below:

```markdown
## Assumptions

| # | Assumption | Rationale |
|---|------------|-----------|
| 1 | ... | ... |
```

Separate confirmed facts from assumptions clearly.

---

## Quality Gate Checklist

Before producing final output, verify every item:

- [ ] All three C4 levels (Context, Container, Component) are present.
- [ ] Diagrams are logically consistent across levels — names and elements align.
- [ ] Each `.puml` file is standalone and includes its C4-PlantUML header.
- [ ] Output paths match the required structure exactly.
- [ ] No infrastructure was invented beyond the project facts.
- [ ] All assumptions are recorded in `assumptions.md`.
- [ ] PlantUML syntax is valid.

---

## Final Response Format

Conclude your response with:

1. A bullet list of every generated file.
2. One paragraph explaining how the Context, Container, and Component views form a coherent architecture narrative for this project.
