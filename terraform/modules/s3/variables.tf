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
}

locals {
  common_tags = merge(var.common_tags, {
    Project     = var.project
    Environment = var.environment
  })

  bucket_name = var.bucket_name != null ? var.bucket_name : "${var.environment}-${var.project}-s3"
}

variable "bucket_name" {
  description = "Override bucket name. Defaults to '<environment>-<project>-s3'."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "ID of the KMS key for bucket encryption"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for bucket encryption"
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_eventbridge" {
  description = "Enable EventBridge notifications for the bucket"
  type        = bool
  default     = false
}

variable "enable_metrics" {
  description = "Enable S3 request metrics for the entire bucket"
  type        = bool
  default     = false
}

variable "enable_iam_user" {
  description = "Create a dedicated IAM user with access to this bucket"
  type        = bool
  default     = true
}

variable "iam_user_name" {
  description = "Override IAM user name. Defaults to '<environment>-<project>-s3-user'."
  type        = string
  default     = null
}

variable "allowed_s3_actions" {
  description = "List of S3 actions to allow in the IAM policy"
  type        = list(string)
  default = [
    "s3:PutObject",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:ListBucket",
    "s3:PutObjectAcl",
    "s3:GetObjectAcl",
  ]
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules to apply to the bucket"
  type = list(object({
    id      = string
    enabled = bool
    prefix  = optional(string, "")
    expiration_days                    = optional(number, null)
    noncurrent_version_expiration_days = optional(number, null)
    transition = optional(list(object({
      days          = number
      storage_class = string
    })), [])
  }))
  default = []
}

variable "cors_rules" {
  description = "List of CORS rules for the bucket"
  type = list(object({
    allowed_headers = optional(list(string), [])
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, null)
  }))
  default = []
}

variable "logging_target_bucket" {
  description = "Target bucket for access logging. If null, logging is disabled."
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Prefix for access log objects"
  type        = string
  default     = "logs/"
}

variable "force_destroy" {
  description = "Allow destroying non-empty bucket"
  type        = bool
  default     = false
}
