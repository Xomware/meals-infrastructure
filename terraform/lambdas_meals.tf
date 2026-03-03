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
      description = "Get a single meal by ID"
      path_part   = "get"
      http_method = "GET"
    },
    {
      name        = "update"
      description = "Update an existing meal"
      path_part   = "update"
      http_method = "PUT"
    },
    {
      name        = "delete"
      description = "Delete a meal"
      path_part   = "delete"
      http_method = "DELETE"
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
      http_method = "GET"
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
