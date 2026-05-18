output "tunnel_instance_id" {
  description = "ID of the tunnel EC2 instance"
  value       = aws_instance.tunnel.id
}

output "tunnel_instance_arn" {
  description = "ARN of the tunnel EC2 instance"
  value       = aws_instance.tunnel.arn
}

output "tunnel_private_ip" {
  description = "Private IP of the tunnel EC2 instance"
  value       = aws_instance.tunnel.private_ip
}

output "tunnel_security_group_id" {
  description = "Security group ID for the tunnel instance"
  value       = aws_security_group.tunnel_sg.id
}

output "tunnel_security_group_arn" {
  description = "Security group ARN for the tunnel instance"
  value       = aws_security_group.tunnel_sg.arn
}

output "tunnel_iam_role_arn" {
  description = "ARN of the tunnel IAM role"
  value       = aws_iam_role.tunnel_role.arn
}

output "tunnel_iam_role_name" {
  description = "Name of the tunnel IAM role"
  value       = aws_iam_role.tunnel_role.name
}
