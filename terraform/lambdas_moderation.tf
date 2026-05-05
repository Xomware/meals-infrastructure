########################################
# Moderation lambdas — blocks/* + reports/*.
########################################

locals {
  moderation_lambdas = [
    {
      name        = "blocks-list"
      description = "List the caller's blocked users"
      path_part   = "list"
      http_method = "POST"
      service     = "blocks"
    },
    {
      name        = "blocks-add"
      description = "Block a user (caller blocks target)"
      path_part   = "add"
      http_method = "POST"
      service     = "blocks"
    },
    {
      name        = "blocks-remove"
      description = "Unblock a user"
      path_part   = "remove"
      http_method = "POST"
      service     = "blocks"
    },
    {
      name        = "reports-add"
      description = "Report a piece of content (recipe / cook / user / comment)"
      path_part   = "add"
      http_method = "POST"
      service     = "reports"
    },
  ]
}

resource "aws_lambda_function" "moderation" {
  for_each         = { for l in local.moderation_lambdas : l.name => l }
  function_name    = "${var.app_name}-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-${each.value.name}", "lambda_type" = "moderation" }))

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
