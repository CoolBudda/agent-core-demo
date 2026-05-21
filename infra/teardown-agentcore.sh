#!/usr/bin/env bash
# =============================================================================
# teardown-agentcore.sh
#
# Removes all AWS resources created by setup-agentcore.sh:
#   - Lambda function and its Function URL
#   - IAM role and attached policies
#   - Amazon Bedrock AgentCore agent and alias
#
# Usage:
#   chmod +x infra/teardown-agentcore.sh
#   ./infra/teardown-agentcore.sh
# =============================================================================

set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
PROJECT_NAME="agent-core-demo"
LAMBDA_FUNCTION_NAME="${PROJECT_NAME}-handler"
LAMBDA_ROLE_NAME="${PROJECT_NAME}-lambda-role"
AGENT_NAME="${PROJECT_NAME}-agent"

echo "=== agent-core-demo teardown ==="
echo "Region: ${AWS_REGION}"
echo ""

# ─── Lambda ───────────────────────────────────────────────────────────────────
echo "▶  Deleting Lambda function: ${LAMBDA_FUNCTION_NAME}"
aws lambda delete-function \
  --function-name "${LAMBDA_FUNCTION_NAME}" \
  --region "${AWS_REGION}" 2>/dev/null \
  && echo "   Deleted." || echo "   Not found, skipping."

# ─── IAM ──────────────────────────────────────────────────────────────────────
echo "▶  Detaching IAM policies from role: ${LAMBDA_ROLE_NAME}"
for POLICY_ARN in \
  "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" \
  "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"; do
  aws iam detach-role-policy \
    --role-name "${LAMBDA_ROLE_NAME}" \
    --policy-arn "${POLICY_ARN}" 2>/dev/null || true
done

echo "▶  Deleting IAM role: ${LAMBDA_ROLE_NAME}"
aws iam delete-role \
  --role-name "${LAMBDA_ROLE_NAME}" 2>/dev/null \
  && echo "   Deleted." || echo "   Not found, skipping."

# ─── Bedrock Agent ────────────────────────────────────────────────────────────
AGENT_ID=$(aws bedrock-agent list-agents \
  --region "${AWS_REGION}" \
  --query "agentSummaries[?agentName=='${AGENT_NAME}'].agentId | [0]" \
  --output text 2>/dev/null || echo "None")

if [[ "${AGENT_ID}" != "None" && -n "${AGENT_ID}" ]]; then
  echo "▶  Deleting agent aliases for agent: ${AGENT_ID}"
  ALIASES=$(aws bedrock-agent list-agent-aliases \
    --agent-id "${AGENT_ID}" \
    --region "${AWS_REGION}" \
    --query "agentAliasSummaries[].agentAliasId" \
    --output text 2>/dev/null || echo "")

  for ALIAS_ID in ${ALIASES}; do
    aws bedrock-agent delete-agent-alias \
      --agent-id "${AGENT_ID}" \
      --agent-alias-id "${ALIAS_ID}" \
      --region "${AWS_REGION}" 2>/dev/null && echo "   Alias ${ALIAS_ID} deleted."
  done

  echo "▶  Deleting Bedrock agent: ${AGENT_ID}"
  aws bedrock-agent delete-agent \
    --agent-id "${AGENT_ID}" \
    --skip-resource-in-use-check \
    --region "${AWS_REGION}" 2>/dev/null \
    && echo "   Deleted." || echo "   Could not delete agent."
else
  echo "   Bedrock agent not found, skipping."
fi

echo ""
echo "======================================================"
echo "  Teardown complete!"
echo "======================================================"
