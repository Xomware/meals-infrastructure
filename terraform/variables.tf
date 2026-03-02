variable "app_name" {
  description = "The name for the application."
  type        = string
  default     = "meals"
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
