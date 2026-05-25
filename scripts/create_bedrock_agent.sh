#!/usr/bin/env bash
# =============================================================================
# create_bedrock_agent.sh
#
# Creates an AWS Bedrock Agent for the user registration app and wires up the
# agentcore-worker-email action group.
#
# Designed to run in AWS CloudShell — no local repo clone required.
# AWS credentials are provided automatically by CloudShell.
#
# How to run in CloudShell:
#   1. Open AWS CloudShell (us-east-1).
#   2. Upload this file: Actions > Upload file.
#   3. Set required variables:
#        export AGENT_ROLE_ARN="arn:aws:iam::123456789012:role/BedrockAgentRole"
#        export EMAIL_WORKER_LAMBDA_ARN="arn:aws:lambda:us-east-1:123456789012:function:agentcore-worker-email-dev"
#        export SCHEMA_S3_BUCKET="my-agent-assets-bucket"
#   4. Run:
#        chmod +x create_bedrock_agent.sh && ./create_bedrock_agent.sh
#
# IAM permissions required on the CloudShell role:
#   bedrock:CreateAgent, bedrock:CreateAgentActionGroup,
#   bedrock:PrepareAgent, bedrock:GetAgent, bedrock:CreateAgentAlias,
#   s3:PutObject, iam:PassRole
#
# Environment variables (override defaults):
#   REGION                  AWS region (default: us-east-1)
#   AGENT_NAME              Bedrock Agent name
#   FOUNDATION_MODEL        Model ID to use
#   AGENT_ROLE_ARN          IAM role ARN Bedrock assumes to run the agent  [REQUIRED]
#   EMAIL_WORKER_LAMBDA_ARN Lambda ARN for agentcore-worker-email           [REQUIRED]
#   SCHEMA_S3_BUCKET        S3 bucket where openapi.json will be uploaded  [REQUIRED]
#   SCHEMA_S3_KEY           S3 key for the uploaded schema
#   ALIAS_NAME              Alias name to publish after preparation
# =============================================================================

set -euo pipefail

SCHEMA_S3_BUCKET="sc-registration-demo-bucket"
AGENT_ROLE_ARN="arn:aws:iam::123456789012:role/BedrockAgentRole"
EMAIL_WORKER_LAMBDA_ARN="arn:aws:lambda:us-east-1:123456789012:function:agentcore-worker-email-dev"

# ---------------------------------------------------------------------------
# Configuration — override via environment variables or edit defaults below
# ---------------------------------------------------------------------------
REGION="${REGION:-us-east-1}"
AGENT_NAME="${AGENT_NAME:-registration-assistant}"
FOUNDATION_MODEL="${FOUNDATION_MODEL:-anthropic.claude-3-5-sonnet-20241022-v2:0}"
AGENT_ROLE_ARN="${AGENT_ROLE_ARN:-}"
EMAIL_WORKER_LAMBDA_ARN="${EMAIL_WORKER_LAMBDA_ARN:-}"
SCHEMA_S3_BUCKET="${SCHEMA_S3_BUCKET:-}"
SCHEMA_S3_KEY="${SCHEMA_S3_KEY:-schemas/agentcore-worker-email/openapi.json}"
ALIAS_NAME="${ALIAS_NAME:-prod}"

# ---------------------------------------------------------------------------
# Validate required inputs
# ---------------------------------------------------------------------------
if [[ -z "${AGENT_ROLE_ARN}" ]]; then
  echo "ERROR: AGENT_ROLE_ARN is required. Set it as an environment variable." >&2
  exit 1
fi
if [[ -z "${EMAIL_WORKER_LAMBDA_ARN}" ]]; then
  echo "ERROR: EMAIL_WORKER_LAMBDA_ARN is required. Set it as an environment variable." >&2
  exit 1
fi
if [[ -z "${SCHEMA_S3_BUCKET}" ]]; then
  echo "ERROR: SCHEMA_S3_BUCKET is required. Set it as an environment variable." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Inline agent instruction — no local file dependency for CloudShell
# ---------------------------------------------------------------------------
INSTRUCTION="You are a user registration assistant. Your job is to collect four pieces of information from the user through natural conversation:

1. Full name
2. Email address
3. Phone number
4. Favourite sport

Behaviour Rules:
- Extract information from whatever the user writes — they may provide all fields at once or one at a time across multiple messages.
- Keep track of what has already been collected in the session. Never ask for a field the user has already provided.
- If one or more fields are missing after reading the user's message, ask specifically and only for the missing fields.
- Do not make up, assume, or infer values for any field. Only use what the user explicitly states.

Completion Condition:
When all four fields are collected, call the sendRegistrationEmail action with the complete payload. Do not call this action until every field is present.

Tone: Be concise and friendly. Keep follow-up questions short."

# ---------------------------------------------------------------------------
# Inline OpenAPI schema — written to a temp file for S3 upload
# ---------------------------------------------------------------------------
TMPDIR_WORK=$(mktemp -d)
OPENAPI_FILE="${TMPDIR_WORK}/openapi.json"
trap 'rm -rf "${TMPDIR_WORK}"' EXIT

