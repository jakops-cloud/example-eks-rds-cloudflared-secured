resource "aws_s3_bucket" "s3" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = merge(local.common_tags, {
    Name = local.bucket_name
    Type = "s3-bucket"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse" {
  bucket = aws_s3_bucket.s3.id

  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_id
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_access" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.s3.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_metric" "s3_metric" {
  count = var.enable_metrics ? 1 : 0

  bucket = aws_s3_bucket.s3.id
  name   = "EntireBucket"
}

resource "aws_s3_bucket_notification" "s3_notification" {
  count = var.enable_eventbridge ? 1 : 0

  bucket      = aws_s3_bucket.s3.id
  eventbridge = true
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.s3.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      filter {
        prefix = rule.value.prefix
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [rule.value.expiration_days] : []
        content {
          days = expiration.value
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days != null ? [rule.value.noncurrent_version_expiration_days] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value
        }
      }

      dynamic "transition" {
        for_each = rule.value.transition
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "s3_cors" {
  count = length(var.cors_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.s3.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_logging" "s3_logging" {
  count = var.logging_target_bucket != null ? 1 : 0

  bucket        = aws_s3_bucket.s3.id
  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix
}
