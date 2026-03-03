# API Secret Key for authorizer
resource "aws_ssm_parameter" "api_secret_key" {
  name        = "/${var.app_name}/api/API_SECRET_KEY"
  description = "API Secret Key for Lambda Authorizer"
  type        = "SecureString"
  value       = var.api_secret_key
  tags        = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-api-secret-key" }))
}

resource "aws_ssm_parameter" "api_id" {
  name        = "/${var.app_name}/api/API_ID"
  description = "API Gateway REST API ID"
  type        = "SecureString"
  value       = module.api.rest_api_id
  tags        = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-api-id" }))
}
