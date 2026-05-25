# AWS Lambda Python AI Platform Prompt

## Goal

Build a production-oriented Python AWS Lambda backend for AI-powered document processing and semantic search.

Prioritize:
- clean architecture
- maintainability
- scalability
- observability
- AI workflow extensibility

---

# Tech Stack

Use:
- Python 3.12
- AWS Lambda
- API Gateway
- DynamoDB
- S3
- Bedrock
- boto3
- Pydantic
- pytest
- structlog

Avoid:
- Flask
- Django
- monolithic handlers
- global mutable state

---

# Project Structure

```text
src/
  handlers/
  services/
  repositories/
  models/
  core/
  utils/
  tests/
```

Rules:
- handlers stay thin
- services contain business logic
- repositories isolate persistence
- centralized config/logging/errors

---

# Lambda Rules

Each Lambda should:
- have single responsibility
- be independently deployable
- support retries/idempotency
- use structured logging
- include correlation IDs

Avoid giant multi-purpose Lambdas.

---

# API Rules

Use API Gateway proxy format.

Response format:

```json
{
  "success": true,
  "data": {},
  "error": null
}
```

Errors must include:
- code
- message
- correlation_id

---

# Validation

Use Pydantic for:
- request validation
- response validation
- config validation

Validate all external input.

---

# Logging

Use structured JSON logs.

Include:
- request_id
- correlation_id
- lambda_name
- execution_time

Never use print().

---

# Error Handling

Implement centralized exception handling.

Requirements:
- typed exceptions
- retry-safe handling
- sanitized client errors

---

# AWS Integration

Use boto3 through service/repository abstractions.

Bad:
handler -> boto3 directly

Good:
handler -> service -> repository

---

# AI / Bedrock Rules

Encapsulate all LLM logic in:

```text
services/bedrock_service.py
```

Support:
- model abstraction
- retries
- timeout handling
- token usage logging
- prompt versioning

---

# Document Pipeline

Design for:

upload
→ parsing
→ chunking
→ embeddings
→ vector indexing
→ retrieval

Prefer asynchronous/event-driven workflows.

---

# Configuration

Centralize environment config in:

```text
core/config.py
```

Support:
- local
- dev
- staging
- prod

No hardcoded values.

---

# Observability

Prepare for:
- CloudWatch
- X-Ray
- OpenTelemetry

Support:
- structured logs
- metrics
- tracing hooks

---

# Testing

Use pytest.

Create:
- unit tests
- integration tests

Mock AWS dependencies cleanly.

---

# Security

Never:
- log secrets
- expose stack traces
- hardcode credentials
- trust user input

Use least-privilege IAM principles.

---

# Performance

Optimize for:
- low cold starts
- small package size
- connection reuse
- minimal dependencies

Avoid loading large models inside Lambda.

---

# Code Style

Requirements:
- typed Python
- small focused modules
- descriptive naming
- explicit dependencies

Prefer:
- composition
- pure functions
- deterministic services

---

# Expected Output

Generate:
- deployable Lambda project
- example handlers
- service layer
- repository layer
- Bedrock integration foundation
- logging setup
- Pydantic models
- pytest examples

The architecture should support:
- RAG pipelines
- semantic search
- agent workflows
- future multi-agent orchestration