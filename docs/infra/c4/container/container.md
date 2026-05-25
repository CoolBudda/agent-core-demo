# Container Diagram — AWS Form Processing Application

## 1. Scope and Purpose

This diagram decomposes the **AWS Form Processing Application** into its deployable containers. It shows the technology choices for each container, the responsibility each one owns, and how data flows through the system on both the request path and the response path. Validation orchestration responsibility is explicitly located at the Lambda Backend.

## 2. Included Elements

| Element | Type | Technology | Responsibility |
|---------|------|------------|----------------|
| End User | Person | — | Submits forms via the web interface. |
| Employee / Operator | Person | — | Receives validated submissions for processing. |
| React Web App | Container | Vite, React, Tailwind CSS | Renders the form UI; collects user input; forwards submissions to AWS API Gateway; displays validation results. |
| AWS API Gateway | Container | AWS Managed | Receives HTTP requests from the browser; authenticates and routes them to the Lambda Backend; forwards responses back to the caller. |
| Lambda Backend | Container | Python 3.10+, uv | Entry point for server-side logic; orchestrates the full multi-agent validation pipeline (validator → error-handler or handoff). |
| AWS Bedrock AgentCore | External System | AWS Managed | Hosts and executes the validator, error-handler, and handoff AI agents invoked by the Lambda Backend. |
| Ticket Tracking System | External System | Assumed REST API | Receives ticket creation requests on validation failure. |

## 3. Key Interactions

| From | To | Interaction | Protocol |
|------|----|-------------|----------|
| End User | React Web App | Fills and submits form | HTTPS |
| React Web App | AWS API Gateway | POST /submit (form payload) | HTTPS / REST |
| AWS API Gateway | Lambda Backend | Invokes Lambda with event payload | AWS SDK |
| Lambda Backend | AWS Bedrock AgentCore | Invokes validator, error-handler, and handoff agents | AWS SDK / HTTPS |
| Lambda Backend | Ticket Tracking System | Creates ticket [on validation failure] | REST / HTTPS |
| Lambda Backend | Employee / Operator | Routes validated submission [on validation success] | Via Handoff Agent / internal notification |
| Lambda Backend | AWS API Gateway | Returns validation result and status | JSON |
| AWS API Gateway | React Web App | Forwards response to browser | HTTPS / JSON |

**Orchestration responsibility** lives in the **Lambda Backend**: it decides which branch to take (failure or success) after receiving the validator agent's verdict.

## 4. Non-Goals

- This diagram does **not** decompose the Lambda Backend into internal modules — see [component.md](../component/component.md).
- This diagram does **not** show Terraform resource definitions or deployment topology.
- This diagram does **not** describe the internal behaviour of AWS Bedrock AgentCore agents.
- Assumptions about authentication, the Ticket Tracking System, and agent hosting are recorded in [assumptions.md](../assumptions.md).
