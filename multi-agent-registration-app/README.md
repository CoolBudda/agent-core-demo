# multi-agent-registration-app

Processes user registration via free-text input using AWS Bedrock Agent (planner/reasoner)
and an AgentCore worker Lambda (email confirmation).

## Flow

```
User free-text
    │
    ▼
bedrock-agent/            ← calls Bedrock Agent runtime (invoke_agent)
    │
    ├── missing fields → ask user for missing information (handled by Bedrock Agent)
    │
    └── all fields present
            │
            ▼
    agent-worker-email/   ← Bedrock Agent action group; sends confirmation email via SES
```

## Required Fields

| Field          | Example            |
|----------------|--------------------|
| name           | Alice              |
| email          | alice@example.com  |
| phone          | +1-555-123-4567    |
| favorite_sport | tennis             |

## Environment Variables

### bedrock-agent

| Variable               | Description                          |
|------------------------|--------------------------------------|
| BEDROCK_AGENT_ID       | Bedrock Agent resource ID            |
| BEDROCK_AGENT_ALIAS_ID | Bedrock Agent alias ID (e.g. prod)   |

### agent-worker-email

| Variable          | Description                        |
|-------------------|------------------------------------|
| SES_SENDER_EMAIL  | Verified SES sender address        |

## Deployment

1. Deploy `agent-worker-email` as a Lambda and note its ARN.
2. In the AWS Console (or Terraform), create a Bedrock Agent with:
   - System prompt describing the 4 required fields and missing-field follow-up behavior.
    - Action group pointing to the `agent-worker-email` Lambda ARN.
3. Deploy `bedrock-agent` as a Lambda with the agent ID and alias ID env vars set.
4. Expose `bedrock-agent` via API Gateway (POST endpoint accepting `user_text` + `session_id`).
