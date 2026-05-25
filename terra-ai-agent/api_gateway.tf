# ------------------------------------------------------------------
# CloudWatch log group for API Gateway execution logs
# ------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/agent-core-${var.environment}"
  retention_in_days = 30
}

# ------------------------------------------------------------------
# REST API
# ------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "this" {
  name        = "agent-core-api-${var.environment}"
  description = "Receives form submissions and routes them to the Lambda agent orchestrator."

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# /submit resource
resource "aws_api_gateway_resource" "submit" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "submit"
}

# POST method on /submit — no API key auth (add aws_api_gateway_api_key
# resources if key-based auth is required in the future)
resource "aws_api_gateway_method" "post_submit" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.submit.id
  http_method   = "POST"
  authorization = "NONE"
}

# AWS_PROXY integration — full Lambda proxy (event + response passthrough)
resource "aws_api_gateway_integration" "post_submit_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.submit.id
  http_method             = aws_api_gateway_method.post_submit.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.bedrock_agent.invoke_arn
}

# ------------------------------------------------------------------
# CORS — OPTIONS preflight for browser clients (React app)
# ------------------------------------------------------------------
resource "aws_api_gateway_method" "options_submit" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.submit.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_submit_mock" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.options_submit.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.options_submit.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.options_submit.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_submit_mock]
}

# ------------------------------------------------------------------
# Deployment + Stage
# A new deployment is triggered whenever the API configuration changes.
# ------------------------------------------------------------------
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  # Force redeployment when method or integration changes
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.submit.id,
      aws_api_gateway_method.post_submit.id,
      aws_api_gateway_integration.post_submit_lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.post_submit_lambda,
    aws_api_gateway_integration.options_submit_mock,
  ]
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.environment

  # Throttling — protects Lambda from runaway traffic
  default_route_settings {
    # REST API stages use method-level throttling below (not default_route_settings),
    # but this block is retained for compatibility with HTTP API if migrated.
    # Throttling is applied via aws_api_gateway_method_settings below.
  }

  # Execution logging to CloudWatch
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
  }

  depends_on = [aws_api_gateway_account.this]
}

# Method-level throttling and detailed logging for POST /submit
resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "${aws_api_gateway_resource.submit.path_part}/POST"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    data_trace_enabled     = false # avoid logging request bodies (PII risk)
    throttling_burst_limit = var.api_gateway_throttle_burst
    throttling_rate_limit  = var.api_gateway_throttle_rate
  }
}