cat > "${OPENAPI_FILE}" << 'EOF'
{
  "openapi": "3.0.0",
  "info": {
    "title": "Registration Email Worker",
    "description": "Action group schema for the AgentCore email worker.",
    "version": "1.0.0"
  },
  "paths": {
    "/send_registration_email": {
      "post": {
        "operationId": "sendRegistrationEmail",
        "description": "Sends a registration confirmation email. Call only when name, email, phone, and favorite_sport are all present.",
        "requestBody": {
          "required": true,
          "content": {
            "application/json": {
              "schema": {
                "type": "object",
                "required": ["name", "email", "phone", "favorite_sport"],
                "properties": {
                  "name":           { "type": "string", "description": "Full name of the registrant." },
                  "email":          { "type": "string", "format": "email", "description": "Email address." },
                  "phone":          { "type": "string", "description": "Phone number." },
                  "favorite_sport": { "type": "string", "description": "Favourite sport." }
                }
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "Email sent successfully.",
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "status":    { "type": "string", "example": "email_sent" },
                    "recipient": { "type": "string", "example": "alice@example.com" }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
EOF

# ---------------------------------------------------------------------------
# Step 1: Upload OpenAPI schema to S3 (using inline temp file)
# ---------------------------------------------------------------------------
echo ">>> Uploading OpenAPI schema to s3://${SCHEMA_S3_BUCKET}/${SCHEMA_S3_KEY} ..."
aws s3 cp "${OPENAPI_FILE}" "s3://${SCHEMA_S3_BUCKET}/${SCHEMA_S3_KEY}" \
  --region "${REGION}"

# ---------------------------------------------------------------------------
# Step 2: Create the Bedrock Agent
# ---------------------------------------------------------------------------
echo ">>> Creating Bedrock Agent '${AGENT_NAME}' ..."
CREATE_RESPONSE=$(aws bedrock-agent create-agent \
  --agent-name "${AGENT_NAME}" \
  --foundation-model "${FOUNDATION_MODEL}" \
  --agent-resource-role-arn "${AGENT_ROLE_ARN}" \
  --instruction "${INSTRUCTION}" \
  --region "${REGION}" \
  --output json)

AGENT_ID=$(echo "${CREATE_RESPONSE}" | python3 -c "import sys,json; print(json.load(sys.stdin)['agent']['agentId'])")
echo "    Agent ID: ${AGENT_ID}"

# ---------------------------------------------------------------------------
# Step 3: Create the action group (email worker)
# ---------------------------------------------------------------------------
echo ">>> Creating action group 'SendRegistrationEmail' ..."
aws bedrock-agent create-agent-action-group \
  --agent-id "${AGENT_ID}" \
  --agent-version "DRAFT" \
  --action-group-name "SendRegistrationEmail" \
  --description "Sends a registration confirmation email when all fields are collected." \
  --action-group-executor '{"lambda": "'"${EMAIL_WORKER_LAMBDA_ARN}"'"}' \
  --api-schema '{"s3": {"s3BucketName": "'"${SCHEMA_S3_BUCKET}"'", "s3ObjectKey": "'"${SCHEMA_S3_KEY}"'"}}' \
  --region "${REGION}" \
  --output json > /dev/null

echo "    Action group created."

# ---------------------------------------------------------------------------
# Step 4: Prepare (compile) the agent
# ---------------------------------------------------------------------------
echo ">>> Preparing agent (compiling DRAFT version) ..."
aws bedrock-agent prepare-agent \
  --agent-id "${AGENT_ID}" \
  --region "${REGION}" \
  --output json > /dev/null

# Poll until the agent status is PREPARED
echo -n "    Waiting for agent to reach PREPARED status ..."
for i in $(seq 1 30); do
  AGENT_STATUS=$(aws bedrock-agent get-agent \
    --agent-id "${AGENT_ID}" \
    --region "${REGION}" \
    --query "agent.agentStatus" \
    --output text)
  if [[ "${AGENT_STATUS}" == "PREPARED" ]]; then
    echo " done."
    break
  fi
  echo -n "."
  sleep 5
done

if [[ "${AGENT_STATUS}" != "PREPARED" ]]; then
  echo ""
  echo "ERROR: Agent did not reach PREPARED status (current: ${AGENT_STATUS})." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Step 5: Create an alias pointing to the DRAFT version
# ---------------------------------------------------------------------------
echo ">>> Creating alias '${ALIAS_NAME}' ..."
ALIAS_RESPONSE=$(aws bedrock-agent create-agent-alias \
  --agent-id "${AGENT_ID}" \
  --agent-alias-name "${ALIAS_NAME}" \
  --region "${REGION}" \
  --output json)

ALIAS_ID=$(echo "${ALIAS_RESPONSE}" | python3 -c "import sys,json; print(json.load(sys.stdin)['agentAlias']['agentAliasId'])")

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "================================================================="
echo "Bedrock Agent created successfully."
echo "  Agent ID  : ${AGENT_ID}"
echo "  Alias ID  : ${ALIAS_ID}"
echo "  Alias name: ${ALIAS_NAME}"
echo "  Region    : ${REGION}"
echo ""
echo "Set these in your bedrock-agent Lambda environment variables:"
echo "  BEDROCK_AGENT_ID=${AGENT_ID}"
echo "  BEDROCK_AGENT_ALIAS_ID=${ALIAS_ID}"
echo "================================================================="
