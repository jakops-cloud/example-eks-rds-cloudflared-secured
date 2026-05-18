resource "aws_codebuild_project" "helm_deploy" {
  name         = "${var.environment}-${var.project}-helm-deploy"
  description  = "Deploy Helm charts to EKS cluster ${var.eks_cluster_name}"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = var.codebuild_compute_type
    image                       = var.codebuild_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.eks_cluster_name
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    dynamic "environment_variable" {
      for_each = var.external_secrets_role_arn != "" ? [1] : []
      content {
        name  = "EXTERNAL_SECRETS_ROLE_ARN"
        value = var.external_secrets_role_arn
      }
    }

    dynamic "environment_variable" {
      for_each = var.efs_file_system_id != "" ? [1] : []
      content {
        name  = "EFS_FILE_SYSTEM_ID"
        value = var.efs_file_system_id
      }
    }

    dynamic "environment_variable" {
      for_each = var.codebuild_environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.private_subnet_ids
    security_group_ids = [aws_security_group.codebuild.id]
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("${path.module}/buildspec.yml")
  }

  secondary_sources {
    source_identifier = "helm_charts"
    type              = var.helm_repo_type
    location          = var.helm_repo_name
    git_clone_depth   = 1
  }

  secondary_source_version {
    source_identifier = "helm_charts"
    source_version    = var.helm_repo_branch
  }

  tags = local.common_tags
}

resource "null_resource" "helm_deploy_trigger" {
  count      = var.trigger_build_on_apply ? 1 : 0
  depends_on = [aws_codebuild_project.helm_deploy]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Starting CodeBuild project ${aws_codebuild_project.helm_deploy.name}..."
      aws codebuild start-build \
        --project-name ${aws_codebuild_project.helm_deploy.name} \
        --profile ${var.aws_profile} \
        --region ${var.region} \
        --query 'build.id' \
        --output text
    EOT
  }
}
