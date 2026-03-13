#**********************
# WAF (shared from xomware-infrastructure)
# Consumes shared WAF ACL ARN via SSM Parameter Store
#**********************

data "aws_ssm_parameter" "shared_cloudfront_waf_arn" {
  name = "/xomware/shared/cloudfront-waf-acl-arn"
}
