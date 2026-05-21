# agent-core-demo
web-lambda-agentcore form validation

## Overview

A full-stack demo that wires a **React TypeScript webapp** → **AWS Lambda** → **Amazon Bedrock AgentCore** together.  A user fills in a simple registration form (username, password, phone, favourite sport) and the backend agent validates and enriches the data.

```
Browser (React form)
  └──POST──► Lambda Function URL (Python 3.12)
               └──► Amazon Bedrock AgentCore
                      └──► AI-powered validation response
```

## Repository layout

```
.
├── webapp/          # React 19 + TypeScript + Vite frontend
├── lambda/          # Python Lambda handler
│   ├── handler.py
│   └── requirements.txt
├── infra/           # Bash scripts to provision / tear down AWS resources
│   ├── setup-agentcore.sh
│   └── teardown-agentcore.sh
├── .ai/             # Copilot coding-assistant configuration
└── README.md
```

## Quick start

### 1. Provision AWS infrastructure

```bash
# Configure your AWS credentials first
aws configure

# Run the setup script (creates IAM role, Lambda, Bedrock agent)
chmod +x infra/setup-agentcore.sh
./infra/setup-agentcore.sh
```

The script prints a **Lambda URL** at the end – copy it for the next step.

### 2. Start the webapp

```bash
cd webapp
cp .env.example .env.local
# Edit .env.local and set VITE_LAMBDA_URL to the Lambda URL from step 1

npm install
npm run dev
```

Open [http://localhost:5173](http://localhost:5173) and fill in the form.

### 3. Tear down

```bash
chmod +x infra/teardown-agentcore.sh
./infra/teardown-agentcore.sh
```

## Components

### React webapp (`webapp/`)

| Tech | Version |
|------|---------|
| React | 19 |
| TypeScript | ~6 |
| Vite | 8 |

The form collects `user`, `password`, `phone`, and `sport`, then POSTs JSON to the Lambda Function URL.

### Python Lambda (`lambda/`)

- Validates that all four fields are present.
- Strips the `password` before building the AgentCore prompt (passwords are never forwarded to the AI).
- Calls `bedrock-agent-runtime.invoke_agent` and streams the response back to the client.

### AWS infrastructure (`infra/`)

`setup-agentcore.sh` provisions:
1. IAM execution role for Lambda
2. Lambda function with a public Function URL
3. Amazon Bedrock AgentCore agent (Claude 3 Sonnet)
4. Agent alias (`live`)

### Copilot assistant (`.ai/`)

See [`.ai/README.md`](.ai/README.md) for coding standards, environment-variable reference, and common tasks used by the GitHub Copilot coding assistant.

## Environment variables

### webapp (`.env.local`)

| Variable | Description |
|----------|-------------|
| `VITE_LAMBDA_URL` | Public Lambda Function URL |

### Lambda

| Variable | Description |
|----------|-------------|
| `AGENT_CORE_AGENT_ID` | Bedrock AgentCore agent ID |
| `AGENT_CORE_AGENT_ALIAS_ID` | Agent alias ID |
| `AWS_REGION` | AWS region (default `us-east-1`) |
| `ALLOWED_ORIGIN` | CORS origin (default `*`) |
