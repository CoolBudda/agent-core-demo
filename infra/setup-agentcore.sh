#!/usr/bin/env bash
# =============================================================================
# setup-agentcore.sh
#
# Provisions all AWS resources needed for the agent-core-demo project:
#   1. IAM role for the Lambda function
#   2. Lambda function (with Function URL)
#   3. Amazon Bedrock AgentCore agent
#   4. Agent alias
#
# Prerequisites:
#   - AWS CLI v2 installed and configured (aws configure)
#   - Permissions: IAM, Lambda, Bedrock, S3 (for Lambda package)
#
# Usage:
#   chmod +x infra/setup-agentcore.sh
#   ./infra/setup-agentcore.sh
#
# Customise the variables in the CONFIG section below before running.
# =============================================================================

set -euo pipefail

# ── CONFIG ──────────────────────────────────────────────────────────────────
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

PROJECT_NAME="agent-core-demo"
LAMBDA_FUNCTION_NAME="${PROJECT_NAME}-handler"
LAMBDA_ROLE_NAME="${PROJECT_NAME}-lambda-role"
LAMBDA_RUNTIME="python3.12"
LAMBDA_HANDLER="handler.handler"
LAMBDA_TIMEOUT=30        # seconds
LAMBDA_MEMORY=256        # MB

AGENT_NAME="${PROJECT_NAME}-agent"
AGENT_DESCRIPTION="Validates and processes user registration data submitted via the React webapp."
# Foundation model used by the AgentCore agent
FOUNDATION_MODEL="anthropic.claude-3-sonnet-20240229-v1:0"

# Instruction given to the agent
AGENT_INSTRUCTION="You are a helpful registration assistant. \
When given user registration details (username, phone number, and favourite sport), \
validate the information for correctness and provide friendly, concise feedback. \
Flag any obvious issues (e.g. invalid phone format) and confirm what looks good."

LAMBDA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../lambda" && pwd)"
# ── END CONFIG ───────────────────────────────────────────────────────────────

echo "=== agent-core-demo AWS setup ==="
echo "Region  : ${AWS_REGION}"
echo "Account : ${AWS_ACCOUNT_ID}"
echo ""

# ─── 1. IAM role ─────────────────────────────────────────────────────────────
echo "▶  Creating IAM role: ${LAMBDA_ROLE_NAME}"

TRUST_POLICY=$(cat <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "lambda.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
EOF
)

ROLE_ARN=$(aws iam create-role \
  --role-name "${LAMBDA_ROLE_NAME}" \
  --assume-role-policy-document "${TRUST_POLICY}" \
  --query "Role.Arn" --output text 2>/dev/null \
  || aws iam get-role --role-name "${LAMBDA_ROLE_NAME}" \
       --query "Role.Arn" --output text)

# Attach managed policies
aws iam attach-role-policy \
  --role-name "${LAMBDA_ROLE_NAME}" \
  --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

aws iam attach-role-policy \
  --role-name "${LAMBDA_ROLE_NAME}" \
  --policy-arn "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"

echo "   Role ARN: ${ROLE_ARN}"

# Give IAM a moment to propagate
sleep 10

# ─── 2. Lambda package ───────────────────────────────────────────────────────
echo "▶  Packaging Lambda function"

TMP_ZIP="/tmp/${PROJECT_NAME}-lambda.zip"
cd "${LAMBDA_DIR}"

# Install dependencies into a local package directory
pip install -q -r requirements.txt -t ./package

cp handler.py ./package/
(cd ./package && zip -qr "${TMP_ZIP}" .)
rm -rf ./package

echo "   Package: ${TMP_ZIP}"

# ─── 3. Lambda function ──────────────────────────────────────────────────────
echo "▶  Deploying Lambda function: ${LAMBDA_FUNCTION_NAME}"

if aws lambda get-function --function-name "${LAMBDA_FUNCTION_NAME}" \
     --region "${AWS_REGION}" &>/dev/null; then
  # Update existing function
  aws lambda update-function-code \
    --function-name "${LAMBDA_FUNCTION_NAME}" \
    --zip-file "fileb://${TMP_ZIP}" \
    --region "${AWS_REGION}" \
    --output table
