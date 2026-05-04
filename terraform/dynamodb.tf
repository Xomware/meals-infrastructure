########################################
# Xom Appétit — Model A schema (Recipe canonical + Cook session).
#
# Replaces the legacy per-user `xomappetit-meals` / `meal-ratings` /
# `meal-comments` tables. Names and shapes are NEW — no data migration
# (the legacy tables are destroyed in the same apply).
########################################

########################################
# 1. recipes — canonical, owned by one author
# PK: recipeId (uuid)
# GSI author-index: authorUserId (PK) + createdAt (SK)
########################################
resource "aws_dynamodb_table" "recipes" {
  name           = "${var.app_name}-recipes"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 0
  write_capacity = 0
  hash_key       = "recipeId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "recipeId"
    type = "S"
  }

  attribute {
    name = "authorUserId"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "S"
  }

  # GSI: list a user's recipes by recency.
  global_secondary_index {
    name            = "author-index"
    hash_key        = "authorUserId"
    range_key       = "createdAt"
    projection_type = "ALL"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-recipes" }))
}

########################################
# 2. cooks — one row per cook session
# PK: cookId (uuid)
# GSI recipe-index: recipeId (PK) + cookedAt (SK)
########################################
resource "aws_dynamodb_table" "cooks" {
  name           = "${var.app_name}-cooks"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 0
  write_capacity = 0
  hash_key       = "cookId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "cookId"
    type = "S"
  }

  attribute {
    name = "recipeId"
    type = "S"
  }

  attribute {
    name = "cookedAt"
    type = "S"
  }

  # GSI: all cooks of a recipe across users, ordered by date.
  global_secondary_index {
    name            = "recipe-index"
    hash_key        = "recipeId"
    range_key       = "cookedAt"
    projection_type = "ALL"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-cooks" }))
}

########################################
# 3. cook-participants — denormalized per-user view of cook sessions
# PK: userId (chef OR diner participant — one row per participant per cook)
# SK: cookedAt#cookId (sorts by date, unique-ifies multi-role participation)
#
# Why dedicated table: DynamoDB GSIs can't have multi-value (List) keys, and
# "all cooks I participated in" needs to fan out across both `chefs` and
# `diners` lists. `cooks-log` writes one row per chef + diner.
########################################
resource "aws_dynamodb_table" "cook_participants" {
  name           = "${var.app_name}-cook-participants"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 0
  write_capacity = 0
  hash_key       = "userId"
  range_key      = "cookedAtCookId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "cookedAtCookId"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-cook-participants" }))
}

########################################
# 4. recipe-ratings — replaces meal-ratings
# PK: recipeId, SK: userId
# (one rating per user per recipe; upsert)
########################################
resource "aws_dynamodb_table" "recipe_ratings" {
  name           = "${var.app_name}-recipe-ratings"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 0
  write_capacity = 0
  hash_key       = "recipeId"
  range_key      = "userId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "recipeId"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-recipe-ratings" }))
}

########################################
# 5. recipe-comments — replaces meal-comments
# PK: recipeId, SK: commentId (uuid)
########################################
resource "aws_dynamodb_table" "recipe_comments" {
  name           = "${var.app_name}-recipe-comments"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 0
  write_capacity = 0
  hash_key       = "recipeId"
  range_key      = "commentId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "recipeId"
    type = "S"
  }

  attribute {
    name = "commentId"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-recipe-comments" }))
}
