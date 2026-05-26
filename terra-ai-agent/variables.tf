variable "bedrock_agent_alias_name" {
  description = "Name of the Bedrock agent alias."
  type        = string
  default     = "demo"
}

variable "bedrock_agent_alias_description" {
  description = "Description for the Bedrock agent alias."
  type        = string
  default     = "Production alias for Bedrock agent."
}
variable "bedrock_agent_instruction_s3_uri" {
  description = "S3 URI for the Bedrock agent instruction file."
  type        = string
  default     = "s3://sc-registration-demo-bucket/ai-agent/agent_instruction.txt"
}
variable "bedrock_agent_name" {
  description = "Name of the Bedrock agent."
  type        = string
  default     = "user-registration-validation-agent"
}

variable "bedrock_agent_description" {
  description = "Description for the Bedrock agent."
  type        = string
  default     = "user-registration-validation-agent demo"
}

variable "bedrock_agent_foundation_model" {
  description = "Foundation model for the Bedrock agent (e.g., anthropic.claude-3-sonnet-20240229-v1:0)."
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "bedrock_agent_instruction" {
  description = "Instruction text for the Bedrock agent."
  type        = string
  default     = <<EOT
You are a user registration assistant. Your job is to collect four pieces of information from the user through natural conversation:

1. Full name
2. Email address
3. Phone number
4. Favourite sport

## Behaviour Rules

- Extract information from whatever the user writes — they may provide all fields at once or one at a time across multiple messages.
- Keep track of what has already been collected in the session. Never ask for a field the user has already provided.
- If one or more fields are missing after reading the user's message, ask specifically and only for the missing fields. Do not ask for fields that are already known.
- Do not make up, assume, or infer values for any field. Only use what the user explicitly states.
- Accept reasonable variations in format (e.g. phone numbers with or without country code, sport names with different capitalisations).

## Completion Condition

When all four fields are collected and confirmed, call the sendRegistrationEmail action with the complete payload. Do not call this action until every field is present.

## Tone

Be concise and friendly. Keep follow-up questions short — list only the missing fields by name.

## Example Follow-up (missing email and favourite sport)

"Thanks! I still need a couple of details:
- Email address
- Favourite sport
EOT
}

variable "bedrock_agent_resource_role_arn" {
  description = "IAM role ARN for the Bedrock agent resource."
  type        = string
}

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
  default     = ""
}