else
  # Create new function (env vars are filled in after AgentCore is ready)
  aws lambda create-function \
    --function-name "${LAMBDA_FUNCTION_NAME}" \
    --runtime "${LAMBDA_RUNTIME}" \
    --role "${ROLE_ARN}" \
    --handler "${LAMBDA_HANDLER}" \
    --timeout "${LAMBDA_TIMEOUT}" \
    --memory-size "${LAMBDA_MEMORY}" \
    --zip-file "fileb://${TMP_ZIP}" \
    --region "${AWS_REGION}" \
    --output table
fi

# Enable Function URL (no auth – public endpoint for the webapp)
echo "▶  Adding Lambda Function URL"
LAMBDA_URL=$(aws lambda create-function-url-config \
  --function-name "${LAMBDA_FUNCTION_NAME}" \
  --auth-type NONE \
  --cors '{"AllowOrigins":["*"],"AllowMethods":["POST","OPTIONS"],"AllowHeaders":["Content-Type"]}' \
  --region "${AWS_REGION}" \
  --query "FunctionUrl" --output text 2>/dev/null \
  || aws lambda get-function-url-config \
       --function-name "${LAMBDA_FUNCTION_NAME}" \
       --region "${AWS_REGION}" \
       --query "FunctionUrl" --output text)

# Allow public (unauthenticated) invocations
aws lambda add-permission \
  --function-name "${LAMBDA_FUNCTION_NAME}" \
  --statement-id "FunctionURLAllowPublicAccess" \
  --action "lambda:InvokeFunctionUrl" \
  --principal "*" \
  --function-url-auth-type NONE \
  --region "${AWS_REGION}" 2>/dev/null || true

echo "   Lambda URL: ${LAMBDA_URL}"

# ─── 4. Bedrock AgentCore agent ───────────────────────────────────────────────
echo "▶  Creating Bedrock AgentCore agent: ${AGENT_NAME}"

AGENT_ID=$(aws bedrock-agent create-agent \
  --agent-name "${AGENT_NAME}" \
  --description "${AGENT_DESCRIPTION}" \
  --foundation-model "${FOUNDATION_MODEL}" \
  --instruction "${AGENT_INSTRUCTION}" \
  --agent-resource-role-arn "${ROLE_ARN}" \
  --region "${AWS_REGION}" \
  --query "agent.agentId" --output text 2>/dev/null \
  || aws bedrock-agent list-agents \
       --region "${AWS_REGION}" \
       --query "agentSummaries[?agentName=='${AGENT_NAME}'].agentId | [0]" \
       --output text)

echo "   Agent ID: ${AGENT_ID}"

# Prepare agent (compile & deploy)
echo "▶  Preparing agent (this may take a moment)"
aws bedrock-agent prepare-agent \
  --agent-id "${AGENT_ID}" \
  --region "${AWS_REGION}" \
  --output table

# ─── 5. Agent alias ───────────────────────────────────────────────────────────
echo "▶  Creating agent alias: live"

AGENT_ALIAS_ID=$(aws bedrock-agent create-agent-alias \
  --agent-id "${AGENT_ID}" \
  --agent-alias-name "live" \
  --region "${AWS_REGION}" \
  --query "agentAlias.agentAliasId" --output text 2>/dev/null \
  || aws bedrock-agent list-agent-aliases \
       --agent-id "${AGENT_ID}" \
       --region "${AWS_REGION}" \
       --query "agentAliasSummaries[?agentAliasName=='live'].agentAliasId | [0]" \
       --output text)

echo "   Agent Alias ID: ${AGENT_ALIAS_ID}"

# ─── 6. Update Lambda environment variables ──────────────────────────────────
echo "▶  Updating Lambda environment variables"

aws lambda update-function-configuration \
  --function-name "${LAMBDA_FUNCTION_NAME}" \
  --environment "Variables={
    AGENT_CORE_AGENT_ID=${AGENT_ID},
    AGENT_CORE_AGENT_ALIAS_ID=${AGENT_ALIAS_ID},
    AWS_REGION=${AWS_REGION}
  }" \
  --region "${AWS_REGION}" \
  --output table

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "======================================================"
echo "  Setup complete!"
echo "======================================================"
echo ""
echo "  Lambda URL       : ${LAMBDA_URL}"
echo "  Agent ID         : ${AGENT_ID}"
echo "  Agent Alias ID   : ${AGENT_ALIAS_ID}"
echo ""
echo "  ➜  Copy the Lambda URL into webapp/.env.local:"
echo "     VITE_LAMBDA_URL=${LAMBDA_URL}"
echo "======================================================"
