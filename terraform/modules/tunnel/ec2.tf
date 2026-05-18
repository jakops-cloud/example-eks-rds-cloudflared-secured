locals {
  secret_name = var.secret_name != null ? var.secret_name : "${var.environment}-${var.project}-cloudflared"

  ami_arch_filter = var.instance_architecture == "arm64" ? "arm64" : "x86_64"
}

data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat

  filter {
    name   = "name"
    values = ["RHEL-9*_HVM-*-${local.ami_arch_filter}-*"]
  }

  filter {
    name   = "architecture"
    values = [local.ami_arch_filter]
  }
}

resource "aws_instance" "tunnel" {
  ami                    = var.ami_id != null ? var.ami_id : data.aws_ami.rhel.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.tunnel_profile.name
  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = concat([aws_security_group.tunnel_sg.id], var.additional_security_group_ids)

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
    kms_key_id            = var.kms_key_arn
  }

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh.tpl", {
    region               = var.region
    secret_name          = local.secret_name
    warp_routing_enabled = var.warp_routing_enabled
  }))

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project}-cloudflared-tunnel"
    Type = "ec2-instance"
  })
}
