#**********************
# Web Hosting (via reusable module)
# S3 + CloudFront + ACM + Route53
#
# Two domains served by one distribution:
#   - xomappétit.xomware.com (canonical, IDN — punycode xn--xomapptit-g4a)
#   - xomappetit.xomware.com  (ASCII fallback — 301-redirects to canonical)
#
# Module v1.4.0 combines canonical_host redirect + subroute_rewrite into one
# viewer-request CloudFront Function (CF only allows one viewer-request fn
# per cache behavior). We need both: canonical to enforce the IDN host and
# subroute rewrite so Next.js static-export deep routes (/auth/sign-in.html)
# resolve correctly when requested without the extension.
#
# Note: a one-shot CloudFront update was issued out-of-band (2026-05-04) to
# swap the distribution's function_association from xomappetit-canonical-redirect
# to xomappetit-viewer-request. Terraform's apply ordering tried to delete the
# old function before updating the distribution, hitting CF's FunctionInUse
# constraint. The CLI swap unstuck the state; this apply finalizes the cleanup.
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
