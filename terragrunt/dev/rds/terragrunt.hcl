locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id               = "vpc-00000000"
    rds_subnet_group_name = "mock-subnet-group"
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
  source = "../../../terraform/modules/rds//?ref=${local.env.locals.module_rds_version}"
}

inputs = {
  project     = local.env.locals.project
  environment = local.env.locals.environment
  region      = local.env.locals.region
  common_tags = local.env.locals.common_tags

  vpc_id               = dependency.vpc.outputs.vpc_id
  db_subnet_group_name = dependency.vpc.outputs.rds_subnet_group_name
  kms_key_arn          = dependency.kms.outputs.kms_key_arn

  engine                 = "postgres"
  engine_version         = "15.17"
  parameter_group_family = "postgres15"
  instance_class         = "db.t4g.micro"

  allocated_storage_gb     = 40
  max_allocated_storage_gb = 100

  multi_az            = false
  deletion_protection = false
  skip_final_snapshot = true

  monitoring_interval         = 60
  enable_performance_insights = true

  allow_from_security_group_ids = [
    dependency.eks.outputs.node_security_group_id
  ]
}
