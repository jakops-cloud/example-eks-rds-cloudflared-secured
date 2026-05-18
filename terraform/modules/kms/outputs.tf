output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.kms.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.kms.arn
}

output "kms_alias_name" {
  description = "KMS key alias name"
  value       = aws_kms_alias.alias.name
}

output "kms_alias_arn" {
  description = "KMS key alias ARN"
  value       = aws_kms_alias.alias.arn
}
