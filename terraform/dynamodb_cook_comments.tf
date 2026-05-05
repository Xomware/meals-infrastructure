########################################
# Cook session comments — mirror of recipe-comments.
#
# PK cookId, SK commentId (uuid). One row per comment. Privacy
# inherits from the parent cook's recipe (handler-side gate).
########################################

resource "aws_dynamodb_table" "cook_comments" {
  name         = "${var.app_name}-cook-comments"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "cookId"
  range_key    = "commentId"

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
    name = "commentId"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-cook-comments" }))
}
