# Meals Infrastructure

Terraform infrastructure for [meals.xomware.com](https://meals.xomware.com).

## Architecture
- S3 bucket for static site hosting
- CloudFront distribution with ACM certificate
- WAF protection
- Route53 DNS record

## Setup
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Deployment
The frontend repo (`Xomware/meals-frontend`) has a GitHub Actions workflow that:
1. Builds the Next.js static export
2. Syncs to the S3 bucket
3. Invalidates CloudFront cache

Required GitHub secrets on the frontend repo:
- `AWS_ROLE_ARN` - IAM role ARN for OIDC
- `S3_BUCKET` - S3 bucket name (from terraform output)
- `CF_DISTRIBUTION_ID` - CloudFront distribution ID (from terraform output)

