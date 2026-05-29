# Data sources for region and account ID
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------
# Agent Email Worker Lambda execution role — least-privilege
# Permissions: CloudWatch Logs only (add more as needed)
# ------------------------------------------------------------------
resource "aws_iam_role" "agent_worker_email_exec" {
  name = "agent-worker-email-exec-${var.environment}"

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

resource "aws_iam_policy" "agent_worker_email_logs" {
  name        = "agent-worker-email-logs-${var.environment}"
  description = "Allow agent-worker-email Lambda to write execution logs to its own log group."

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
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/agent-worker-email-${var.environment}:*"
      },
      {
        "Effect": "Allow",
        "Action": "ses:SendEmail",
        "Resource": "arn:aws:ses:us-east-1:863615190391:identity/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "agent_worker_email_logs" {
  role       = aws_iam_role.agent_worker_email_exec.name
  policy_arn = aws_iam_policy.agent_worker_email_logs.arn
}
# ------------------------------------------------------------------
# Bedrock Agent resource role — least-privilege
# Allows Bedrock Agent to access required AWS services (customize as needed)
# ------------------------------------------------------------------
resource "aws_iam_role" "bedrock_agent_resource_role" {
  name = "bedrock-agent-resource-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "bedrock.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Example policy attachment: allow S3 read (for instruction file), CloudWatch logs, etc.
resource "aws_iam_policy" "bedrock_agent_basic" {
  name        = "bedrock-agent-basic-${var.environment}"
  description = "Basic permissions for Bedrock agent (S3 read, logs)."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bedrock_agent_basic" {
  role       = aws_iam_role.bedrock_agent_resource_role.name
  policy_arn = aws_iam_policy.bedrock_agent_basic.arn
}
