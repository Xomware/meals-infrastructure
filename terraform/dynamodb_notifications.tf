########################################
# Notifications inbox.
#
# PK userId   = recipient (who's getting the notification)
# SK sortKey  = `<iso-createdAt>#<notifId>`  — sorts newest-last by
#               default; reads use ScanIndexForward=false.
#
# 90-day TTL via `ttl` numeric attribute keeps storage near-zero.
# `read` toggled by notifications-mark-read.
########################################

resource "aws_dynamodb_table" "notifications" {
  name         = "${var.app_name}-notifications"
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

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-notifications" }))
}
