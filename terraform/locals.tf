locals {
  domain_name        = "${var.app_name}${var.domain_suffix}"
  api_domain_name    = "api.${local.domain_name}"
  web_app_account_id = data.aws_caller_identity.web_app_account.account_id

  standard_tags = {
    "source"   = "terraform"
    "app_name" = var.app_name
  }

  # Lambda environment variables (names match what handler code reads)
  lambda_variables = {
    APP_NAME            = var.app_name
    MEALS_TABLE_NAME    = aws_dynamodb_table.meals.id
    RATINGS_TABLE_NAME  = aws_dynamodb_table.meal_ratings.id
    COMMENTS_TABLE_NAME = aws_dynamodb_table.meal_comments.id
    AWS_ACCOUNT_ID      = data.aws_caller_identity.web_app_account.account_id
  }

  # API Gateway allowed headers
  api_allow_headers = [
    "Authorization",
    "Content-Type",
    "X-Amz-Date",
    "X-Amz-Security-Token",
    "X-Api-Key",
    "Origin",
    "Accept",
    "Access-Control-Allow-Origin"
  ]
}
