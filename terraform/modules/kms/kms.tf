data "aws_caller_identity" "current" {}

locals {
  cloudwatch_logs_principal = "logs.${var.aws_region}.amazonaws.com"

  all_services = var.enable_cloudwatch_logs_policy
    ? concat(var.allowed_services, [local.cloudwatch_logs_principal])
    : var.allowed_services

  cloudwatch_statement = var.enable_cloudwatch_logs_policy ? [{
    Sid    = "AllowCloudWatchLogsUseOfKey"
    Effect = "Allow"
    Principal = {
      Service = local.cloudwatch_logs_principal
    }
    Action = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    Resource = "*"
    Condition = {
      ArnEquals = {
        "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:*"
      }
    }
  }] : []

  key_admin_statement = length(var.additional_key_admins) > 0 ? [{
    Sid    = "AllowKeyAdministration"
    Effect = "Allow"
    Principal = {
      AWS = var.additional_key_admins
    }
    Action = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    Resource = "*"}] : []
}

resource "aws_kms_key" "kms" {
  description             = "${var.environment} ${var.project} KMS key"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  multi_region            = var.multi_region

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-kms-key"
    Type = "kms-key"
  })

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "EnableIAMUserPermissions"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
          Action   = "kms:*"
          Resource = "*"
        },
        {
          Sid    = "AllowUseOfKeyForServices"
          Effect = "Allow"
          Principal = {
            Service = local.all_services
          }
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ]
          Resource = "*"
        }
      ],
      local.cloudwatch_statement,
      local.key_admin_statement
    )
  })
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.environment}-${var.project}-kms-key"
  target_key_id = aws_kms_key.kms.id
}
