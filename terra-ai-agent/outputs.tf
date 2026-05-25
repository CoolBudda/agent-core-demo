output "api_gateway_invoke_url" {
  description = "Base URL for the deployed API Gateway stage. Use this as the frontend API endpoint."
  value       = "${aws_api_gateway_stage.this.invoke_url}/submit"
}

output "bedrock_agent_function_name" {
  description = "Name of the bedrock-agent Lambda (API Gateway entry point)."
  value       = aws_lambda_function.bedrock_agent.function_name
}

output "bedrock_agent_function_arn" {
  description = "ARN of the bedrock-agent Lambda."
  value       = aws_lambda_function.bedrock_agent.arn
}

output "email_worker_function_name" {
  description = "Name of the agentcore-worker-email Lambda (Bedrock Agent action group target)."
  value       = aws_lambda_function.email_worker.function_name
}

output "email_worker_function_arn" {
  description = "ARN of the agentcore-worker-email Lambda. Use this when configuring the Bedrock Agent action group."
  value       = aws_lambda_function.email_worker.arn
}

output "api_gateway_rest_api_id" {
  description = "REST API ID of the API Gateway (useful for further config or testing)."
  value       = aws_api_gateway_rest_api.this.id
}

output "cloudwatch_log_group_bedrock_agent" {
  description = "CloudWatch log group for the bedrock-agent Lambda."
  value       = aws_cloudwatch_log_group.bedrock_agent_logs.name
}

output "cloudwatch_log_group_email_worker" {
  description = "CloudWatch log group for the agentcore-worker-email Lambda."
  value       = aws_cloudwatch_log_group.email_worker_logs.name
}

output "cloudwatch_log_group_api_gateway" {
  description = "CloudWatch log group for API Gateway execution logs."
  value       = aws_cloudwatch_log_group.api_gateway_logs.name
}
