

# Bedrock Agent resource provisioning
# This file provisions a Bedrock Agent using the awscc_bedrock_agent resource (AWS Cloud Control provider)

resource "awscc_bedrock_agent" "this" {
	agent_name  = var.bedrock_agent_name
	description = var.bedrock_agent_description
	foundation_model = var.bedrock_agent_foundation_model
	instruction = var.bedrock_agent_instruction
	agent_resource_role_arn   = aws_iam_role.bedrock_agent_resource_role.arn
	action_groups = [{
		action_group_name = "sendRegistrationEmail"
		description       = "Send registration confirmation email"
		api_schema = {
			s3 = {
				s3_bucket_name = "sc-registration-demo-bucket"
				s3_object_key  = "ai-agent/openAPI.spec.yml"
			}
		}
		action_group_executor = {
			lambda = aws_lambda_function.email_worker.arn
		}
	}]
}
