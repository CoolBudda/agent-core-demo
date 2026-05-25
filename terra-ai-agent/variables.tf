variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "bedrock_agent_zip_path" {
  description = "Local path to the bedrock-agent Lambda deployment package (.zip). Build with pip before applying."
  type        = string
  default     = "../multi-agent-registration-app/bedrock-agent/dist/bedrock_agent.zip"
}

variable "email_worker_zip_path" {
  description = "Local path to the agentcore-worker-email Lambda deployment package (.zip). Build with pip before applying."
  type        = string
  default     = "../multi-agent-registration-app/agentcore-worker-email/dist/agentcore_worker_email.zip"
}

# ------------------------------------------------------------------
# Bedrock AgentCore — IDs are created outside Terraform (AWS Console
# or separate Bedrock deployment). Supply them via tfvars or env vars.
# ------------------------------------------------------------------
variable "bedrock_validator_agent_id" {
  description = "Bedrock AgentCore agent ID for the Validator agent."
  type        = string
  default     = "OYHMDXIYFX"
}

variable "bedrock_validator_agent_alias_id" {
  description = "Bedrock AgentCore agent alias ID for the Validator agent."
  type        = string
}

variable "bedrock_error_handler_agent_id" {
  description = "Bedrock AgentCore agent ID for the Error Handler agent."
  type        = string
}

variable "bedrock_error_handler_agent_alias_id" {
  description = "Bedrock AgentCore agent alias ID for the Error Handler agent."
  type        = string
}

variable "bedrock_handoff_agent_id" {
  description = "Bedrock AgentCore agent ID for the Human Handoff agent."
  type        = string
}

variable "bedrock_handoff_agent_alias_id" {
  description = "Bedrock AgentCore agent alias ID for the Human Handoff agent."
  type        = string
}

variable "api_gateway_throttle_burst" {
  description = "API Gateway stage default burst limit (requests/sec)."
  type        = number
  default     = 50
}

variable "api_gateway_throttle_rate" {
  description = "API Gateway stage default rate limit (requests/sec, steady-state)."
  type        = number
  default     = 100
}

variable "ses_sender_email" {
  description = "Verified SES sender email address used by the agentcore-worker-email Lambda."
  type        = string
}
