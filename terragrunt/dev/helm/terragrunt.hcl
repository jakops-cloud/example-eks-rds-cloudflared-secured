include "root" {
  path = find_in_parent_folders()
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))

  project     = local.common_vars.locals.project
  environment = local.common_vars.locals.environment
  region      = local.common_vars.locals.region
  aws_profile = local.common_vars.locals.aws_profile
  common_tags = local.common_vars.locals.common_tags
}

terraform {
  source = "../../../../modules/helm"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name              = "mock-cluster"
    cluster_security_group_id = "sg-00000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id             = "vpc-00000000"
    vpc_cidr_block     = "10.0.0.0/16"
    private_subnet_ids = ["subnet-00000000"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  project     = local.project
  environment = local.environment
  region      = local.region
  aws_profile = local.aws_profile
  common_tags = local.common_tags

  vpc_id                        = dependency.vpc.outputs.vpc_id
  vpc_cidr_block                = dependency.vpc.outputs.vpc_cidr_block
  private_subnet_ids            = dependency.vpc.outputs.private_subnet_ids
  eks_cluster_name              = dependency.eks.outputs.cluster_name
  eks_cluster_security_group_id = dependency.eks.outputs.cluster_security_group_id

  helm_repo_type          = "BITBUCKET"
  helm_repo_name          = "https://bitbucket.org/my-org/my-helm-charts"
  helm_repo_branch        = "main"
  codestar_connection_arn = "arn:aws:codeconnections:eu-central-1:123456789012:connection/abc123"

  codebuild_compute_type = "BUILD_GENERAL1_SMALL"
  codebuild_image        = "aws/codebuild/amazonlinux-x86_64-standard:5.0"

  external_secrets_role_arn = ""
  efs_file_system_id        = ""

  trigger_build_on_apply        = true
  additional_codebuild_policies = []

  codebuild_environment_variables = []
}
