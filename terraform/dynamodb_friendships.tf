########################################
# Xom Appétit — friendships table.
#
# One row per direction:
#   pending request:  (caller -> target, status='pending')   one row only
#   accepted:         BOTH (A -> B, accepted) AND (B -> A, accepted)
#                     so "my friends" is a single Query by PK=me.
#
# Reverse-direction lookups (incoming requests) go through the
# `friend-index` GSI (PK = friendUserId).
########################################

resource "aws_dynamodb_table" "friendships" {
  name           = "${var.app_name}-friendships"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 0
  write_capacity = 0
  hash_key       = "userId"
  range_key      = "friendUserId"

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
    name = "friendUserId"
    type = "S"
  }

  # Reverse-direction lookup — "who has a row pointing at me?"
  global_secondary_index {
    name            = "friend-index"
    hash_key        = "friendUserId"
    range_key       = "userId"
    projection_type = "ALL"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-friendships" }))
}
