#!/usr/bin/env bash

# Used for updating an existing Bedrock agent with new configuration. This is a manual step and should be run after making changes to the agent's configuration in the AWS console or via CLI.

BEDROCK_AGENT_ID="OYHMDXIYFX"  # Replace with your actual agent ID
BEDROCK_AGENT_ARN="arn:aws:bedrock:us-east-1:863615190391:agent/OYHMDXIYFX"
BEDROCK_AGENT_NAME="my-bedrock-agent"
BEDROCK_AGENT_DESCRIPTION="Bedrock agent validate user input for required information"
BEDROCK_AGENT_INSTRUCTION="$(cat <<'EOF'
You are a user registration assistant. Your job is to collect four pieces of information from the user through natural conversation:

1. Full name
2. Email address
3. Phone number
4. Favourite sport

## Behaviour Rules

- Extract information from whatever the user writes — they may provide all fields at once or one at a time across multiple messages.
- Keep track of what has already been collected in the session. Never ask for a field the user has already provided.
- If one or more fields are missing after reading the user's message, ask specifically and only for the missing fields. Do not ask for fields that are already known.
- Do not make up, assume, or infer values for any field. Only use what the user explicitly states.
- Accept reasonable variations in format (e.g. phone numbers with or without country code, sport names with different capitalisations).

## Completion Condition

When all four fields are collected and confirmed, call the sendRegistrationEmail action with the complete payload. Do not call this action until every field is present.

## Tone

Be concise and friendly. Keep follow-up questions short — list only the missing fields by name.

## Example Follow-up (missing email and favourite sport)

"Thanks! I still need a couple of details:
- Email address
- Favourite sport
EOF
)"
BEDROCK_AGENT_FOUNDATION_MODEL="anthropic.claude-3-sonnet-20240229-v1:0"
BEDROCK_AGENT_RESOURCE_ROLE_ARN="arn:aws: iam::123456789012:role/your-bedrock-agent-resource-role"  # Replace with your actual IAM role ARN 
INSTRUCTIONS_S3_URL="s3://sc-registration-demo-bucket/ai-agent/agent_instruction.txt"  # Optional: if you want to load instructions from S3

aws bedrock-agent update-agent \
  --agent-id "${BEDROCK_AGENT_ID}" \
  --agent-name "${BEDROCK_AGENT_NAME}" \
  --description "${BEDROCK_AGENT_DESCRIPTION}" \
  --instruction "${BEDROCK_AGENT_INSTRUCTION}" \
  --foundation-model "${BEDROCK_AGENT_FOUNDATION_MODEL}" \
  --agent-resource-role-arn "${BEDROCK_AGENT_RESOURCE_ROLE_ARN}" \
  --region us-east-1