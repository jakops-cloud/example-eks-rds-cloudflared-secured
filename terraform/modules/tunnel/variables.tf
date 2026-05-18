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
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t4g.micro"
}

variable "instance_architecture" {
  description = "EC2 instance architecture: 'arm64' or 'x86_64'"
  type        = string
  default     = "arm64"
  validation {
    condition     = contains(["arm64", "x86_64"], var.instance_architecture)
    error_message = "Must be 'arm64' or 'x86_64'."
  }
}

variable "ami_id" {
  description = "Custom AMI ID to use. If null, latest RHEL 9 for the given architecture is used."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC for security group rules"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs to place the tunnel instance in"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN to encrypt root EBS volume and secrets"
  type        = string
}

variable "secret_name" {
  description = "Secrets Manager secret name containing the Cloudflare tunnel token (key: tunnel_token). Defaults to '<environment>-<project>-cloudflared'."
  type        = string
  default     = null
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to attach to the tunnel instance"
  type        = list(string)
  default     = []
}

variable "target_security_group_ids" {
  description = "Map of security group IDs that the tunnel should be allowed to reach on port 443"
  type        = map(string)
  default     = {}
}

variable "enable_ssm" {
  description = "Attach AmazonSSMManagedInstanceCore policy to allow SSM Session Manager access"
  type        = bool
  default     = true
}

variable "additional_iam_policy_arns" {
  description = "Additional IAM managed policy ARNs to attach to the tunnel role"
  type        = list(string)
  default     = []
}

variable "warp_routing_enabled" {
  description = "Enable WARP routing in Cloudflare Tunnel config"
  type        = bool
  default     = true
}
