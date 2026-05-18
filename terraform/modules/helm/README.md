# Helm Module

Terraform module for deploying Helm charts to an EKS cluster using AWS CodeBuild. The module provisions a CodeBuild project that connects to a source repository, authenticates to EKS, and runs Helm deployments via a buildspec.

## Features

- Creates a CodeBuild project that deploys Helm charts to EKS
- Configures VPC-enabled CodeBuild with scoped security group rules
- Grants CodeBuild EKS cluster admin access via EKS Access Entries
- Configurable source repository type (Bitbucket, GitHub, CodeCommit)
- Supports additional environment variables and IAM policy attachments
- Optional automatic build trigger on `terraform apply`

## Usage

```hcl
module "helm" {
  source = "./modules/helm"

  project     = "my-app"
  environment = "production"
  region      = "eu-central-1"

  common_tags = {
    Owner     = "platform-team"
    ManagedBy = "terraform"
  }

  vpc_id                        = "vpc-0abc123"
  vpc_cidr_block                = "10.0.0.0/16"
  private_subnet_ids            = ["subnet-0abc123", "subnet-0def456"]
  eks_cluster_name              = "production-my-app-eks"
  eks_cluster_security_group_id = "sg-0abc123"

  helm_repo_type          = "GITHUB"
  helm_repo_name          = "https://github.com/my-org/my-helm-charts"
  helm_repo_branch        = "main"
  codestar_connection_arn = "arn:aws:codeconnections:eu-central-1:123456789012:connection/abc123"

  external_secrets_role_arn = "arn:aws:iam::123456789012:role/external-secrets-role"
  efs_file_system_id        = "fs-0abc123"

  trigger_build_on_apply = true

  additional_codebuild_policies = []

  codebuild_environment_variables = [
    {
      name  = "MY_CUSTOM_VAR"
      value = "my-value"
    }
  ]
}
