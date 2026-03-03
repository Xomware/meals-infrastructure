########################################
# 1. meals - Main meals table
# PK: userId (partition key for RLS)
# SK: mealId (sort key)
########################################
resource "aws_dynamodb_table" "meals" {
  name           = "${var.app_name}-meals"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 0
  write_capacity = 0
  hash_key       = "userId"
  range_key      = "mealId"

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
    name = "mealId"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-meals" }))
}

########################################
# 2. meal-ratings
# PK: userId (partition key for RLS)
# SK: mealId (sort key)
########################################
resource "aws_dynamodb_table" "meal_ratings" {
  name           = "${var.app_name}-meal-ratings"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 0
  write_capacity = 0
  hash_key       = "userId"
  range_key      = "mealId"

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
    name = "mealId"
    type = "S"
  }

  # GSI: Lookup all ratings for a meal (across users)
  global_secondary_index {
    name            = "mealId-userId-index"
    hash_key        = "mealId"
    range_key       = "userId"
    projection_type = "ALL"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-meal-ratings" }))
}
