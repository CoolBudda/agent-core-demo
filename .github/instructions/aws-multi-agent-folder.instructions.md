---
description: "Use when creating or restructuring AWS multi-agent projects, Lambda folder layout, Bedrock agent orchestration folders, or AgentCore worker scaffolding."
---

# AWS Multi-Agent Folder Scaffolding

Apply these rules when users ask for a new AWS multi-agent app layout.

## Default Structure

Create the project with these top-level directories by default:
- bedrock-agent/
- agencycore-worker1/
- agencycore-worker2/

Each directory should include:
- lambda_function.py
- utils.py
- requirements.txt

Also create a root README.md that documents:
- Each agent/worker responsibility
- Deployment steps per Lambda
- Environment variables and IAM permission expectations

## Responsibilities

- bedrock-agent: coordinator or primary entry Lambda that invokes Bedrock agent runtime APIs.
- agencycore-worker1: worker Lambda for one specialized step in the flow.
- agencycore-worker2: worker Lambda for a second specialized step in the flow.

If the user provides explicit names or responsibilities, use those instead of defaults.

## Guardrails

- Do not merge all logic into one Lambda unless requested.
- Keep shared helper logic in each service-local utils.py first; only extract shared packages when duplication is proven.
- Keep dependencies minimal in requirements.txt per service to reduce cold-start package size.
- Ensure architecture recommendations remain consistent with [docs/currated/infra/Infra.spec.md](docs/currated/infra/Infra.spec.md).
