########################################
# Notifications service — 2 lambdas (list + mark-read).
# Notification *writes* happen inline in other lambdas via the shared
# notify() helper (see xomappetit-backend shared/notifications.js).
########################################

locals {
  notifications_lambdas = [
    {
      name        = "list"
      description = "List the caller's notifications (newest first, paginated)"
      path_part   = "list"
      http_method = "POST"
    },
    {
      name        = "mark-read"
      description = "Mark a single notification or all notifications as read"
      path_part   = "mark-read"
      http_method = "POST"
    },
  ]
}

resource "aws_lambda_function" "notifications" {
  for_each         = { for l in local.notifications_lambdas : l.name => l }
  function_name    = "${var.app_name}-notifications-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-notifications-${each.value.name}", "lambda_type" = "notifications" }))

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
