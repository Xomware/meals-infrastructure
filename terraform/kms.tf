resource "aws_kms_key" "web_app" {
  description             = "KMS key for ${var.app_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.standard_tags
}

resource "aws_kms_alias" "web_app" {
  name          = "alias/${var.app_name}"
  target_key_id = aws_kms_key.web_app.key_id
}
