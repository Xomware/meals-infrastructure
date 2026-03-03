resource "aws_kms_key" "dynamodb" {
  description             = "KMS key for ${var.app_name} DynamoDB encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.standard_tags
}

resource "aws_kms_alias" "dynamodb" {
  name          = "alias/${var.app_name}-dynamodb"
  target_key_id = aws_kms_key.dynamodb.key_id
}
