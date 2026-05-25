## Assumptions

| # | Assumption | Rationale |
|---|------------|-----------|
| 1 | The Ticket Tracking System exposes a REST API over HTTPS for ticket creation. | No specific system (e.g., Jira, ServiceNow) was named in the project facts. A REST/HTTPS interface is the most common integration pattern; the exact endpoint is implementation-specific. |
| 2 | AWS API Gateway uses a REST or HTTP API type (not WebSocket). | The business flow is synchronous request-response (form submit → validate → respond). WebSocket would only be needed for streaming or long-running async flows. |
| 3 | The Lambda Backend is invoked synchronously by API Gateway (request-response mode). | The form submission flow requires an immediate validation result returned to the React Web App. |
| 4 | AWS Bedrock AgentCore hosts exactly three agents: validator, error-handler, and handoff. | Derived directly from the backend source structure (`agents/validator.py`, `agents/error_handler.py`, `agents/handoff.py`). No additional agents are assumed. |
| 5 | Authentication between the React Web App and AWS API Gateway (e.g., Cognito, API key, IAM) is outside the scope of these diagrams. | No auth mechanism was specified in the project facts. Auth is acknowledged as a likely concern but left unspecified to avoid inventing infrastructure. |
| 6 | The Employee / Operator receives submission handoffs via the Bedrock AgentCore handoff agent rather than a direct Lambda-to-employee call. | The handoff agent encapsulates routing logic; Lambda delegates to it rather than maintaining employee routing tables itself. |
| 7 | Terraform manages all AWS infrastructure (API Gateway, Lambda, Bedrock AgentCore configuration) but is not represented as a runtime component in C4 diagrams. | Terraform is an IaC tool; it creates infrastructure but does not participate in runtime data flows and therefore does not appear as a container or component. |
| 8 | The React Web App is a single-page application (SPA) served as static assets (e.g., from S3 + CloudFront or a similar CDN). | Vite produces static build artifacts. No SSR framework (Next.js, Remix) is listed in the project facts. The exact hosting mechanism is unspecified and not shown in the diagrams. |
| 9 | Structured logging in the Lambda Backend uses Python's standard `logging` module, potentially enhanced with aws-lambda-powertools. | The project uses `uv` and `ruff` but does not explicitly name a logging library. aws-lambda-powertools is the de-facto standard for structured Lambda logging in Python. |
| 10 | The Error Handler Agent Client calls the Ticket Tracking System indirectly via the Bedrock AgentCore error-handler agent (the agent owns the ticket creation call), or directly from the Lambda component. Both interpretations are architecturally valid; the diagrams show it as a direct call from the Error Handler Agent Client to keep the component boundary clear. | Bedrock AgentCore agents may themselves call external APIs via action groups. The exact delegation boundary is an implementation detail not specified in the project facts. |

---

## Confirmed Facts (from project specification)

| Category | Fact |
|----------|------|
| Frontend | Vite, React, Tailwind CSS, ESLint |
| Backend | AWS Lambda, Python 3.10+, uv, ruff (lint + format) |
| Platform services | AWS API Gateway, AWS Bedrock AgentCore |
| IaC | Terraform |
| Business flow | User submits form → validate → [failure] create ticket; [success] route to employee |
| Agent modules | `agents/validator.py`, `agents/error_handler.py`, `agents/handoff.py` |
