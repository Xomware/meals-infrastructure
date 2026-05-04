#**********************
# Web Hosting (via reusable module)
# S3 + CloudFront + ACM + Route53
#
# Two domains served by one distribution:
#   - xomappétit.xomware.com (canonical, IDN — punycode xn--xomapptit-g4a)
#   - xomappetit.xomware.com  (ASCII fallback — 301-redirects to canonical)
#
# Module v1.3.0 adds support for SAN aliases + a CloudFront Function that
# enforces canonical host. var.domain_name is treated as the *primary* on
# the cert/CF/Route53 side; canonical_host names the redirect target. We
# keep the ASCII form as var.domain_name (matches existing infra naming and
# is what API/lambda env vars reference) and put the IDN form in SANs.
#**********************

locals {
  idn_canonical_host = "xn--xomapptit-g4a.xomware.com" # punycode for xomappétit.xomware.com
}

module "web" {
  source = "git::https://github.com/domgiordano/web-hosting.git?ref=v1.4.0"

  app_name    = var.app_name
  domain_name = local.domain_name
  zone_id     = data.aws_route53_zone.web_zone.zone_id
  tags        = local.standard_tags

  # IDN canonical: xomappétit.xomware.com (punycode form for AWS providers
  # and Host-header comparison in the redirect function — both arrive as ASCII)
  subject_alternative_names = [local.idn_canonical_host]
  canonical_host            = local.idn_canonical_host

  # Static-export deep-route rewrite. Without this, /auth/sign-in 404s on S3
  # (Next.js export generated /auth/sign-in.html, not /auth/sign-in/index.html),
  # CloudFront's spa_error_path falls back to /index.html (the home page),
  # whose useRequireAuth hook redirects to /auth/sign-in?next=… — infinite loop.
  enable_subroute_rewrite = true

  # S3
  kms_key_arn = aws_kms_alias.web_app.target_key_arn

  # CloudFront
  waf_acl_arn               = data.aws_ssm_parameter.shared_cloudfront_waf_arn.value
  spa_error_path            = var.custom_error_response_page_path
  geo_restriction_locations = var.us_canada_only ? ["US", "CA"] : []
  enable_cache              = var.enable_cloudfront_cache
  origin_path               = var.cloudfront_origin_path
  minimum_tls_version       = var.minimum_tls_version
  retain_on_delete          = var.retain_on_delete
}
