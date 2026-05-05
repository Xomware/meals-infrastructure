########################################
# Blocks + reports.
#
# Blocks: PK userId (blocker), SK blockedUserId.
#         Read-time filter on feed/discover/list endpoints.
#         No GSI yet — "am I blocked by X?" not enforced for v1
#         (one-direction model: blocker doesn't see blocked).
#
# Reports: PK userId (reporter), SK <iso>#<reportId>. Write-only
#          inbox for now; admin moderation UI is a future feature.
#          90-day TTL keeps the table near-zero.
########################################

resource "aws_dynamodb_table" "blocks" {
  name         = "${var.app_name}-blocks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "blockedUserId"

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
    name = "blockedUserId"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-blocks" }))
}

resource "aws_dynamodb_table" "reports" {
  name         = "${var.app_name}-reports"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "sortKey"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "sortKey"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-reports" }))
}
