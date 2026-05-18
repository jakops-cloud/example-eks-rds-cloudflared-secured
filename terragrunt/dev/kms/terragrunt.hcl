include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))

  project     = local.common_vars.locals.project
  environment = local.common_vars.locals.environment
  region      = local.common_vars.locals.region
  common_tags = local.common_vars.locals.common_tags
}

terraform {
  source = "../../../../modules/kms"
}

inputs = {
  project     = local.project
  environment = local.environment
  aws_region  = local.region
  common_tags = local.common_tags

  deletion_window_in_days       = 7
  multi_region                  = false
  enable_cloudwatch_logs_policy = true

  allowed_services = [
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

  additional_key_admins = []
}
