# Component Diagram — Lambda Backend

## 1. Scope and Purpose

This diagram decomposes the **Lambda Backend** container into its internal Python modules (components). It shows how the Lambda Handler coordinates the multi-agent validation pipeline and how each agent client interacts with AWS Bedrock AgentCore and external systems. The diagram makes the branching logic between the validation failure path and the validation success path explicit.

## 2. Included Elements

| Element | Type | Module / Technology | Responsibility |
|---------|------|---------------------|----------------|
| Employee / Operator | Person (external) | — | Receives routed submissions on validation success. |
| Ticket Tracking System | External System | REST API | Receives ticket creation requests on validation failure. |
| AWS Bedrock AgentCore | External System | AWS Managed | Hosts the validator, error-handler, and handoff agents. |
| AWS API Gateway | External System | AWS Managed | Invokes the Lambda Handler and receives its response. |
| **Lambda Handler** | Component | `handler.py` | Entry point. Parses the API Gateway event, drives the agent pipeline, and returns the response. |
| **Validator Agent Client** | Component | `agents/validator.py`, boto3 | Calls the Bedrock AgentCore validator agent; returns `valid \| invalid` plus structured error details. |
| **Error Handler Agent Client** | Component | `agents/error_handler.py`, boto3 | Called on validation failure; invokes the Bedrock AgentCore error-handler agent, which triggers ticket creation. |
| **Handoff Agent Client** | Component | `agents/handoff.py`, boto3 | Called on validation success; invokes the Bedrock AgentCore handoff agent to route the submission to an employee. |
| **Logger** | Component | `logging` / aws-lambda-powertools | Cross-cutting structured logger used by all components. |

## 3. Key Interactions

| From | To | Interaction | Protocol |
|------|----|-------------|----------|
| AWS API Gateway | Lambda Handler | Invokes with event payload | AWS SDK |
| Lambda Handler | Validator Agent Client | Always called first to validate the submission | In-process |
| Validator Agent Client | AWS Bedrock AgentCore | Invoke validator agent | AWS SDK / HTTPS |
| Lambda Handler | Error Handler Agent Client | Called **[on invalid result]** | In-process |
| Error Handler Agent Client | AWS Bedrock AgentCore | Invoke error-handler agent | AWS SDK / HTTPS |
| Error Handler Agent Client | Ticket Tracking System | Create ticket for failed submission | REST / HTTPS |
| Lambda Handler | Handoff Agent Client | Called **[on valid result]** | In-process |
| Handoff Agent Client | AWS Bedrock AgentCore | Invoke handoff agent | AWS SDK / HTTPS |
| Handoff Agent Client | Employee / Operator | Route validated submission | Via Handoff Agent / internal notification |
| All components | Logger | Structured log events | In-process |

**Orchestration sequence:**

```
Lambda Handler
  └─► Validator Agent Client ──► Bedrock AgentCore (validator)
        ├─ [invalid] ─► Error Handler Agent Client ──► Bedrock AgentCore (error-handler)
        │                                           └─► Ticket Tracking System
        └─ [valid]   ─► Handoff Agent Client       ──► Bedrock AgentCore (handoff)
                                                    └─► Employee / Operator
```

## 4. Non-Goals

- This diagram does **not** show the internal implementation of AWS Bedrock AgentCore agents (prompt design, model selection, etc.).
- This diagram does **not** cover the React Web App or API Gateway internals.
- This diagram does **not** describe infrastructure provisioning (Terraform).
- Assumptions about boto3 configuration, IAM roles, and agent IDs are recorded in [assumptions.md](../assumptions.md).
