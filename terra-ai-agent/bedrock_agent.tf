# Bedrock Agent resource provisioning
# This file provisions a Bedrock Agent using the awscc_bedrock_agent resource (AWS Cloud Control provider)

resource "awscc_bedrock_agent" "this" {
  agent_name  = var.bedrock_agent_name
  description = var.bedrock_agent_description
  foundation_model = var.bedrock_agent_foundation_model
  instruction = var.bedrock_agent_instruction
  agent_resource_role_arn   = aws_iam_role.bedrock_agent_resource_role.arn
  action_groups = [
    {
      action_group_name   = "sendRegistrationEmail"
      lambda_function_arn = aws_lambda_function.email_worker.arn
      description         = "Send registration confirmation email"
    }
  ]
}
