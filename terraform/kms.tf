# KMS key for S3 web app bucket. Needs a CloudFront-aware policy so that
# CloudFront's OAC can decrypt KMS-SSE-encrypted objects served via the
# web-hosting module's distribution.

resource "aws_kms_key" "web_app" {
  description             = "KMS key for ${var.app_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.standard_tags

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "KMSKeyPolicy"
    Statement = [
      {
        Sid      = "Full key access for account root"
        Effect   = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.web_app_account_id}:root"
        }
        Action   = ["kms:*"]
        Resource = "*"
      },
      {
        Sid       = "Key access for services accessing the S3 bucket"
        Effect    = "Allow"
        Principal = { AWS = ["*"] }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:CallerAccount" = local.web_app_account_id
            "kms:ViaService"    = "s3.${var.aws_region}.amazonaws.com"
          }
        }
      },
      {
        Sid       = "CloudFront key access"
        Effect    = "Allow"
        Principal = { Service = ["cloudfront.amazonaws.com"] }
        Action    = ["kms:Decrypt"]
        Resource  = "*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = module.web.cloudfront_distribution_arn
          }
        }
      },
    ]
  })
}

resource "aws_kms_alias" "web_app" {
  name          = "alias/${var.app_name}"
  target_key_id = aws_kms_key.web_app.key_id
}
