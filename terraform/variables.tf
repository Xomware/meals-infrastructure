variable "app_name" {
  description = "The name for the application."
  type        = string
  default     = "xomappetit"
}

variable "domain_suffix" {
  description = "Suffix for the domain of the app."
  type        = string
  default     = ".xomware.com"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "api_secret_key" {
  description = "API Secret Key for authorizer"
  type        = string
  sensitive   = true
}

# CloudFront Variables
variable "cloudfront_origin_path" {
  type    = string
  default = ""
}

variable "us_canada_only" {
  type    = bool
  default = true
}

variable "custom_error_response_page_path" {
  type    = string
  default = "/index.html"
}

variable "retain_on_delete" {
  type    = bool
  default = false
}

variable "minimum_tls_version" {
  type    = string
  default = "TLSv1.2_2018"
}

variable "enable_cloudfront_cache" {
  type    = bool
  default = true
}

# Lambda Variables
variable "lambda_runtime" {
  description = "Runtime for Lambda functions"
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_trace_mode" {
  description = "X-Ray tracing mode for Lambda"
  type        = string
  default     = "Active"
}

variable "lambda_memory_size" {
  description = "Memory size for Lambda functions in MB"
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Timeout for Lambda functions in seconds"
  type        = number
  default     = 30
}
