
# Infrastructure Specification

## Purpose
Support a multi-agent registration pipeline using AWS Bedrock AgentCore, Lambda, and API Gateway.

## Architecture

```
User (Form Submit)
    │
    ▼
AWS API Gateway (proxy integration)
    │
    ▼
AWS Lambda (Python 3.10+)
    │
    ▼
AWS Bedrock AgentCore
    ├── Data Validator Agent
    ├── Error Handler Agent (on validation fail)
    └── Human Handoff Agent (on validation pass)
```

## Services
| Service               | Role                                                        |
|-----------------------|-------------------------------------------------------------|
| AWS API Gateway       | Receives form submissions, routes to Lambda                 |
| AWS Lambda            | Orchestrates Bedrock AgentCore multi-agent flow             |
| AWS Bedrock AgentCore | Orchestrates agents: validation, error handling, handoff    |
| Ticket Tracking System| Creates tickets when validation errors are found            |

## Infrastructure as Code
| Property | Value     |
|----------|-----------|
| Tool     | Terraform |

## Notes
- API Gateway uses direct Lambda integration.
- Bedrock AgentCore handles all agent logic.
- UI/API submission is minimal; focus is on agent orchestration.
