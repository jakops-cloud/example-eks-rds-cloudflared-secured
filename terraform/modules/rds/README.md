```markdown
# RDS Module

This Terraform module provisions a production-ready AWS RDS instance with KMS encryption, SSL enforcement, enhanced monitoring, Performance Insights, and Secrets Manager credential management.

## Architecture

The module creates the following components:

- **DB Instance** — RDS instance (PostgreSQL or MySQL) with encrypted storage
- **DB Parameter Group** — with optional SSL enforcement and custom parameters
- **Security Group** — allowing inbound/outbound DB traffic from specified security groups or CIDRs
- **IAM Role** — for RDS Enhanced Monitoring (created when `monitoring_interval > 0`)

## Usage

```hcl
module "rds" {
  source = "./modules/rds"

  project     = "myapp"
  environment = "production"
  region      = "eu-west-1"

  common_tags = {
    ManagedBy = "Terraform"
  }

  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.rds_subnet_group_name
  kms_key_arn          = aws_kms_key.main.arn

  engine                 = "postgres"
  engine_version         = "15.17"
  parameter_group_family = "postgres15"
  instance_class         = "db.t4g.micro"

  allocated_storage_gb     = 40
  max_allocated_storage_gb = 100

  multi_az            = true
  deletion_protection = true

  monitoring_interval         = 60
  enable_performance_insights = true

  allow_from_security_group_ids = [
    module.eks.node_security_group_id
  ]
}
```

## Secrets Manager

The module expects a secret in AWS Secrets Manager with the following structure:

```json
{
  "username": "<db-username>",
  "password": "<db-password>"
}
```

By default, the secret name is `<environment>-<project>-db-secret`. Override with `secret_name`.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project` | Application name used as namespace prefix | `string` | — | ✅ |
| `environment` | Environment name used as namespace prefix | `string` | — | ✅ |
| `region` | AWS Region | `string` | — | ✅ |
| `common_tags` | Common tags applied to all resources | `map(string)` | — | ✅ |
| `vpc_id` | VPC ID where the RDS instance will be created | `string` | — | ✅ |
| `kms_key_arn` | KMS key ARN for storage and Performance Insights encryption | `string` | — | ✅ |
| `db_subnet_group_name` | Name of the DB subnet group | `string` | — | ✅ |
| `engine` | Database engine (`postgres` or `mysql`) | `string` | `"postgres"` | ❌ |
| `engine_version` | Database engine version | `string` | `"15.17"` | ❌ |
| `port` | Database port. Defaults to `5432` for postgres, `3306` for mysql | `number` | `null` | ❌ |
| `instance_class` | DB instance class | `string` | `"db.t4g.micro"` | ❌ |
| `storage_type` | Storage type (`gp2`, `gp3`, `io1`) | `string` | `"gp3"` | ❌ |
| `allocated_storage_gb` | Initial allocated storage in GB | `number` | `40` | ❌ |
| `max_allocated_storage_gb` | Max autoscaling storage in GB (`0` disables autoscaling) | `number` | `100` | ❌ |
| `multi_az` | Enable Multi-AZ deployment | `bool` | `false` | ❌ |
| `publicly_accessible` | Allow public access to the RDS instance | `bool` | `false` | ❌ |
| `deletion_protection` | Enable deletion protection | `bool` | `true` | ❌ |
| `skip_final_snapshot` | Skip final snapshot on deletion | `bool` | `false` | ❌ |
| `delete_automated_backups` | Delete automated backups on instance deletion | `bool` | `false` | ❌ |
| `apply_immediately` | Apply changes immediately instead of next maintenance window | `bool` | `false` | ❌ |
| `auto_minor_version_upgrade` | Enable automatic minor version upgrades | `bool` | `true` | ❌ |
| `ca_cert_identifier` | Certificate authority identifier | `string` | `"rds-ca-rsa2048-g1"` | ❌ |
| `secret_name` | Secrets Manager secret name. Defaults to `<environment>-<project>-db-secret` | `string` | `null` | ❌ |
| `parameter_group_family` | DB parameter group family (e.g. `postgres15`, `mysql8.0`) | `string` | `"postgres15"` | ❌ |
| `force_ssl` | Force SSL connections via DB parameter group | `bool` | `true` | ❌ |
| `additional_parameters` | Additional DB parameter group parameters | `list(object)` | `[]` | ❌ |
| `backup_retention_days` | Automated backup retention in days | `number` | `14` | ❌ |
| `backup_window` | Preferred backup window in UTC | `string` | `"04:00-04:30"` | ❌ |
| `maintenance_window` | Preferred maintenance window in UTC | `string` | `"Sun:05:00-Sun:06:00"` | ❌ |
| `monitoring_interval` | Enhanced monitoring interval in seconds. One of: `0, 1, 5, 10, 15, 30, 60` | `number` | `1` | ❌ |
| `enable_performance_insights` | Enable Performance Insights | `bool` | `true` | ❌ |
| `pi_retention_days` | Performance Insights retention in days (`7` or `731`) | `number` | `7` | ❌ |
| `cloudwatch_logs_exports` | Log types to export to CloudWatch | `list(string)` | `["postgresql", "upgrade"]` | ❌ |
| `enable_iam_auth` | Enable IAM database authentication | `bool` | `true` | ❌ |
| `allow_from_security_group_ids` | Security group IDs allowed to connect to the database | `list(string)` | `[]` | ❌ |
| `allow_from_cidrs` | CIDR blocks allowed to connect to the database | `list(string)` | `[]` | ❌ |

### `additional_parameters` object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | `string` | ✅ | Parameter name |
| `value` | `string` | ✅ | Parameter value |
| `apply_method` | `string` | ❌ | `immediate` or `pending-reboot` (default: `pending-reboot`) |

## Outputs

| Name | Description |
|------|-------------|
| `db_endpoint` | RDS instance endpoint hostname |
| `db_port` | RDS instance port |
| `db_arn` | RDS instance ARN |
| `db_id` | RDS instance identifier |
| `db_name` | RDS database name |
| `db_security_group_id` | Security group ID for the RDS instance |
| `db_security_group_arn` | Security group ARN for the RDS instance |
| `db_parameter_group_id` | Parameter group ID |
| `enhanced_monitoring_role_arn` | ARN of the enhanced monitoring IAM role (`null` if `monitoring_interval` is `0`) |

## Security Group Rules

| Direction | Protocol | Port | Source/Destination | Purpose |
|-----------|----------|------|--------------------|---------|
| Ingress | TCP | DB port | Allowed security groups | DB access from trusted workloads |
| Ingress | TCP | DB port | Allowed CIDRs | DB access from trusted CIDRs |
| Egress | TCP | DB port | Allowed security groups | DB egress to trusted workloads |
| Egress | TCP | DB port | Allowed CIDRs | DB egress to trusted CIDRs |

## SSL Enforcement

When `force_ssl = true`, the following parameter is added to the parameter group:

| Engine | Parameter | Value |
|--------|-----------|-------|
| `postgres` | `rds.force_ssl` | `1` |
| `mysql` | `require_secure_transport` | `1` |

Changes are applied on the next reboot (`pending-reboot`).
```