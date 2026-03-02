module "waf_cloudfront" {
  source = "git::https://github.com/domgiordano/waf.git?ref=v1.1.0"

  app_name = "${var.app_name}-cloudfront"
  scope    = "CLOUDFRONT"
  tags     = local.standard_tags
}
