locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                  = "vpc-00000000"
    private_subnet_ids      = ["subnet-00000000"]
    private_route_table_ids = ["rtb-00000000"]
  }
}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    kms_key_arn = "arn:aws:kms:eu-central-1:000000000000:key/mock"
  }
}

terraform {
  source = "../../../terraform/modules/eks//?ref=${local.env.locals.module_eks_version}"
}

inputs = {
  project     = local.env.locals.project
  environment = local.env.locals.environment
  region      = local.env.locals.region
  common_tags = local.env.locals.common_tags

  vpc_id                  = dependency.vpc.outputs.vpc_id
  private_subnet_ids      = dependency.vpc.outputs.private_subnet_ids
  private_route_table_ids = dependency.vpc.outputs.private_route_table_ids
  kms_key_arn             = dependency.kms.outputs.kms_key_arn

  cluster_version = local.env.locals.eks_version

  endpoint_private_access = true
  endpoint_public_access  = false

  node_instance_types = local.env.locals.node_instance_types
  node_capacity_type  = local.env.locals.node_capacity_type
  node_ami_type       = "AL2023_x86_64_STANDARD"
  node_desired_size   = 2
  node_min_size       = 1
  node_max_size       = 6

  enable_efs                      = true
  enable_karpenter                = true
  enable_load_balancer_controller = true

  enable_addon_ebs_csi         = true
  enable_addon_efs_csi         = true
  enable_addon_node_monitoring = true
}
