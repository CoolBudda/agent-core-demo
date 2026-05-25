# Backend Specification

## Runtime

| Property | Value        |
|----------|--------------|
| Platform | AWS Lambda   |
| Language | Python 3.10+ |

## Tooling

| Tool    | Purpose                     |
|---------|-----------------------------|
| uv      | Package & environment manager |
| ruff    | Linter (`ruff check`)       |
| ruff    | Formatter (`ruff format`)   |

## Common Commands

```bash
# Install dev dependencies
uv add --dev ruff

# Lint
uv run ruff check .

# Auto-fix lint issues
uv run ruff check . --fix

# Format
uv run ruff format .
```

## Agent Processing Flow

Lambda triggers a multi-agent pipeline in Bedrock AgentCore:

| Step | Agent             | Trigger                        | Action                                      |
|------|-------------------|--------------------------------|---------------------------------------------|
| 1    | Data Validator    | Always                         | Validates form fields against backend system |
| 2    | Error Handler     | Validation fails               | Creates a ticket in a tracking system        |
| 3    | Human Handoff     | Validation passes              | Forwards submission to an employee           |

## Notes

- Lambda functions receive requests forwarded from AWS API Gateway.
- Lambda delegates multi-agent orchestration to AWS Bedrock AgentCore.
- The submission entry point (UI form or POST API) is secondary to the agent pipeline.
