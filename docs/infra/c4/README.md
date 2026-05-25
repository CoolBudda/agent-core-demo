# C4 Architecture Diagrams — AWS Form Processing Application

This directory contains the C4 model architecture documentation for the AWS Form Processing Application. Diagrams are authored in [PlantUML](https://plantuml.com/) using the [C4-PlantUML](https://github.com/plantuml-stdlib/C4-PlantUML) macro library and can be rendered with any PlantUML-compatible tool.

---

## What Is the C4 Model?

The [C4 model](https://c4model.com/) (Context, Containers, Components, Code) is a structured approach to visualising software architecture at four progressive levels of detail. This project documents three levels:

| Level | What It Shows |
|-------|---------------|
| **Context** | The system in relation to its users and external dependencies — the "big picture". |
| **Container** | The deployable units (apps, services, databases) that make up the system and how they communicate. |
| **Component** | The internal modules or classes within a single container (Lambda Backend) and their interactions. |

Each level zooms in on a specific element from the level above, maintaining consistent naming and boundaries across all diagrams.

---

## File Structure

```
docs/c4/
├── README.md             ← This file
├── assumptions.md        ← All assumptions and confirmed project facts
├── context/
│   ├── context.puml      ← C4 Context diagram (PlantUML source)
│   └── context.md        ← Context diagram documentation
├── container/
│   ├── container.puml    ← C4 Container diagram (PlantUML source)
│   └── container.md      ← Container diagram documentation
└── component/
    ├── component.puml    ← C4 Component diagram (Lambda Backend)
    └── component.md      ← Component diagram documentation
```

---

## How the Three Levels Connect

```
Context Diagram
  └─ "AWS Form Processing Application" (black box)
       │
       ▼
  Container Diagram
    ├─ React Web App
    ├─ AWS API Gateway
    └─ Lambda Backend  ◄── decomposed below
         │
         ▼
    Component Diagram
      ├─ Lambda Handler
      ├─ Validator Agent Client
      ├─ Error Handler Agent Client
      ├─ Handoff Agent Client
      └─ Logger
```

- The **Context diagram** establishes the system boundary and identifies all external actors and dependencies.
- The **Container diagram** opens the black box to reveal deployable units, technology choices, and inter-service data flows (both request and response paths).
- The **Component diagram** zooms into the **Lambda Backend** — the orchestration core — to show how its internal Python modules implement the multi-agent validation pipeline.

---

## Rendering the Diagrams

Any of the following tools can render `.puml` files:

- **VS Code**: [PlantUML extension](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml) (requires a local Java + Graphviz install or the PlantUML server).
- **Online**: Paste `.puml` content at [https://www.plantuml.com/plantuml/uml/](https://www.plantuml.com/plantuml/uml/).
- **CLI**: `plantuml docs/c4/**/*.puml`
- **CI**: Use the [plantuml-github-action](https://github.com/marketplace/actions/generate-plantuml) to generate PNG/SVG artifacts automatically.

---

## Assumptions

All assumptions and confirmed project facts are recorded in [assumptions.md](./assumptions.md).
