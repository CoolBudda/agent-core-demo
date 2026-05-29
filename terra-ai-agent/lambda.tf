# ------------------------------------------------------------------
# CloudWatch log groups — created before Lambdas so retention is set
# before the first invocation writes logs.
# ------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "email_worker_logs" {
  name              = "/aws/lambda/agent-worker-email-${var.environment}"
  retention_in_days = 30
}

# ------------------------------------------------------------------
# Lambda — Agent email worker
# Called by Bedrock Agent as an action group when all fields are present.
# ------------------------------------------------------------------
resource "aws_lambda_function" "email_worker" {
  function_name = "agent-worker-email-${var.environment}"
  description   = "Sends registration confirmation email. Invoked by Bedrock Agent action group when all registration fields are collected."
  role          = aws_iam_role.agent_worker_email_exec.arn

  filename         = var.agent_worker_email_zip_path
  source_code_hash = filebase64sha256(var.agent_worker_email_zip_path)

  runtime     = "python3.10"
  handler     = "lambda_function.lambda_handler"
  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      ENVIRONMENT        = var.environment
      SES_SENDER_EMAIL   = var.ses_sender_email
      BEDROCK_AGENT_REGION = var.region
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.email_worker_logs,
  ]
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
