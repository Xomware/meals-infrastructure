locals {
  meals_lambdas = [
    {
      name        = "list"
      description = "Get all meals for the authenticated user"
      path_part   = "list"
      http_method = "GET"
    },
    {
      name        = "create"
      description = "Create a new meal"
      path_part   = "create"
      http_method = "POST"
    },
    {
      name        = "get"
      description = "Get a single meal by ID (id in body)"
      path_part   = "get"
      http_method = "POST"
    },
    {
      name        = "update"
      description = "Toggle cooked on a meal (id in body)"
      path_part   = "update"
      http_method = "POST"
    },
    {
      name        = "delete"
      description = "Delete a meal (id in body)"
      path_part   = "delete"
      http_method = "POST"
    },
    {
      name        = "rate"
      description = "Rate a meal"
      path_part   = "rate"
      http_method = "POST"
    },
    {
      name        = "ratings"
      description = "Get ratings for a meal"
      path_part   = "ratings"
      http_method = "POST"
    },
    {
      name        = "edit"
      description = "Update fields on an existing meal (instructions, ingredients, etc.)"
      path_part   = "edit"
      http_method = "POST"
    },
    {
      name        = "comment-add"
      description = "Add a comment to a meal"
      path_part   = "comment-add"
      http_method = "POST"
    },
    {
      name        = "comments-list"
      description = "List comments for a meal"
      path_part   = "comments-list"
      http_method = "POST"
    },
    {
      name        = "comment-delete"
      description = "Delete a comment (author only)"
      path_part   = "comment-delete"
      http_method = "POST"
    },
  ]
}

resource "aws_lambda_function" "meals" {
  for_each         = { for lambda in local.meals_lambdas : lambda.name => lambda }
  function_name    = "${var.app_name}-meals-${each.value.name}"
  description      = each.value.description
  filename         = "./templates/lambda_stub.zip"
  source_code_hash = filebase64sha256("./templates/lambda_stub.zip")
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = local.lambda_variables
  }

  tracing_config {
    mode = var.lambda_trace_mode
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-meals-${each.value.name}", "lambda_type" = "meals" }))

  lifecycle {
    ignore_changes = [
      description,
      filename,
      source_code_hash
    ]
  }

  depends_on = [
    aws_iam_role_policy.lambda_role_policy,
    aws_iam_role.lambda_role
  ]
}
