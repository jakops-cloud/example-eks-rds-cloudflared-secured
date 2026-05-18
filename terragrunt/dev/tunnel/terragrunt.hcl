locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id         = "vpc-00000000"
    vpc_cidr_block = "150.0.0.0/16"
    private_subnet_ids = ["subnet-00000000"]
  }
}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    kms_key_arn = "arn:aws:kms:eu-central-1:000000000000:key/mock"
  }
}

dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    node_security_group_id = "sg-00000000"
  }
}

terraform {
  source = "../../../terraform/modules/tunnel//?ref=${local.env.locals.module_tunnel_version}"
}

inputs = {
  project     = local.env.locals.project
  environment = local.env.locals.environment
  region      = local.env.locals.region
  common_tags = local.env.locals.common_tags

  vpc_id         = dependency.vpc.outputs.vpc_id
  vpc_cidr_block = dependency.vpc.outputs.vpc_cidr_block
  subnet_ids     = dependency.vpc.outputs.private_subnet_ids
  kms_key_arn    = dependency.kms.outputs.kms_key_arn

  instance_type         = "t4g.micro"
  instance_architecture = "arm64"

  warp_routing_enabled = true
  enable_ssm           = true

  target_security_group_ids = {
    eks_nodes = dependency.eks.outputs.node_security_group_id
  }
}
