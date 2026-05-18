# KMS Module

Terraform module for creating and managing AWS KMS (Key Management Service) keys with flexible, configurable key policies for AWS services.

## Features

- Creates a KMS key with automatic key rotation enabled
- Fully configurable list of allowed AWS service principals
- Optional dedicated CloudWatch Logs policy with encryption context condition
- Optional KMS key administrator permissions for IAM roles/users
- Supports multi-region key configuration
- Configurable key deletion window

## Usage

```hcl
module "kms" {
  source = "./modules/kms"

  project     = "my-app"
  environment = "production"
  aws_region  = "eu-central-1"

  common_tags = {
    Owner     = "platform-team"
    ManagedBy = "terraform"
  }

  deletion_window_in_days      = 7
  multi_region                 = false
  enable_cloudwatch_logs_policy = true

  allowed_services = [
    "eks.amazonaws.com",
    "ec2.amazonaws.com",
    "s3.amazonaws.com",
    "rds.amazonaws.com",
    "lambda.amazonaws.com"
  ]

  additional_key_admins = [
    "arn:aws:iam::123456789012:role/my-admin-role"
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project` | Application name used as a namespace prefix for all resources | `string` | n/a | yes |
| `environment` | Environment name used as a namespace prefix for all resources | `string` | n/a | yes |
| `aws_region` | AWS region used for region-scoped service principals (e.g. CloudWatch Logs) | `string` | n/a | yes |
| `common_tags` | Common tags to apply to all resources | `map(string)` | `{}` | no |
| `deletion_window_in_days` | KMS key deletion window in days (7–30) | `number` | `7` | no |
| `multi_region` | Enable multi-region KMS key | `bool` | `false` | no |
| `allowed_services` | List of AWS service principals allowed to use the KMS key | `list(string)` | see below | no |
| `enable_cloudwatch_logs_policy` | Enable dedicated CloudWatch Logs KMS policy statement with encryption context condition | `bool` | `true` | no |
| `additional_key_admins` | List of IAM ARNs to grant KMS key admin permissions | `list(string)` | `[]` | no |

### Default `allowed_services`

```hcl
[
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
```

## Outputs

| Name | Description |
|------|-------------|
| `kms_key_id` | KMS key ID |
| `kms_key_arn` | KMS key ARN |
| `kms_alias_name` | KMS key alias name |
| `kms_alias_arn` | KMS key alias ARN |

## Key Policy

The module constructs the KMS key policy from the following statements:

| Statement | Description | Condition |
|-----------|-------------|-----------|
| `EnableIAMUserPermissions` | Grants full `kms:*` access to the AWS account root | Always included |
| `AllowUseOfKeyForServices` | Grants encrypt/decrypt permissions to `allowed_services` | Always included |
| `AllowCloudWatchLogsUseOfKey` | Grants scoped encrypt/decrypt to CloudWatch Logs with encryption context condition | When `enable_cloudwatch_logs_policy = true` |
| `AllowKeyAdministration` | Grants full key administration to specified IAM ARNs | When `additional_key_admins` is non-empty |

## Resources

| Name | Type |
|------|------|
| `aws_kms_key.kms` | resource |
| `aws_kms_alias.alias` | resource |
| `aws_caller_identity.current` | data source |