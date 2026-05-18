locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

include "root" {
  path = find_in_parent_folders()
}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    kms_key_id  = "mock-key-id"
    kms_key_arn = "arn:aws:kms:eu-central-1:000000000000:key/mock"
  }
}

terraform {
  source = "../../../terraform/modules/s3//?ref=${local.env.locals.module_s3_version}"
}

inputs = {
  project     = local.env.locals.project
  environment = local.env.locals.environment
  common_tags = local.env.locals.common_tags

  kms_key_id  = dependency.kms.outputs.kms_key_id
  kms_key_arn = dependency.kms.outputs.kms_key_arn

  enable_versioning  = true
  enable_iam_user    = true
  enable_eventbridge = false
  enable_metrics     = true

  lifecycle_rules = [
    {
      id      = "expire-old-objects"
      enabled = true
      prefix  = "logs/"
      expiration_days                    = 90
      noncurrent_version_expiration_days = 30
    }
  ]
}
