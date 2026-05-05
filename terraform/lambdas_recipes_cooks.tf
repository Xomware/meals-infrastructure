########################################
# Xom Appétit — Lambda functions for the Recipe + Cook services.
#
# Replaces the legacy `meals_lambdas` local + `aws_lambda_function.meals`
# resources. Two flat services:
#   - recipes/* (9 endpoints)
#   - cooks/*   (5 endpoints)
########################################

locals {
  recipes_lambdas = [
    {
      name        = "create"
      description = "Create a new recipe owned by the caller"
      path_part   = "create"
      http_method = "POST"
    },
    {
      name        = "list"
      description = "List a user's recipes (caller's by default; other user's public-only)"
      path_part   = "list"
      http_method = "POST"
    },
    {
      name        = "list-public"
      description = "Global feed of public recipes, newest first (paginated)"
      path_part   = "list-public"
      http_method = "POST"
    },
    {
      name        = "search"
      description = "Search public recipes by name (case-insensitive contains)"
      path_part   = "search"
      http_method = "POST"
    },
    {
      name        = "get"
      description = "Get a single recipe by id (privacy-enforced)"
      path_part   = "get"
      http_method = "POST"
    },
    {
      name        = "edit"
      description = "Edit fields on an owned recipe"
      path_part   = "edit"
      http_method = "POST"
    },
    {
      name        = "delete"
      description = "Delete an owned recipe"
      path_part   = "delete"
      http_method = "POST"
    },
    {
      name        = "rate"
      description = "Rate a recipe (one per caller, upsert; recomputes avgRating)"
      path_part   = "rate"
      http_method = "POST"
    },
    {
      name        = "like"
      description = "Toggle a like on a recipe (returns new count + likedByMe)"
      path_part   = "like"
      http_method = "POST"
    },
    {
      name        = "comment-add"
      description = "Add a comment to a recipe"
      path_part   = "comment-add"
      http_method = "POST"
    },
    {
      name        = "comments-list"
      description = "List comments for a recipe"
      path_part   = "comments-list"
      http_method = "POST"
    },
    {
      name        = "comment-delete"
      description = "Delete a comment (author only)"
      path_part   = "comment-delete"
      http_method = "POST"
    },
    {
      name        = "import-url"
      description = "Import a recipe from a URL (JSON-LD fast path, Claude Haiku fallback). Returns a draft to prefill /recipes/new."
      path_part   = "import-url"
      http_method = "POST"
    },
    {
      name        = "import-text"
      description = "Import a recipe from pasted text (Instagram/TikTok captions, OCR, blog excerpts). Claude Haiku → sanitized draft."
      path_part   = "import-text"
      http_method = "POST"
    },
  ]

  cooks_lambdas = [
    {
      name        = "log"
      description = "Log a new cook session (writes cooks + cook-participants, bumps recipe.cookCount)"
      path_part   = "log"
      http_method = "POST"
    },
    {
      name        = "list"
      description = "List cooks — scope: 'mine' (via cook-participants) or 'recipe' (via recipe-index)"
      path_part   = "list"
      http_method = "POST"
    },
    {
      name        = "get"
      description = "Get a single cook session"
      path_part   = "get"
      http_method = "POST"
    },
    {
      name        = "edit"
      description = "Edit a cook session (chef-only)"
      path_part   = "edit"
      http_method = "POST"
    },
    {
      name        = "delete"
      description = "Delete a cook session (chef-only)"
      path_part   = "delete"
      http_method = "POST"
    },
    {
      name        = "comment-add"
      description = "Add a comment to a cook session"
      path_part   = "comment-add"
      http_method = "POST"
    },
    {
      name        = "comments-list"
      description = "List comments on a cook session"
      path_part   = "comments-list"
      http_method = "POST"
    },
    {
      name        = "comment-delete"
      description = "Delete a cook-session comment (author or chef only)"
      path_part   = "comment-delete"
      http_method = "POST"
    },
  ]

  friends_lambdas = [
    {
      name        = "list"
      description = "List the caller's friends, incoming requests, and outgoing pending requests"
      path_part   = "list"
      http_method = "POST"
    },
    {
      name        = "add"
      description = "Send a friend request to another user (instant friend if reciprocal pending)"
      path_part   = "add"
      http_method = "POST"
    },
    {
      name        = "respond"
      description = "Accept or decline an incoming friend request"
      path_part   = "respond"
      http_method = "POST"
    },
    {
      name        = "remove"
      description = "Cancel an outgoing pending request, or remove an accepted friend"
      path_part   = "remove"
      http_method = "POST"
    },
    {
      name        = "feed"
      description = "Recipes from caller + caller's friends, newest first (paginated)"
      path_part   = "feed"
      http_method = "POST"
    },
  ]
}

resource "aws_lambda_function" "recipes" {
  for_each         = { for l in local.recipes_lambdas : l.name => l }
  function_name    = "${var.app_name}-recipes-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-recipes-${each.value.name}", "lambda_type" = "recipes" }))

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

resource "aws_lambda_function" "friends" {
  for_each         = { for l in local.friends_lambdas : l.name => l }
  function_name    = "${var.app_name}-friends-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-friends-${each.value.name}", "lambda_type" = "friends" }))

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

resource "aws_lambda_function" "cooks" {
  for_each         = { for l in local.cooks_lambdas : l.name => l }
  function_name    = "${var.app_name}-cooks-${each.value.name}"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-cooks-${each.value.name}", "lambda_type" = "cooks" }))

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
