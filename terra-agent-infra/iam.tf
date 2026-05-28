# ------------------------------------------------------------------
# Lambda execution role — least-privilege
# Permissions: CloudWatch Logs only (add more as needed)
# ------------------------------------------------------------------
resource "aws_iam_role" "lambda_exec" {
  name = "agent-lambda-exec-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_logs" {
  name        = "agent-lambda-logs-${var.environment}"
  description = "Allow Lambda to write execution logs to its own log group."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}
# ------------------------------------------------------------------
# Bedrock Agent Lambda execution role — least-privilege
# Permissions: CloudWatch Logs only (add more as needed)
# ------------------------------------------------------------------
resource "aws_iam_role" "bedrock_agent_exec" {
  name = "bedrock-agent-exec-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "bedrock_agent_logs" {
  name        = "bedrock-agent-logs-${var.environment}"
  description = "Allow bedrock-agent Lambda to write execution logs to its own log group."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowLogGroupCreation"
        Effect = "Allow"
        Action = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Sid    = "AllowLogStreamAndEvents"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/bedrock-agent-${var.environment}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bedrock_agent_logs" {
  role       = aws_iam_role.bedrock_agent_exec.name
  policy_arn = aws_iam_policy.bedrock_agent_logs.arn
}

resource "aws_iam_policy" "bedrock_agent_invoke_agent" {
  name        = "bedrock-agent-invoke-agent-${var.environment}"
  description = "Allow Lambda to invoke Bedrock Agent via agent alias"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = "bedrock:InvokeAgent"
        Resource = "*"
        # Resource = "arn:aws:bedrock:us-east-1:863615190391:agent-alias/WBKYJIUJU0/E3ALIVTWCU"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bedrock_agent_invoke_agent" {
  role       = aws_iam_role.bedrock_agent_exec.name
  policy_arn = aws_iam_policy.bedrock_agent_invoke_agent.arn
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {
  name  = "us-east-1"
}


# ------------------------------------------------------------------
# API Gateway CloudWatch logging role
# Required once per account/region. AWS mandates a specific role ARN
# be set at the account level (aws_api_gateway_account resource).
# Uses the AWS-managed policy as required by AWS.
# ------------------------------------------------------------------
resource "aws_iam_role" "api_gateway_cloudwatch" {
  name = "agent-apigw-cloudwatch-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "apigateway.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# AWS-managed policy required for API Gateway -> CloudWatch logging
resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch" {
  role       = aws_iam_role.api_gateway_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Register the logging role at the account level
resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}


# Bedrock InvokeAgent — scoped to the three specific agent ARNs
resource "aws_iam_policy" "lambda_bedrock" {
  name        = "agent-lambda-bedrock-${var.environment}"
  description = "Allow Lambda to invoke only the three Bedrock agents for this project."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InvokeBedrockAgents"
        Effect = "Allow"
        Action = "bedrock:InvokeAgent"
        Resource = [
          "arn:aws:bedrock:us-east-1:${data.aws_caller_identity.current.account_id}:agent-alias/${var.bedrock_agent_id}/${var.bedrock_agent_alias_id}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_iam_role_policy_attachment" "lambda_bedrock" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_bedrock.arn
}


