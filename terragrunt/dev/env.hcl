locals {
  project     = "jakops"
  environment = "dev"
  region      = "eu-central-1"
  common_tags = {
    Project     = local.project
    Environment = local.environment
  }
  aws_profile              = "terraform_dev"
  eks_version              = "1.34"
  vpc_cidr                 = "150.0.0.0/16"
  public_subnet_eks_count  = 3
  private_subnet_eks_count = 3
  nat_gateway_count        = 1
  node_instance_types = [
    "t3.xlarge",
    "t3a.xlarge",
    "t2.xlarge",
    "m5.xlarge",
    "m5a.xlarge",
    "m6i.xlarge"
  ]
  node_capacity_type = "SPOT"


  helm_repo_name          = "https://github.com/jakops-cloud/example-helm-charts"
  helm_repo_branch        = "master"


  module_vpc_version               = "v0.10.0"
  module_kms_version               = "v0.10.0"
  module_eks_version               = "v0.10.0"
  module_helm_version              = "v0.10.0"
  module_tunnel_version            = "v0.10.0"
  module_s3_version                = "v0.10.0"
  module_rds_version               = "v0.10.0"
}