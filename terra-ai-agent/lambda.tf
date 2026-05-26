# ------------------------------------------------------------------
# CloudWatch log groups — created before Lambdas so retention is set
# before the first invocation writes logs.
# ------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "bedrock_agent_logs" {
  name              = "/aws/lambda/bedrock-agent-${var.environment}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "email_worker_logs" {
  name              = "/aws/lambda/agentcore-worker-email-${var.environment}"
  retention_in_days = 30
}

# ------------------------------------------------------------------
# Lambda — Bedrock Agent caller
# Receives user text, invokes the Bedrock Agent runtime (invoke_agent).
# ------------------------------------------------------------------
resource "aws_lambda_function" "bedrock_agent" {
  function_name = "bedrock-agent-${var.environment}"
  description   = "Calls Bedrock Agent runtime with user free-text input. Bedrock Agent handles planning and field extraction."
  role          = aws_iam_role.lambda_exec.arn

  filename         = var.bedrock_agent_zip_path
  source_code_hash = filebase64sha256(var.bedrock_agent_zip_path)

  runtime     = "python3.10"
  handler     = "lambda_function.handler"
  timeout     = 60
  memory_size = 256

  environment {
    variables = {
      ENVIRONMENT      = var.environment
      BEDROCK_AGENT_ID = awscc_bedrock_agent.this.id
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy_attachment.lambda_bedrock,
    aws_cloudwatch_log_group.bedrock_agent_logs,
  ]
}

# ------------------------------------------------------------------
# Lambda — AgentCore email worker
# Called by Bedrock Agent as an action group when all fields are present.
# ------------------------------------------------------------------
resource "aws_lambda_function" "email_worker" {
  function_name = "agentcore-worker-email-${var.environment}"
  description   = "Sends registration confirmation email. Invoked by Bedrock Agent action group when all registration fields are collected."
  role          = aws_iam_role.lambda_exec.arn

  filename         = var.email_worker_zip_path
  source_code_hash = filebase64sha256(var.email_worker_zip_path)

  runtime     = "python3.10"
  handler     = "lambda_function.handler"
  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      ENVIRONMENT        = var.environment
      SES_SENDER_EMAIL   = var.ses_sender_email
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.email_worker_logs,
  ]
}

# ------------------------------------------------------------------
# Lambda permission — allow API Gateway to invoke bedrock-agent.
# Scoped to the exact API Gateway ARN (not a wildcard).
# ------------------------------------------------------------------
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bedrock_agent.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/${var.environment}/POST/submit"
}

# ------------------------------------------------------------------
# Lambda permission — allow Bedrock Agent to invoke email worker
# as an action group.
# ------------------------------------------------------------------
resource "aws_lambda_permission" "bedrock_agent_invoke_email_worker" {
  statement_id  = "AllowBedrockAgentInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_worker.function_name
  principal     = "bedrock.amazonaws.com"
}
