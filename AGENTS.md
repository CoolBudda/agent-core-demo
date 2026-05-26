# Project Guidelines

## Architecture

This repository has three core work areas:
- ai-agent-app: React + TypeScript frontend for form submission and result display.
- ai-agent-lambda: Python Lambda backend that orchestrates validator, error-handler, and handoff agent calls.
- terra-ai-agent: Terraform project for AWS infrastructure (API Gateway, Lambda, IAM, logging).

For requirements and architecture details, use links instead of re-stating docs:
- Project overview: [README.md](README.md)
- Backend specification: [docs/currated/backend/Backend.spec.md](docs/currated/backend/Backend.spec.md)
- Frontend specification: [docs/currated/frontend/Frontend.spec.md](docs/currated/frontend/Frontend.spec.md)
- Infrastructure specification: [docs/currated/infra/Infra.spec.md](docs/currated/infra/Infra.spec.md)
- C4 diagrams: [docs/infra/c4/README.md](docs/infra/c4/README.md)

## Build and Test

Run commands from each project folder:
- Frontend setup/dev: cd ai-agent-app && npm install && npm run dev
- Frontend checks: cd ai-agent-app && npm run lint && npm run build
- Backend setup: cd ai-agent-lambda && uv sync && uv sync --extra dev
- Backend checks: cd ai-agent-lambda && uv run ruff check . && uv run ruff format . && uv run pytest
- Terraform workflow: cd terra-ai-agent && terraform init && terraform plan

## Conventions

- Keep frontend code feature-first under ai-agent-app/src/features.
- Keep Lambda handler thin and place workflow logic in ai-agent-lambda/src/ai_agent_lambda/agents.
- For AWS infrastructure, default to us-east-1 and least-privilege IAM policies.
- Prefer Terraform changes in terra-ai-agent only; do not mix infra changes into app code.
- When tasks involve architecture artifacts, update diagrams under docs/infra/c4 rather than creating duplicate diagram folders.

## AWS Multi-Agent Folder Pattern

When asked to scaffold a new multi-agent Lambda app, prefer this repository-style pattern at the target folder root:

- multi-agent-registration-app/bedrock-agent/lambda_function.py
- multi-agent-registration-app/bedrock-agent/requirements.txt
- multi-agent-registration-app/agentcore-worker-email/lambda_function.py
- multi-agent-registration-app/agentcore-worker-email/requirements.txt
- README.md

Use this naming unless the user asks for different agent names or a different compute platform.
