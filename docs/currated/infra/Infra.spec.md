# Infrastructure Specification

## Purpose

Demonstrate AWS Bedrock AgentCore by orchestrating multiple agents to process a user-submitted form.

## Services Overview

```
User (Form Submit)
    │
    ▼
AWS API Gateway
    │  (proxy integration)
    ▼
AWS Lambda (Python 3.10+)
    │  (orchestrates multi-agent flow)
    ▼
AWS Bedrock AgentCore
    │
    ├── Agent 1: Data Validation
    │       └── validates form data against backend system
    │
    ├── Agent 2: Error Handling  (if validation fails)
    │       └── creates ticket in tracking system
    │
    └── Agent 3: Human Handoff   (if validation passes)
            └── sends submission to employee for action
```

## Services

| Service               | Role                                                        |
|-----------------------|-------------------------------------------------------------|
| AWS API Gateway       | Receives form submissions, routes to Lambda                 |
| AWS Lambda            | Compute layer; triggers Bedrock AgentCore multi-agent flow  |
| AWS Bedrock AgentCore | Orchestrates agents: validation, error handling, handoff    |
| Ticket Tracking System| Creates tickets when validation errors are found            |

## Infrastructure as Code

| Property | Value     |
|----------|-----------|
| Tool     | Terraform |

## Notes

- API Gateway is configured with a direct Lambda integration.
- Bedrock AgentCore orchestrates all agents; Lambda does not implement agent logic directly.
- The UI/API submission layer is intentionally minimal — the multi-agent flow is the focus.
