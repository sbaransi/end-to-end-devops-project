output "instance_id" {
  description = "ID of the builder EC2 instance"
  value       = aws_instance.builder.id
}

output "public_ip" {
  description = "Public IP of the builder instance"
  value       = aws_instance.builder.public_ip
}

output "security_group_id" {
  description = "ID of the builder security group"
  value       = aws_security_group.builder_sg.id
}

output "ssh_key_name" {
  description = "Name of the AWS SSH key pair"
  value       = aws_key_pair.builder_key.key_name
}

output "ssh_private_key_path" {
  description = "Path to the generated private SSH key (the key itself is never printed)"
  value       = local_sensitive_file.private_key.filename
}

output "allowed_cidr" {
  description = "The only address allowed to reach ports 22 and 5001"
  value       = local.allowed_cidr
}

output "ssh_command" {
  description = "Command to connect to the instance"
  value       = "ssh -i ${local_sensitive_file.private_key.filename} ec2-user@${aws_instance.builder.public_ip}"
}

output "app_url" {
  description = "URL of the Flask app once its container runs"
  value       = "http://${aws_instance.builder.public_ip}:5001/"
}
