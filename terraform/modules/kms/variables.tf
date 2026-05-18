variable "project" {
  description = "Application name used as a namespace prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name used as a namespace prefix for all resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

locals {
  common_tags = merge(var.common_tags, {
    Project     = var.project
    Environment = var.environment
  })
}

variable "deletion_window_in_days" {
  description = "KMS key deletion window in days (7–30)"
  type        = number
  default     = 7
  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days."
  }
}

variable "multi_region" {
  description = "Enable multi-region KMS key"
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "AWS region used for region-scoped service principals (e.g. CloudWatch Logs)"
  type        = string
}

variable "allowed_services" {
  description = "List of AWS service principals allowed to use the KMS key"
  type        = list(string)
  default = [
    "eks.amazonaws.com",
    "ec2.amazonaws.com",
    "sns.amazonaws.com",
    "ses.amazonaws.com",
    "s3.amazonaws.com",
    "rds.amazonaws.com",
    "redshift.amazonaws.com",
    "redshift-serverless.amazonaws.com",
    "lambda.amazonaws.com"
  ]
}

variable "enable_cloudwatch_logs_policy" {
  description = "Enable dedicated CloudWatch Logs KMS policy statement with encryption context condition"
  type        = bool
  default     = true
}

variable "additional_key_admins" {
  description = "List of IAM ARNs to grant KMS key admin permissions"
  type        = list(string)
  default     = []
}
