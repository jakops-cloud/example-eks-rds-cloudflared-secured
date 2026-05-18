variable "environment" {
  description = "Environment name used as a namespace prefix for all resources"
  type        = string
}

variable "project" {
  description = "Application name used as a namespace prefix for all resources"
  type        = string
}

variable "region" {
  description = "AWS region for all resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

locals {
  common_tags = merge(var.common_tags, {
    Project     = var.project
    Environment = var.environment
  })
}

variable "aws_profile" {
  description = "AWS CLI profile used to trigger CodeBuild"
  type        = string
  default     = "default"
}

variable "vpc_id" {
  description = "VPC ID where CodeBuild will run"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC (used for security group rules)"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for CodeBuild VPC config"
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster to deploy Helm charts to"
  type        = string
}

variable "eks_cluster_security_group_id" {
  description = "Security group ID of the EKS cluster control plane"
  type        = string
}

variable "helm_repo_type" {
  description = "CodeBuild secondary source type (e.g. BITBUCKET, GITHUB, CODECOMMIT)"
  type        = string
  default     = "BITBUCKET"
}

variable "helm_repo_name" {
  description = "Helm charts repository URL or name (used as CodeBuild secondary source location)"
  type        = string
}

variable "helm_repo_branch" {
  description = "Branch to track in the Helm charts repository"
  type        = string
  default     = "main"
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar/CodeConnections connection for source repository access"
  type        = string
}

variable "codebuild_compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_image" {
  description = "CodeBuild Docker image"
  type        = string
  default     = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
}

variable "codebuild_environment_variables" {
  description = "Additional environment variables to pass to CodeBuild"
  type = list(object({
    name  = string
    value = string
    type  = optional(string, "PLAINTEXT")
  }))
  default = []
}

variable "external_secrets_role_arn" {
  description = "ARN of the IAM role for External Secrets Operator"
  type        = string
  default     = ""
}

variable "efs_file_system_id" {
  description = "EFS file system ID"
  type        = string
  default     = ""
}

variable "additional_codebuild_policies" {
  description = "List of additional IAM policy ARNs to attach to the CodeBuild role"
  type        = list(string)
  default     = []
}

variable "trigger_build_on_apply" {
  description = "Whether to automatically trigger a CodeBuild build on terraform apply"
  type        = bool
  default     = true
}
