locals {
  db_port = var.port != null ? var.port : (var.engine == "postgres" ? 5432 : 3306)

  ssl_parameter = var.force_ssl ? [{
    name         = var.engine == "postgres" ? "rds.force_ssl" : "require_secure_transport"
    value        = "1"
    apply_method = "pending-reboot"
  }] : []

  all_parameters = concat(local.ssl_parameter, var.additional_parameters)
}

resource "aws_db_parameter_group" "this" {
  name        = "${var.environment}-${var.project}-pg"
  family      = var.parameter_group_family
  description = "Parameter group for ${var.environment}-${var.project}"

  dynamic "parameter" {
    for_each = local.all_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-pg"
    Type = "db-parameter-group"
  })
}

resource "aws_db_instance" "this" {
  identifier                = "${var.environment}-${var.project}-db"
  final_snapshot_identifier = "${var.environment}-${var.project}-db-final"

  engine         = var.engine
  engine_version = var.engine_version
  port           = local.db_port

  instance_class         = var.instance_class
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  parameter_group_name   = aws_db_parameter_group.this.name

  username = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["username"]
  password = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]

  allocated_storage     = var.allocated_storage_gb
  max_allocated_storage = var.max_allocated_storage_gb
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  multi_az                            = var.multi_az
  publicly_accessible                 = var.publicly_accessible
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  delete_automated_backups            = var.delete_automated_backups
  ca_cert_identifier                  = var.ca_cert_identifier
  iam_database_authentication_enabled = var.enable_iam_auth

  backup_retention_period = var.backup_retention_days
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  copy_tags_to_snapshot   = true

  enabled_cloudwatch_logs_exports       = var.cloudwatch_logs_exports
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_kms_key_id       = var.enable_performance_insights ? var.kms_key_arn : null
  performance_insights_retention_period = var.enable_performance_insights ? var.pi_retention_days : null

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-db"
    Type = "rds-instance"
  })
}
