output "db_endpoint" {
  description = "RDS instance endpoint hostname"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.this.port
}

output "db_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.this.arn
}

output "db_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.id
}

output "db_name" {
  description = "RDS instance database name"
  value       = aws_db_instance.this.db_name
}

output "db_security_group_id" {
  description = "Security group ID for the RDS instance"
  value       = aws_security_group.db_sg.id
}

output "db_security_group_arn" {
  description = "Security group ARN for the RDS instance"
  value       = aws_security_group.db_sg.arn
}

output "db_parameter_group_id" {
  description = "Parameter group ID"
  value       = aws_db_parameter_group.this.id
}

output "enhanced_monitoring_role_arn" {
  description = "ARN of the enhanced monitoring IAM role (null if monitoring_interval is 0)"
  value       = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
}
