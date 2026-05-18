output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.s3.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.s3.arn
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.s3.id
}

output "s3_policy_arn" {
  description = "ARN of the IAM policy for S3 access"
  value       = aws_iam_policy.s3.arn
}

output "s3_user_name" {
  description = "Name of the IAM user (null if enable_iam_user is false)"
  value       = var.enable_iam_user ? aws_iam_user.s3_user[0].name : null
}

output "s3_user_arn" {
  description = "ARN of the IAM user (null if enable_iam_user is false)"
  value       = var.enable_iam_user ? aws_iam_user.s3_user[0].arn : null
}
