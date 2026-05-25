# ai-agent-lambda

AWS Lambda backend that orchestrates a multi-agent pipeline via **AWS Bedrock AgentCore** to process user form submissions.

## Agent Pipeline

```
Form Submission (API Gateway → Lambda)
    │
    ▼
Agent 1: Data Validator  ──── always runs
    │
    ├── validation failed ──▶ Agent 2: Error Handler (creates ticket)
    │
    └── validation passed ──▶ Agent 3: Human Handoff (routes to employee)
```

## Setup

```bash
# Install dependencies
uv sync

# Install dev dependencies
uv sync --extra dev
```

## Development

```bash
# Lint
uv run ruff check .

# Auto-fix
uv run ruff check . --fix

# Format
uv run ruff format .

# Run tests
uv run pytest
```

## Project Structure

```
src/ai_agent_lambda/
├── handler.py          # Lambda entry point
├── agents/
│   ├── validator.py    # Agent 1: validates form data
│   ├── error_handler.py# Agent 2: creates ticket on validation failure
│   └── handoff.py      # Agent 3: routes to employee on success
└── models/
    └── form.py         # FormSubmission data model
```
