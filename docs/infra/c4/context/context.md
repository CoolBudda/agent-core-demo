# Context Diagram — AWS Form Processing Application

## 1. Scope and Purpose

This diagram presents the **system context** for the AWS Form Processing Application. It shows who interacts with the system and which external systems the application depends on, without exposing any internal implementation detail. The primary purpose is to establish system boundaries and clarify the roles of every actor and external dependency.

## 2. Included Elements

| Element | Type | Description |
|---------|------|-------------|
| End User | Person | Submits forms through the web interface. |
| Employee / Operator | Person | Receives form submissions that have passed validation for manual or automated processing. |
| AWS Form Processing Application | Software System (primary) | The AWS-hosted application that accepts form submissions, orchestrates AI-agent validation, routes successful submissions, and creates tickets for failed ones. |
| Ticket Tracking System | External Software System | Third-party or internal system that receives ticket creation requests when form validation fails. |
| AWS Bedrock AgentCore | External Software System | AWS-managed service that hosts and executes the validator, error-handler, and handoff AI agents. |

## 3. Key Interactions

| From | To | Interaction | Protocol |
|------|----|-------------|----------|
| End User | AWS Form Processing Application | Submits form data | HTTPS |
| AWS Form Processing Application | Employee / Operator | Routes validated submission on success | Internal notification / handoff |
| AWS Form Processing Application | Ticket Tracking System | Creates a ticket on validation failure | REST / HTTPS |
| AWS Form Processing Application | AWS Bedrock AgentCore | Invokes AI agents for validation, error handling, and handoff | AWS SDK / HTTPS |

## 4. Non-Goals

- This diagram does **not** show internal containers (React Web App, API Gateway, Lambda Backend) — see [container.md](../container/container.md).
- This diagram does **not** describe the agent orchestration sequence — see [component.md](../component/component.md).
- This diagram does **not** cover infrastructure provisioning (Terraform) or CI/CD pipelines.
- Assumptions about the Ticket Tracking System and agent details are recorded in [assumptions.md](../assumptions.md).
