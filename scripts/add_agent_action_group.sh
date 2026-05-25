#!/usr/bin/env sh


aws bedrock-agent create-action-group \
  --agent-id YOUR_AGENT_ID \
  --action-group-name "sendRegistrationEmail" \
  --action-group-execution-role-arn arn:aws:iam::123456789012:role/your-lambda-exec-role \
  --lambda-function-arn arn:aws:lambda:us-east-1:123456789012:function:your-lambda-function \
  --region us-east-1


# aws bedrock-agent create-action-group \
#   --agent-id YOUR_AGENT_ID \
#   --action-group-name "my-openapi-action" \
#   --action-group-execution-role-arn arn:aws:iam::123456789012:role/your-exec-role \
#   --openapi-spec-s3-location s3://your-bucket/path/openapi.json \
#   --region us-east-1  