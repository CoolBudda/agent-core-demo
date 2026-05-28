# ------------------------------------------------------------------
# CloudWatch log groups — created before Lambdas so retention is set
# before the first invocation writes logs.
# ------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "bedrock_agent_logs" {
  name              = "/aws/lambda/bedrock-agent-${var.environment}"
  retention_in_days = 30
}

# ------------------------------------------------------------------
# Lambda — Bedrock Agent caller
# Receives user text, invokes the Bedrock Agent runtime (invoke_agent).
# ------------------------------------------------------------------
resource "aws_lambda_function" "bedrock_agent" {
  function_name = "bedrock-agent-${var.environment}"
  description   = "Calls Bedrock Agent runtime with user free-text input. Bedrock Agent handles planning and field extraction."
  role          = aws_iam_role.bedrock_agent_exec.arn

  filename         = var.bedrock_agent_zip_path
  source_code_hash = filebase64sha256(var.bedrock_agent_zip_path)

  runtime     = "python3.10"
  handler     = "lambda_function.lambda_handler"
  timeout     = 60
  memory_size = 256

  environment {
    variables = {
      ENVIRONMENT      = var.environment
      BEDROCK_AGENT_ID   = var.bedrock_agent_id
      BEDROCK_AGENT_ALIAS_ID = "var.bedrock_agent_alias_id
      BEDROCK_AGENT_REGION = var.region
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.bedrock_agent_logs,
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

