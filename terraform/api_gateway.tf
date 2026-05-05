## API Gateway Account (account-level singleton)
resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

#**********************
# API Gateway (via reusable module)
#**********************

locals {
  recipes_endpoints = [
    for l in local.recipes_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.recipes[l.name].invoke_arn
    }
  ]

  cooks_endpoints = [
    for l in local.cooks_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.cooks[l.name].invoke_arn
    }
  ]

  friends_endpoints = [
    for l in local.friends_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.friends[l.name].invoke_arn
    }
  ]

  notifications_endpoints = [
    for l in local.notifications_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.notifications[l.name].invoke_arn
    }
  ]

  blocks_endpoints = [
    for l in local.moderation_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.moderation[l.name].invoke_arn
    } if l.service == "blocks"
  ]

  reports_endpoints = [
    for l in local.moderation_lambdas : {
      name        = l.name
      path_part   = l.path_part
      http_method = l.http_method
      invoke_arn  = aws_lambda_function.moderation[l.name].invoke_arn
    } if l.service == "reports"
  ]
}

module "api" {
  source = "git::https://github.com/domgiordano/api-gateway-service.git?ref=v2.5.0"

  app_name      = var.app_name
  stage_name    = "dev"
  authorization = "COGNITO_USER_POOLS"
  cognito_user_pool_arns = [
    data.aws_ssm_parameter.cognito_user_pool_arn.value
  ]
  tags          = local.standard_tags
  allow_headers = local.api_allow_headers
  allow_origin  = "*"

  # Custom domain
  domain_name     = local.api_domain_name
  certificate_arn = aws_acm_certificate_validation.api.certificate_arn

  services = {
    recipes       = { path_prefix = "recipes", endpoints = local.recipes_endpoints }
    cooks         = { path_prefix = "cooks", endpoints = local.cooks_endpoints }
    friends       = { path_prefix = "friends", endpoints = local.friends_endpoints }
    notifications = { path_prefix = "notifications", endpoints = local.notifications_endpoints }
    blocks        = { path_prefix = "blocks", endpoints = local.blocks_endpoints }
    reports       = { path_prefix = "reports", endpoints = local.reports_endpoints }
  }
}
