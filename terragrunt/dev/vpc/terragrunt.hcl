locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../terraform/modules/vpc//?ref=${local.env.locals.module_vpc_version}"
}

inputs = {
  project     = local.env.locals.project
  environment = local.env.locals.environment
  region      = local.env.locals.region
  vpc_cidr    = local.env.locals.vpc_cidr
  common_tags = local.env.locals.common_tags

  public_subnet_count  = local.env.locals.public_subnet_eks_count
  private_subnet_count = local.env.locals.private_subnet_eks_count
  nat_gateway_strategy = local.env.locals.nat_gateway_count == 1 ? "single" : "one_per_az"

  enable_flow_logs         = true
  flow_logs_retention_days = 14

  enable_s3_endpoint      = true
  enable_ecr_api_endpoint = true
  enable_ecr_dkr_endpoint = true
}
