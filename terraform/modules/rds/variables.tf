variable "project" {
  description = "Application name used as a namespace prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name used as a namespace prefix for all resources"
  type        = string
}

variable "region" {
  description = "AWS Region"
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

  secret_name = var.secret_name != null ? var.secret_name : "${var.environment}-${var.project}-db-secret"
}

variable "vpc_id" {
  description = "ID of the VPC where the RDS instance will be created"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting RDS storage and Performance Insights"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

variable "engine" {
  description = "Database engine (e.g., postgres, mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version (e.g., 15.17)"
  type        = string
  default     = "15.17"
}

variable "port" {
  description = "Database port. Defaults to 5432 for postgres, 3306 for mysql."
  type        = number
  default     = null
}

variable "instance_class" {
  description = "DB instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "allocated_storage_gb" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 40
}

variable "max_allocated_storage_gb" {
  description = "Max autoscaling storage in GB (0 disables autoscaling)"
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Allow public access to the RDS instance"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "delete_automated_backups" {
  description = "Delete automated backups on instance deletion"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes immediately instead of next maintenance window"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "ca_cert_identifier" {
  description = "Certificate authority identifier"
  type        = string
  default     = "rds-ca-rsa2048-g1"
}

variable "secret_name" {
  description = "Secrets Manager secret name containing 'username' and 'password'. Defaults to '<environment>-<project>-db-secret'."
  type        = string
  default     = null
}

variable "parameter_group_family" {
  description = "DB parameter group family (e.g., postgres15, mysql8.0)"
  type        = string
  default     = "postgres15"
}

variable "force_ssl" {
  description = "Force SSL connections via DB parameter group"
  type        = bool
  default     = true
}

variable "additional_parameters" {
  description = "Additional DB parameter group parameters"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "pending-reboot")
  }))
  default = []
}

variable "backup_retention_days" {
  description = "Automated backup retention in days"
  type        = number
  default     = 14
}

variable "backup_window" {
  description = "Preferred backup window in UTC (30m minimum)"
  type        = string
  default     = "04:00-04:30"
}

variable "maintenance_window" {
  description = "Preferred maintenance window in UTC"
  type        = string
  default     = "Sun:05:00-Sun:06:00"
}

# --- Monitoring ---

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0 disables it)"
  type        = number
  default     = 1validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "enable_performance_insights" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "pi_retention_days" {
  description = "Performance Insights retention period in days (7 or 731)"
  type        = number
  default     = 7validation {
    condition     = contains([7, 731], var.pi_retention_days)
    error_message = "Must be 7 (free tier) or 731 (2 years)."
  }
}

variable "cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch (e.g., postgresql, upgrade, error, slowquery)"
  type        = list(string)
  default     = ["postgresql", "upgrade"]
}

variable "enable_iam_auth" {
  description = "Enable IAM database authentication"
  type        = bool
  default     = true
}

variable "allow_from_security_group_ids" {
  description = "Security group IDs allowed to connect to the database"
  type        = list(string)
  default     = []
}

variable "allow_from_cidrs" {
  description = "CIDR blocks allowed to connect to the database"
  type        = list(string)
  default     = []
}
