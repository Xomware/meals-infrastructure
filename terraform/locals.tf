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
    APP_NAME                     = var.app_name
    RECIPES_TABLE_NAME           = aws_dynamodb_table.recipes.id
    COOKS_TABLE_NAME             = aws_dynamodb_table.cooks.id
    COOK_PARTICIPANTS_TABLE_NAME = aws_dynamodb_table.cook_participants.id
    RECIPE_RATINGS_TABLE_NAME    = aws_dynamodb_table.recipe_ratings.id
    RECIPE_COMMENTS_TABLE_NAME   = aws_dynamodb_table.recipe_comments.id
    FRIENDSHIPS_TABLE_NAME       = aws_dynamodb_table.friendships.id
    RECIPE_LIKES_TABLE_NAME      = aws_dynamodb_table.recipe_likes.id
    COOK_COMMENTS_TABLE_NAME     = aws_dynamodb_table.cook_comments.id
    NOTIFICATIONS_TABLE_NAME     = aws_dynamodb_table.notifications.id
    BLOCKS_TABLE_NAME            = aws_dynamodb_table.blocks.id
    REPORTS_TABLE_NAME           = aws_dynamodb_table.reports.id
    AWS_ACCOUNT_ID               = data.aws_caller_identity.web_app_account.account_id
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
