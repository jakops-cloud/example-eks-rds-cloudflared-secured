variable "project" {
  description = "Application name used as a namespace prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name used as a namespace prefix for all resources"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

locals {
  common_tags = merge(var.common_tags, {
    Project     = var.project
    Environment = var.environment
  })

  nat_gateway_count = var.nat_gateway_strategy == "one_per_az" ? var.public_subnet_count : 1
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
  default     = 3
}

variable "private_subnet_count" {
  description = "Number of private subnets per tier"
  type        = number
  default     = 3
}

variable "nat_gateway_strategy" {
  description = "NAT gateway strategy: 'single' (one shared) or 'one_per_az' (one per AZ)"
  type        = string
  default     = "single"
  validation {
    condition     = contains(["single", "one_per_az"], var.nat_gateway_strategy)
    error_message = "Must be 'single' or 'one_per_az'."
  }
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "CloudWatch log retention in days for VPC flow logs"
  type        = number
  default     = 14
}

variable "endpoint_additional_ingress_cidrs" {
  description = "Additional CIDRs allowed to reach VPC endpoints (VPC CIDR is always included)"
  type        = list(string)
  default     = []
}

variable "enable_s3_endpoint" {
  description = "Enable S3 Gateway VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_ecr_api_endpoint" {
  description = "Enable ECR API Interface VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_ecr_dkr_endpoint" {
  description = "Enable ECR DKR Interface VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_ec2_endpoint" {
  description = "Enable EC2 Interface VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_sts_endpoint" {
  description = "Enable STS Interface VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_elb_endpoint" {
  description = "Enable ELB Interface VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_logs_endpoint" {
  description = "Enable CloudWatch Logs Interface VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_monitoring_endpoint" {
  description = "Enable CloudWatch Monitoring Interface VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_ssm_endpoint" {
  description = "Enable SSM Interface VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_ssmmessages_endpoint" {
  description = "Enable SSM Messages Interface VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_autoscaling_endpoint" {
  description = "Enable Autoscaling Interface VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB Gateway VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_secretsmanager_endpoint" {
  description = "Enable Secrets Manager Interface VPC endpoint"
  type        = bool
  default     = false
}
