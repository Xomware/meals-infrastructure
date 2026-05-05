########################################
# Recipe likes — one row per (recipe, liker).
#
# Toggle endpoint maintains a denormalized `likeCount` on the recipe
# row so feed/list views don't need to fan out per recipe. The
# per-row entries here back the `likedByMe` membership check
# (recipes-get does a single GetItem; feed batches via BatchGetItem).
########################################

resource "aws_dynamodb_table" "recipe_likes" {
  name         = "${var.app_name}-recipe-likes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "recipeId"
  range_key    = "userId"

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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-recipe-likes" }))
}
