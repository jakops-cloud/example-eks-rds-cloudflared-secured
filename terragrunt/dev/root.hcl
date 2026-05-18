locals {
  region = "eu-central-1"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "jakops-nonprod-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    profile        = "terraform_dev"
    dynamodb_table = "jakops-nonprod-terraform-locks"
  }
}

terraform {
  extra_arguments "provider_cache" {
    commands = ["init", "validate", "plan", "apply", "destroy"]
    env_vars = {
      TF_PLUGIN_CACHE_DIR = "${get_terragrunt_dir()}/../.terragrunt-cache"
    }
  }
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {}
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.31"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "terraform_dev"
}
EOF
}