# Shared Cognito SSM data sources
#
# These read the SSM parameters exported by xomware-infrastructure (Phase 1
# of the auth epic). Xom Appetit consumes the shared User Pool rather than
# owning its own identity surface.

data "aws_ssm_parameter" "cognito_user_pool_arn" {
  name = "/xomware/shared/cognito/user-pool-arn"
}

data "aws_ssm_parameter" "cognito_user_pool_id" {
  name = "/xomware/shared/cognito/user-pool-id"
}

data "aws_ssm_parameter" "cognito_user_pool_jwks_url" {
  name = "/xomware/shared/cognito/user-pool-jwks-url"
}

data "aws_ssm_parameter" "cognito_hosted_ui_domain" {
  name = "/xomware/shared/cognito/hosted-ui-domain"
}

data "aws_ssm_parameter" "cognito_xomappetit_client_id" {
  name = "/xomware/shared/cognito/clients/xomappetit-id"
}

data "aws_ssm_parameter" "cognito_xomware_com_client_id" {
  name = "/xomware/shared/cognito/clients/xomware-com-id"
}
