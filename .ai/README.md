# agent-core-demo – Copilot Coding Assistant Configuration

## Project overview

This repository consists of three cooperating layers:

| Layer | Location | Language/Runtime |
|-------|----------|-----------------|
| React webapp | `webapp/` | TypeScript + React 19 + Vite |
| Python Lambda | `lambda/` | Python 3.12 |
| AWS infra scripts | `infra/` | Bash |

### Data flow

```
Browser (React form)
  └──POST /──► Lambda Function URL
                 └──► Amazon Bedrock AgentCore (invoke_agent)
                        └──► Response streamed back to Lambda
                               └──► JSON response to browser
```

## Coding standards

### TypeScript / React
- Use functional components with hooks.
- Prefer named exports over default exports for components.
- Keep form state local to `RegistrationForm`; avoid global state for now.
- Environment variables must be prefixed with `VITE_` and typed via `import.meta.env`.
- CSS lives in `App.css`; component-scoped styles can be added there under a
  descriptive comment block.

### Python (Lambda)
- Target **Python 3.12**.
- Use type hints throughout.
- Never log or forward the user's `password` field.
- Use `boto3` for all AWS API calls.
- Keep the handler thin: validate → strip password → call `_invoke_agent_core`.
- Unit-testable functions should be pure (no side effects) where possible.

### Bash (infra)
- Always use `set -euo pipefail`.
- Prefer `aws` CLI v2 idiomatic commands.
- Scripts must be idempotent (safe to re-run).

## Environment variables

### webapp (`webapp/.env.local`)
| Variable | Description |
|----------|-------------|
| `VITE_LAMBDA_URL` | Public URL of the Lambda Function URL endpoint |

### Lambda
| Variable | Description |
|----------|-------------|
| `AGENT_CORE_AGENT_ID` | Amazon Bedrock AgentCore agent ID |
| `AGENT_CORE_AGENT_ALIAS_ID` | AgentCore agent alias ID |
| `AWS_REGION` | AWS region (default: `us-east-1`) |
| `ALLOWED_ORIGIN` | Allowed CORS origin (default: `*`) |

## Common tasks

### Start the webapp in dev mode
```bash
cd webapp
cp .env.example .env.local   # then fill in VITE_LAMBDA_URL
npm install
npm run dev
```

### Build the webapp for production
```bash
cd webapp
npm run build
# artefacts in webapp/dist/
```

### Lint the webapp
```bash
cd webapp && npm run lint
```

### Deploy everything to AWS
```bash
chmod +x infra/setup-agentcore.sh
./infra/setup-agentcore.sh
```

### Tear down all AWS resources
```bash
chmod +x infra/teardown-agentcore.sh
./infra/teardown-agentcore.sh
```

## Architecture decisions

- **Lambda Function URL** (no API Gateway): simpler, lower cost, sufficient for
  this demo.  CORS is configured directly on the Function URL.
- **Password never forwarded**: the Lambda strips the password before building
  the AgentCore prompt – passwords are validated locally by the browser's native
  form validation only.
- **Session IDs**: each Lambda invocation generates a fresh UUID v4 session ID so
  that AgentCore conversations remain isolated.
