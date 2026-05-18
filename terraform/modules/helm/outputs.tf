output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.helm_deploy.name
}

output "codebuild_project_arn" {
  description = "CodeBuild project ARN"
  value       = aws_codebuild_project.helm_deploy.arn
}

output "codebuild_role_arn" {
  description = "IAM role ARN used by CodeBuild"
  value       = aws_iam_role.codebuild_role.arn
}

output "codebuild_role_name" {
  description = "IAM role name used by CodeBuild"
  value       = aws_iam_role.codebuild_role.name
}

output "codebuild_security_group_id" {
  description = "Security group ID attached to the CodeBuild project"
  value       = aws_security_group.codebuild.id
}
